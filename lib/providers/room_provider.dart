// lib/providers/room_provider.dart

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Cần thiết cho ChangeNotifier
// Đảm bảo bạn đã có AlertProvider ở lib/providers/alert_provider.dart
import 'alert_provider.dart';

import '../models/room.dart';

class RoomProvider extends ChangeNotifier {
  // THAY ĐỔI: Thêm AlertProvider vào constructor để có thể cập nhật cảnh báo
  RoomProvider(this._database, this._alertProvider);

  final FirebaseDatabase? _database;
  final AlertProvider _alertProvider; // Biến lưu trữ AlertProvider

  // (Phần _fallbackRooms giữ nguyên)
  final List<Room> _fallbackRooms = [
    const Room(
      id: '102',
      name: 'Phòng 102',
      status: 'Trống',
      temperature: '24C',
      price: '3.200.000 VND/tháng',
      occupant: null,
      lightOn: false,
      fanOn: false,
      gasLevel: 15,
      gasAlert: false,
      motionDetected: false,
      humidity: 48,
      fanSpeed: 0,
      temperatureValue: 24,
    ),
    const Room(
      id: '103',
      name: 'Phòng 103',
      status: 'Có người',
      temperature: '27C',
      price: '3.800.000 VND/tháng',
      occupant: 'Trần Thị B',
      lightOn: true,
      fanOn: true,
      gasLevel: 30,
      gasAlert: false,
      motionDetected: true,
      humidity: 62,
      fanSpeed: 70,
      temperatureValue: 27,
    ),
    const Room(
      id: '105',
      name: 'Phòng 105',
      status: 'Có người',
      temperature: '26C',
      price: '3.500.000 VND/tháng',
      occupant: 'Phạm Văn C',
      lightOn: true,
      fanOn: false,
      gasLevel: 20,
      gasAlert: false,
      motionDetected: true,
      humidity: 58,
      fanSpeed: 30,
      temperatureValue: 26,
    ),
  ];

  final List<Room> _rooms = [];
  bool _loading = false;
  bool _isOnline = false;
  String? _error;
  StreamSubscription<DatabaseEvent>? _subscription;

  List<Room> get rooms => List.unmodifiable(_rooms);
  bool get isLoading => _loading;
  bool get isOnline => _isOnline;
  String? get errorMessage => _error;

  Future<void> bootstrap() async {
    _rooms.clear();
    if (_database != null) {
      try {
        await _listenRealtime();
        _isOnline = true;
      } catch (error) {
        _isOnline = false;
        _rooms.addAll(_fallbackRooms);
        // CẬP NHẬT ALERTPROVIDER KHI DÙNG FALLBACK DATA
        _updateAlertsFromRooms(_fallbackRooms);

        if (kDebugMode) {
          debugPrint(
            'RoomProvider: Firebase not available, using fallback data: $error',
          );
        }
      }
    } else {
      _isOnline = false;
      _rooms.addAll(_fallbackRooms);
      // CẬP NHẬT ALERTPROVIDER KHI KHÔNG CÓ KẾT NỐI DB
      _updateAlertsFromRooms(_fallbackRooms);
    }
    notifyListeners();
  }

  Future<void> _listenRealtime() async {
    _loading = true;
    notifyListeners();

    try {
      _subscription?.cancel();
      _subscription = _database!.ref('rooms').onValue.listen((event) {
        final List<Room> updated = [];
        final snapshotValue = event.snapshot.value;
        if (snapshotValue is Map) {
          final data = Map<dynamic, dynamic>.from(snapshotValue);
          data.forEach((key, value) {
            if (value is Map) {
              updated.add(
                Room.fromMap(key.toString(), Map<dynamic, dynamic>.from(value)),
              );
            }
          });
        } else if (snapshotValue is List) {
          for (var index = 0; index < snapshotValue.length; index++) {
            final value = snapshotValue[index];
            if (value is Map) {
              final mapValue = Map<dynamic, dynamic>.from(value);
              final itemId = mapValue['id']?.toString() ?? index.toString();
              updated.add(Room.fromMap(itemId, mapValue));
            }
          }
        }
        if (updated.isEmpty) {
          updated.addAll(_fallbackRooms);
        }

        // CHÈN LOGIC KIỂM TRA NGƯỠNG VÀ CẬP NHẬT ALERTPROVIDER NGAY TẠI ĐÂY
        _updateAlertsFromRooms(updated);

        _rooms
          ..clear()
          ..addAll(updated);
        _loading = false;
        notifyListeners();
      });
    } catch (error) {
      _error = 'Không thể kết nối Firebase: $error';
      _rooms
        ..clear()
        ..addAll(_fallbackRooms);
      _loading = false;
      notifyListeners();
    }
  }

