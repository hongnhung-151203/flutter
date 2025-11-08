import 'dart:convert';

enum UserRole { landlord, tenant }

UserRole parseUserRole(String? raw) {
  if (raw == null) return UserRole.tenant;
  return raw == 'landlord' ? UserRole.landlord : UserRole.tenant;
}

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.landlord:
        return 'landlord';
      case UserRole.tenant:
        return 'tenant';
    }
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.roomId,
    this.status = 'active',
    this.createdAt,
    this.password,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? roomId;
  final String status;
  final DateTime? createdAt;
  final String? password;

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'email': email,
      'name': name,
      'role': role.value,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'password': password,
    };

    if (roomId != null && roomId!.isNotEmpty) {
      map['roomId'] = roomId;
    }

    return map;
  }

  factory UserProfile.fromMap(Map<dynamic, dynamic> data) {
    DateTime? parseDate(dynamic value) {
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    final id = data['id']?.toString() ??
        data['uid']?.toString() ??
        'user-${DateTime.now().millisecondsSinceEpoch}';

    return UserProfile(
      id: id,
      email: data['email']?.toString() ?? '',
      name: data['name']?.toString() ?? 'User',
      role: parseUserRole(data['role']?.toString()),
      roomId: data['roomId']?.toString(),
      status: data['status']?.toString() ?? 'active',
      createdAt: parseDate(data['createdAt']),
      password: data['password']?.toString(),
    );
  }

  factory UserProfile.fromJson(String source) {
    return UserProfile.fromMap(
      Map<String, dynamic>.from(jsonDecode(source) as Map),
    );
  }

  String toJson() => jsonEncode(toMap());

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? roomId,
    String? status,
    DateTime? createdAt,
    String? password,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      roomId: roomId ?? this.roomId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      password: password ?? this.password,
    );
  }
}
