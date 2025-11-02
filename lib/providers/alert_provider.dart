import 'package:flutter/material.dart';
import 'dart:async'; // Cần import này cho Timer!

// Định nghĩa một lớp cho thông tin cảnh báo
class AlertInfo {
  final String message;
  final DateTime timestamp;

  // Constructor khởi tạo timestamp khi cảnh báo được tạo
  AlertInfo({required this.message}) : timestamp = DateTime.now();

  // Dùng để so sánh xem hai AlertInfo có giống nhau không (dựa trên message)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertInfo &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

// Provider quản lý trạng thái cảnh báo chung
class AlertProvider extends ChangeNotifier {
  // Danh sách các cảnh báo hiện tại (chứa cảnh báo, bất kể đã xác nhận hay chưa)
  List<AlertInfo> _currentAlerts = [];

  // === CÁC THUỘC TÍNH MỚI CHO LOGIC TÁI CẢNH BÁO ===
  final Duration _reAlertDelay = const Duration(seconds: 100);
  Timer? _reAlertTimer; // Timer để kích hoạt tái cảnh báo

  // Theo dõi xem người dùng đã xác nhận cảnh báo hiện tại chưa
  bool _isAcknowledged = false;

  // Mã hash của tập hợp các tin nhắn cảnh báo hiện tại.
  int _currentAlertMessagesHash = 0;
  // =================================================

  List<AlertInfo> get currentAlerts => _currentAlerts;

  // Getter cho UI. Chỉ trả về TRUE nếu có cảnh báo VÀ CHƯA được xác nhận.
  bool get hasUnacknowledgedAlerts =>
      _currentAlerts.isNotEmpty && !_isAcknowledged;

  // Giữ lại getter cũ cho các logic khác
  bool get hasAlerts => _currentAlerts.isNotEmpty;

  // Hàm quản lý Timer: Bắt đầu đếm ngược 5 giây
  void _startReAlertTimer() {
    // Hủy Timer cũ nếu có
    _reAlertTimer?.cancel();
    _reAlertTimer = null;

    if (_currentAlerts.isNotEmpty && _isAcknowledged) {
      // Chỉ bắt đầu hẹn giờ nếu đang trong trạng thái nguy hiểm và đã được xác nhận
      _reAlertTimer = Timer(_reAlertDelay, () {
        // Sau 5 giây, kiểm tra lại: Nếu nguy hiểm vẫn còn và vẫn đang ở trạng thái xác nhận
        if (_currentAlerts.isNotEmpty && _isAcknowledged) {
          _isAcknowledged = false; // Reset trạng thái xác nhận (tái cảnh báo)
          _reAlertTimer = null;
          notifyListeners(); // Kích hoạt UI hiện lại
        }
      });
    }
  }

  // Hàm quan trọng: Cập nhật danh sách cảnh báo (được gọi từ nơi nhận dữ liệu sensor)
  void updateAlerts(List<String> newAlertMessages) {
    final int newAlertsHash = newAlertMessages.fold(
      0,
      (hash, message) => hash ^ message.hashCode,
    );

    if (newAlertsHash != _currentAlertMessagesHash) {
      _currentAlertMessagesHash = newAlertsHash;

      if (newAlertMessages.isNotEmpty) {
        // NGUY HIỂM XUẤT HIỆN/THAY ĐỔI
        List<AlertInfo> updatedList = [];

        for (var message in newAlertMessages) {
          final existingAlert = _currentAlerts.cast<AlertInfo?>().firstWhere(
            (a) => a != null && a.message == message,
            orElse: () => null,
          );

          if (existingAlert != null) {
            updatedList.add(existingAlert);
          } else {
            updatedList.add(AlertInfo(message: message));
          }
        }

        _currentAlerts = updatedList;
        // Quan trọng: RESET trạng thái xác nhận vì đây là một tình trạng nguy hiểm MỚI
        _isAcknowledged = false;
        _reAlertTimer?.cancel(); // Hủy Timer nếu có cảnh báo mới/khác biệt
      } else {
        // NGUY HIỂM ĐÃ HOÀN TOÀN BIẾN MẤT
        _currentAlerts = [];
        _isAcknowledged = false; // Reset
        _reAlertTimer?.cancel(); // Hủy Timer
      }

      notifyListeners();
    }
    // Nếu hash KHÔNG thay đổi và alerts vẫn active, Timer sẽ lo việc tái cảnh báo.
  }

  // Hàm xóa tất cả cảnh báo (khi người dùng nhấn nút)
  void clearAlerts() {
    if (_currentAlerts.isNotEmpty) {
      // Đánh dấu cảnh báo hiện tại là đã được xác nhận (Acknowledged).
      _isAcknowledged = true;
      _startReAlertTimer(); // Bắt đầu đếm ngược 5 giây
      notifyListeners();
    }
  }

  // Quan trọng: Hủy Timer khi Provider bị loại bỏ để tránh rò rỉ bộ nhớ
  @override
  void dispose() {
    _reAlertTimer?.cancel();
    super.dispose();
  }
}