  // HÀM XỬ LÝ CẬP NHẬT CẢNH BÁO TỪ DANH SÁCH PHÒNG
  void _updateAlertsFromRooms(List<Room> rooms) {
    final List<String> allAlertMessages = [];
    for (var room in rooms) {
      // Gọi hàm kiểm tra cho từng phòng
      allAlertMessages.addAll(_checkSafetyThresholds(room));
    }
    // GỌI HÀM CỦA ALERTPROVIDER ĐỂ CẬP NHẬT TRẠNG THÁI TOÀN CỤC
    _alertProvider.updateAlerts(allAlertMessages);
  }

  // HÀM LOGIC KIỂM TRA NGƯỠNG SENSOR CỤ THỂ CHO MỘT PHÒNG
  List<String> _checkSafetyThresholds(Room room) {
    List<String> alerts = [];

    if (room.temperatureValue > 35) {
      alerts.add(
        '⚠️ Phòng ${room.name} Nhiệt độ cao (${room.temperatureValue}°C). '
        '» Đề xuất: Mở cửa sổ, bật điều hòa hoặc kiểm tra hệ thống thông gió.',
      );
    }

    if (room.gasLevel > 1500) {
      alerts.add(
        '🚨 KHẨN CẤP! Phòng ${room.name} Khí Gas cao (${room.gasLevel} PPM). '
        '» Đề xuất: Ngay lập tức mở cửa, tắt bếp gas/thiết bị đốt, và liên hệ khẩn cấp!',
      );
    }

    if (room.motionDetected) {
      alerts.add(
        '👤 Phòng ${room.name} Phát hiện chuyển động. '
        '» Đề xuất: Kiểm tra người thuê/camera để xác nhận đây là người quen hoặc truy cập trái phép.',
      );
    }

    if (room.humidity < 30) {
      alerts.add(
        '💧 Phòng ${room.name} Độ ẩm thấp (${room.humidity}%). '
        '» Đề xuất: Sử dụng máy tạo ẩm để tránh khô da và nội thất.',
      );
    } else if (room.humidity > 70) {
      alerts.add(
        '💧 Phòng ${room.name} Độ ẩm cao (${room.humidity}%). '
        '» Đề xuất: Bật quạt thông gió, sử dụng máy hút ẩm để tránh nấm mốc.',
      );
    }

    return alerts;
  }

  Future<Room?> fetchRoom(String id) async {
    try {
      if (_database != null) {
        final snapshot = await _database!.ref('rooms/$id').get();
        if (snapshot.exists) {
          return Room.fromMap(
            id,
            Map<dynamic, dynamic>.from(snapshot.value as Map),
          );
        }
        return null;
      }
      try {
        return _rooms.firstWhere((room) => room.id == id);
      } catch (_) {
        try {
          return _fallbackRooms.firstWhere((room) => room.id == id);
        } catch (_) {
          return null;
        }
      }
    } catch (error) {
      _error = 'Không thể tải phòng: $error';
      notifyListeners();
      return null;
    }
  }

  Future<Room> createRoom(Room room) async {
    try {
      final roomId = _deriveRoomId(room);
      if (_database != null) {
        final ref = _database!.ref("rooms/$roomId");
        final newRoom = room.copyWith(
          id: roomId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref.set(newRoom.toMap());
        return newRoom;
      }

      final newRoom = room.copyWith(
        id: roomId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _rooms.add(newRoom);
      notifyListeners();
      return newRoom;
    } catch (error) {
      _error = 'Không thể tạo phòng: $error';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateRoom(Room room) async {
    try {
      final newId = _deriveRoomId(room);
      final updatedRoom = room.copyWith(id: newId, updatedAt: DateTime.now());

      if (_database != null) {
        final currentRef = _database!.ref('rooms/${room.id}');
        if (newId != room.id) {
          final newRef = _database!.ref('rooms/$newId');
          await newRef.set(updatedRoom.toMap());
          await currentRef.remove();
        } else {
          await currentRef.set(updatedRoom.toMap());
        }
        return;
      }

      final index = _rooms.indexWhere((item) => item.id == room.id);
      if (index != -1) {
        if (newId != room.id) {
          _rooms
            ..removeAt(index)
            ..insert(index, updatedRoom);
        } else {
          _rooms[index] = updatedRoom;
        }
        notifyListeners();
      }
    } catch (error) {
      _error = 'Không thể cập nhật phòng: $error';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteRoom(String id) async {
    try {
      if (_database != null) {
        await _database!.ref('rooms/$id').remove();
        return;
      }
      _rooms.removeWhere((room) => room.id == id);
      notifyListeners();
    } catch (error) {
      _error = 'Không thể xoá phòng: $error';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String _generateRoomId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _deriveRoomId(Room room) {
    // Nếu phòng đã có id thì giữ nguyên id cũ (tránh tạo node Firebase mới)
    if (room.id.isNotEmpty) return room.id;

    // Nếu là phòng mới, tạo id duy nhất (vd: timestamp)
    return _generateRoomId();
  }
}
