import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user_profile.dart';

// === MODEL CẢNH BÁO ===
class AlertInfo {
  final String roomId;
  final String message;
  final DateTime timestamp;

  AlertInfo({required this.roomId, required this.message})
      : timestamp = DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertInfo &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          roomId == other.roomId;

  @override
  int get hashCode => message.hashCode ^ roomId.hashCode;
}

// === PROVIDER QUẢN LÝ CẢNH BÁO ===
class AlertProvider extends ChangeNotifier {
  List<AlertInfo> _currentAlerts = [];

  // Thời gian chờ để hiển thị lại cảnh báo
  final Duration _reAlertDelay = const Duration(seconds: 30);

  // Lưu lại thời điểm user xác nhận cảnh báo
  final Map<String, DateTime> _userAcknowledgements = {};

  int _currentAlertMessagesHash = 0;

  List<AlertInfo> get currentAlerts => _currentAlerts;

  // ===============================================================
  // CẬP NHẬT DỮ LIỆU CẢNH BÁO (TỪ ROOM PROVIDER)
  // ===============================================================
  void updateAlerts(List<Map<String, String>> newAlertsData) {
    final newAlertMessages =
        newAlertsData.map((e) => e['message'] ?? '').toList();
    final int newAlertsHash = newAlertMessages.fold(
      0,
      (hash, message) => hash ^ message.hashCode,
    );

    if (newAlertsHash != _currentAlertMessagesHash) {
      _currentAlertMessagesHash = newAlertsHash;

      if (newAlertsData.isNotEmpty) {
        List<AlertInfo> updatedList = [];

        for (var alert in newAlertsData) {
          final message = alert['message'] ?? '';
          final roomId = alert['roomId'] ?? '';

          final existingAlert = _currentAlerts.cast<AlertInfo?>().firstWhere(
            (a) => a != null && a.message == message && a.roomId == roomId,
            orElse: () => null,
          );

          if (existingAlert != null) {
            updatedList.add(existingAlert);
          } else {
            updatedList.add(AlertInfo(roomId: roomId, message: message));
          }
        }

        _currentAlerts = updatedList;
      } else {
        _currentAlerts = [];
      }

      notifyListeners();
    }
  }

  // ===============================================================
  // XÁC NHẬN CẢNH BÁO RIÊNG THEO NGƯỜI DÙNG
  // ===============================================================
  void acknowledgeAlertsForUser(String userId) {
    _userAcknowledgements[userId] = DateTime.now();
    notifyListeners();

    // Sau 30 giây, cảnh báo tự động hiện lại cho user đó
    Timer(_reAlertDelay, () {
      _userAcknowledgements.remove(userId);
      notifyListeners();
    });
  }

  // ===============================================================
  // KIỂM TRA USER NÀY CÓ NÊN THẤY CẢNH BÁO KHÔNG
  // ===============================================================
  bool shouldShowAlertsForUser(String userId) {
    if (!_userAcknowledgements.containsKey(userId)) return true;
    final elapsed = DateTime.now().difference(_userAcknowledgements[userId]!);
    return elapsed > _reAlertDelay;
  }

  // ===============================================================
  // LỌC CẢNH BÁO THEO QUYỀN CỦA USER
  // ===============================================================
  List<AlertInfo> getAlertsForUser(UserProfile user) {
    List<AlertInfo> alerts;

    if (user.role == UserRole.landlord) {
      alerts = _currentAlerts;
    } else {
      alerts = _currentAlerts
          .where((alert) => alert.roomId == user.roomId)
          .toList();
    }

    // Nếu user vừa xác nhận trong vòng 30s thì ẩn cảnh báo của họ
    if (!shouldShowAlertsForUser(user.id)) {
      return [];
    }

    return alerts;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
