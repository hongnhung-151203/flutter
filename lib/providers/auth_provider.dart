import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../services/firebase_service.dart'; // Thêm dòng này vào đầu file

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._database);

  static const _prefsKey = 'userInfo';

  final FirebaseDatabase? _database;
  StreamSubscription<DatabaseEvent>? _userStreamSubscription;
  final List<UserProfile> _fallbackUsers = [
    UserProfile(
      id: 'landlord1',
      email: 'landlord@example.com',
      name: 'Nguyen Van Chu',
      role: UserRole.landlord,
      roomId: null,
      password: '123456',
    ),
    UserProfile(
      id: 'tenant1',
      email: 'tenant@example.com',
      name: 'Nguyen Van A',
      role: UserRole.tenant,
      roomId: '101',
      password: '123456',
    ),
    UserProfile(
      id: 'tenant2',
      email: 'tenant2@example.com',
      name: 'Tran Thi B',
      role: UserRole.tenant,
      roomId: '103',
      password: '123456',
    ),
  ];

  List<UserProfile> _users = [];
  UserProfile? _currentUser;
  bool _loading = false;
  String? _error;
  bool _isOnline = false;

  // Getters
  UserProfile? get currentUser => _currentUser;
  List<UserProfile> get users => List.unmodifiable(_users);
  bool get isLoading => _loading;
  String? get errorMessage => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isLandlord => _currentUser?.role == UserRole.landlord;
  bool get isTenant => _currentUser?.role == UserRole.tenant;
  bool get isOnline => _isOnline;

  Future<void> bootstrap() async {
    await _restoreSession();
    if (_database != null) {
      await _initializeFirebaseConnection();
    } else {
      _isOnline = false;
      _users = List.from(_fallbackUsers);
      notifyListeners();
    }
    await _loadAllUsers();
  }

  /// Initialize Firebase connection and set up realtime listeners
  Future<void> _initializeFirebaseConnection() async {
    if (_database == null) {
      _isOnline = false;
      if (kDebugMode) {
        debugPrint('AuthProvider: Firebase database is null');
      }
      return;
    }

    try {
      // Test connection by trying to read from Firebase
      if (kDebugMode) {
        debugPrint('AuthProvider: Testing Firebase connection...');
      }

      final snapshot = await _database.ref('users').get();
      _isOnline = true;

      if (kDebugMode) {
        debugPrint('AuthProvider: Firebase connection successful');
        debugPrint('AuthProvider: Users data exists: ${snapshot.exists}');
        if (snapshot.exists) {
          debugPrint('AuthProvider: Users data: ${snapshot.value}');
        }
      }

      // Set up realtime listener for users
      _userStreamSubscription?.cancel();
      _userStreamSubscription = _database
          .ref('users')
          .onValue
          .listen(
            (event) {
              if (kDebugMode) {
                debugPrint('AuthProvider: Received Firebase update');
              }
              _handleUsersUpdate(event);
            },
            onError: (error) {
              if (kDebugMode) {
                debugPrint('AuthProvider: Firebase listener error: $error');
              }
              _isOnline = false;
              notifyListeners();
            },
          );
    } catch (error) {
      _isOnline = false;
      if (kDebugMode) {
        debugPrint('AuthProvider: Firebase connection failed: $error');
      }
    }
    notifyListeners();
  }

  /// Handle realtime updates from Firebase
  void _handleUsersUpdate(DatabaseEvent event) {
    try {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        _users = data.entries.map((entry) {
          final userData = Map<dynamic, dynamic>.from(entry.value);
          return UserProfile.fromMap(userData);
        }).toList();
      } else {
        _users = [];
      }
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AuthProvider: Error handling users update: $error');
      }
    }
  }

  /// Load all users from Firebase or fallback data
  Future<void> _loadAllUsers() async {
    if (_database != null && _isOnline) {
      try {
        final snapshot = await _database.ref('users').get();
        if (snapshot.exists && snapshot.value is Map) {
          final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
          _users = data.entries.map((entry) {
            final userData = Map<dynamic, dynamic>.from(entry.value);
            return UserProfile.fromMap(userData);
          }).toList();
        } else {
          _users = [];
        }
      } catch (error) {
        _users = List.from(_fallbackUsers);
        if (kDebugMode) {
          debugPrint(
            'AuthProvider: Failed to load users from Firebase: $error',
          );
        }
      }
    } else {
      _users = List.from(_fallbackUsers);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _userStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      _currentUser = UserProfile.fromJson(raw);
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to restore session: $error');
      }
      await prefs.remove(_prefsKey);
    }
  }

  Future<void> _persistSession(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, profile.toJson());
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (kDebugMode) {
      debugPrint('AuthProvider: Attempting login for email: $email');
      debugPrint('AuthProvider: Firebase online: $_isOnline');
    }

    try {
      UserProfile? profile;

      // Try Firebase first if available
      if (_database != null && _isOnline) {
        try {
          if (kDebugMode) {
            debugPrint('AuthProvider: Checking Firebase for user...');
          }

          final snapshot = await _database.ref('users').get();
          if (snapshot.exists && snapshot.value is Map) {
            final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

            if (kDebugMode) {
              debugPrint(
                'AuthProvider: Found ${data.length} users in Firebase',
              );
            }

            for (final entry in data.entries) {
              final userData = Map<dynamic, dynamic>.from(entry.value);
              final user = UserProfile.fromMap(userData);
              final storedPassword = userData['password']?.toString() ?? '';

              if (kDebugMode) {
                debugPrint('AuthProvider: Checking user: ${user.email}');
              }

              if (user.email.toLowerCase() == email.toLowerCase() &&
                  storedPassword == password) {
                profile = user.copyWith(password: storedPassword);
                if (kDebugMode) {
                  debugPrint(
                    'AuthProvider: Firebase login successful for: ${user.email}',
                  );
                }
                break;
              }
            }
          } else {
            if (kDebugMode) {
              debugPrint('AuthProvider: No users found in Firebase');
            }
          }
        } catch (error) {
          if (kDebugMode) {
            debugPrint('AuthProvider: Firebase login error: $error');
          }
          // Fall back to local data on Firebase error
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            'AuthProvider: Firebase not available, checking local data',
          );
        }
      }

      // Fall back to local data if Firebase not available or user not found
      if (profile == null) {
        if (kDebugMode) {
          debugPrint(
            'AuthProvider: Checking ${_fallbackUsers.length} fallback users',
          );
        }

        for (final user in _fallbackUsers) {
          if (kDebugMode) {
            debugPrint('AuthProvider: Checking fallback user: ${user.email}');
          }

          if (user.email.toLowerCase() == email.toLowerCase() &&
              user.password == password) {
            profile = user;
            if (kDebugMode) {
              debugPrint(
                'AuthProvider: Fallback login successful for: ${user.email}',
              );
            }
            break;
          }
        }
      }

      if (profile == null) {
        _error = 'Email hoặc mật khẩu không đúng.';
        if (kDebugMode) {
          debugPrint('AuthProvider: Login failed - no matching user found');
        }
        return false;
      }

      _currentUser = profile;
      await _persistSession(profile);

      if (kDebugMode) {
        debugPrint(
          'AuthProvider: User logged in successfully: ${profile.email}',
        );
      }

      notifyListeners();
      return true;
    } catch (error) {
      _error = 'Đăng nhập thất bại: $error';
      if (kDebugMode) {
        debugPrint('AuthProvider: Login failed with exception: $error');
      }
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (kDebugMode) {
      debugPrint('AuthProvider: Attempting registration for: $email');
      debugPrint('AuthProvider: Firebase online: $_isOnline');
    }

    try {
      if (email.trim().isEmpty || password.isEmpty || name.trim().isEmpty) {
        _error = 'Vui lòng điền đầy đủ thông tin.';
        return false;
      }

      // Check if landlord already exists
      if (role == UserRole.landlord && await _landlordExists()) {
        _error = 'Đã tồn tại tài khoản chủ trọ.';
        return false;
      }

      // Check if email already exists
      if (await _emailExists(email.trim())) {
        _error = 'Email đã được sử dụng.';
        return false;
      }

      // SỬA ĐOẠN NÀY: Lấy id mới dạng user_00x
      String newUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      if (_database != null && _isOnline) {
        newUserId = await FirebaseService.generateNextUserId();
      }

      final profile = UserProfile(
        id: newUserId,
        email: email.trim().toLowerCase(),
        name: name.trim(),
        role: role,
        roomId: null,
        createdAt: DateTime.now(),
        password: password,
        status: 'active',
      );

      // Try to save to Firebase first
      bool savedToFirebase = false;
      if (_database != null) {
        try {
          if (kDebugMode) {
            debugPrint('AuthProvider: Saving user to Firebase...');
          }

          await _database.ref('users/${profile.id}').set(profile.toMap());
          savedToFirebase = true;

          if (kDebugMode) {
            debugPrint(
              'AuthProvider: User registered to Firebase: ${profile.email}',
            );
          }
        } catch (error) {
          if (kDebugMode) {
            debugPrint('AuthProvider: Failed to save to Firebase: $error');
          }
          // Continue with local storage as fallback
        }
      } else {
        if (kDebugMode) {
          debugPrint('AuthProvider: Firebase not available for registration');
        }
      }

      // Add to local fallback data if not saved to Firebase
      if (!savedToFirebase) {
        _fallbackUsers.add(profile);
        _users = List.from(_fallbackUsers);
        if (kDebugMode) {
          debugPrint('AuthProvider: User registered locally: ${profile.email}');
        }
      }

      _currentUser = profile;
      await _persistSession(profile);
      notifyListeners();
      return true;
    } catch (error) {
      _error = 'Đăng ký thất bại: $error';
      if (kDebugMode) {
        debugPrint('AuthProvider: Registration failed: $error');
      }
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> _landlordExists() async {
    // Check Firebase data first if available
    if (_database != null && _isOnline) {
      try {
        final snapshot = await _database.ref('users').get();
        if (snapshot.exists && snapshot.value is Map) {
          final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
          return data.values.any((value) {
            final role = value['role']?.toString();
            return role == 'landlord';
          });
        }
      } catch (error) {
        if (kDebugMode) {
          debugPrint('AuthProvider: Error checking landlord existence: $error');
        }
      }
    }

    // Fall back to local data
    return _fallbackUsers.any((user) => user.role == UserRole.landlord) ||
        _users.any((user) => user.role == UserRole.landlord);
  }

  Future<bool> _emailExists(String email) async {
    final normalizedEmail = email.toLowerCase();

    // Check Firebase data first if available
    if (_database != null && _isOnline) {
      try {
        final snapshot = await _database.ref('users').get();
        if (snapshot.exists && snapshot.value is Map) {
          final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
          return data.values.any((value) {
            final storedEmail = value['email']?.toString().toLowerCase();
            return storedEmail == normalizedEmail;
          });
        }
      } catch (error) {
        if (kDebugMode) {
          debugPrint('AuthProvider: Error checking email existence: $error');
        }
      }
    }

    // Fall back to local data
    return _fallbackUsers.any(
          (user) => user.email.toLowerCase() == normalizedEmail,
        ) ||
        _users.any((user) => user.email.toLowerCase() == normalizedEmail);
  }

  /// Update user profile
  Future<bool> updateUserProfile(UserProfile updatedProfile) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Update in Firebase if available
      if (_database != null && _isOnline) {
        await _database
            .ref('users/${updatedProfile.id}')
            .update(updatedProfile.toMap());
      }

      // Update local data
      final index = _users.indexWhere((user) => user.id == updatedProfile.id);
      if (index != -1) {
        _users[index] = updatedProfile;
      }

      // Update current user if it's the same user
      if (_currentUser?.id == updatedProfile.id) {
        _currentUser = updatedProfile;
        await _persistSession(updatedProfile);
      }

      notifyListeners();
      return true;
    } catch (error) {
      _error = 'Cập nhật thông tin thất bại: $error';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Get user by ID
  UserProfile? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// Get users by role
  List<UserProfile> getUsersByRole(UserRole role) {
    return _users.where((user) => user.role == role).toList();
  }

  /// Refresh user data from Firebase
  Future<void> refreshUsers() async {
    await _loadAllUsers();
  }

  /// Assign room to user (Landlord only)
  Future<bool> assignRoomToUser(String userId, String? roomId) async {
    if (!isLandlord) {
      _error = 'Chỉ chủ trọ mới có quyền gán phòng.';
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Find the user
      final user = getUserById(userId);
      if (user == null) {
        _error = 'Không tìm thấy người dùng.';
        return false;
      }

      // Update user with new room assignment
      final updatedUser = user.copyWith(roomId: roomId);

      // Save to Firebase if available
      if (_database != null) {
        await _database.ref('users/${updatedUser.id}').update({
          'roomId': roomId,
        });
        if (kDebugMode) {
          debugPrint('AuthProvider: Room assignment saved to Firebase');
        }
      }

      // Update local data
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _users[userIndex] = updatedUser;
      }

      // Update fallback data
      final fallbackIndex = _fallbackUsers.indexWhere((u) => u.id == userId);
      if (fallbackIndex != -1) {
        _fallbackUsers[fallbackIndex] = updatedUser;
      }

      // Update current user if it's the same user
      if (_currentUser?.id == userId) {
        _currentUser = updatedUser;
        await _persistSession(updatedUser);
      }

      if (kDebugMode) {
        debugPrint(
          'AuthProvider: Room ${roomId ?? 'unassigned'} assigned to user ${user.name}',
        );
      }

      // Force refresh all data to ensure consistency
      await refreshUsers();

      // Broadcast the update to all listeners
      notifyListeners();
      return true;
    } catch (error) {
      _error = 'Không thể gán phòng: $error';
      if (kDebugMode) {
        debugPrint('AuthProvider: Room assignment failed: $error');
      }
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Get users by room ID
  List<UserProfile> getUsersByRoom(String roomId) {
    return _users.where((user) => user.roomId == roomId).toList();
  }

  /// Get unassigned users (tenants without rooms)
  List<UserProfile> getUnassignedTenants() {
    return _users
        .where(
          (user) =>
              user.role == UserRole.tenant &&
              (user.roomId == null || user.roomId!.isEmpty),
        )
        .toList();
  }

  /// Get all assigned users (tenants with rooms)
  List<UserProfile> getAssignedTenants() {
    return _users
        .where(
          (user) =>
              user.role == UserRole.tenant &&
              user.roomId != null &&
              user.roomId!.isNotEmpty,
        )
        .toList();
  }

  /// Debug method to check Firebase status and data
  Future<void> debugFirebaseStatus() async {
    if (kDebugMode) {
      debugPrint('=== Firebase Debug Status ===');
      debugPrint(
        'Database instance: ${_database != null ? 'Available' : 'Null'}',
      );
      debugPrint('Is online: $_isOnline');
      debugPrint('Users count: ${_users.length}');
      debugPrint('Fallback users count: ${_fallbackUsers.length}');

      if (_database != null) {
        try {
          final snapshot = await _database.ref('users').get();
          debugPrint('Firebase users exist: ${snapshot.exists}');
          if (snapshot.exists) {
            final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
            debugPrint('Firebase users count: ${data.length}');
            for (final entry in data.entries) {
              final userData = Map<dynamic, dynamic>.from(entry.value);
              debugPrint('User: ${userData['email']} - ${userData['name']}');
            }
          }
        } catch (error) {
          debugPrint('Firebase read error: $error');
        }
      }
      debugPrint('=== End Debug Status ===');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Khôi phục lại 3 user mẫu user_001, user_002, user_003 (rút gọn)
  Future<void> restoreDefaultUsers() async {
    if (_database != null) {
      final usersRef = _database!.ref('users');
      final defaultUsers = [
        {
          'id': 'user_001',
          'email': 'landlord@example.com',
          'name': 'Nguyen Van Chu',
          'role': 'landlord',
          'roomId': null,
        },
        {
          'id': 'user_002',
          'email': 'tenant@example.com',
          'name': 'Nguyen Van A',
          'role': 'tenant',
          'roomId': '101',
        },
        {
          'id': 'user_003',
          'email': 'tenant2@example.com',
          'name': 'Tran Thi B',
          'role': 'tenant',
          'roomId': '102',
        },
      ];
      for (final user in defaultUsers) {
        await usersRef.child(user['id']!).set({
          ...user,
          'password': '123456',
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    }
  }
}
