// lib/widgets/alert_notification_box.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';

class AlertNotificationBox extends StatelessWidget {
  const AlertNotificationBox({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Lắng nghe AlertProvider
    final alertProvider = context.watch<AlertProvider>();
    final alerts = alertProvider.currentAlerts;

    // Sử dụng getter đã sửa: Chỉ hiển thị nếu có cảnh báo VÀ chưa được xác nhận.
    final bool shouldDisplay = alertProvider.hasUnacknowledgedAlerts;

    // =========================================================
    // LOGIC QUAN TRỌNG: ẨN KHI KHÔNG CÓ CẢNH BÁO CHƯA XÁC NHẬN
    if (!shouldDisplay) {
      return const SizedBox.shrink();
    }
    // =========================================================

    // 2. Xác định nội dung
    String title = '🚨 CẢNH BÁO KHẨN CẤP (${alerts.length})';
    Color color = Colors.red.shade700;

    // 3. Xây dựng giao diện Hộp Thông báo
    return Container(
      // ✅ THAY ĐỔI 1: KHÔNG DÙNG width cố định. Dùng BoxConstraints để giới hạn.
      constraints: BoxConstraints(
        minHeight: 100,
        maxWidth: 400, // Chiều rộng tối đa (giới hạn trên để không quá to)
        maxHeight:
            MediaQuery.of(context).size.height *
            0.8, // Chiều cao tối đa là 80% màn hình
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // ✅ THAY ĐỔI 2: Dùng MainAxisSize.min để Column chỉ chiếm không gian cần thiết
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Divider(color: Colors.white70, height: 12), // Đường phân cách
          // ✅ THAY ĐỔI 3: Dùng ListView.builder hoặc SingleChildScrollView cho danh sách cảnh báo
          Flexible(
            // Dùng SingleChildScrollView để tự cuộn khi nhiều cảnh báo vượt quá maxHeight
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: alerts.map((alert) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '${alert.message}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // =========================================================

          // Nút xác nhận
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton(
              onPressed: () {
                // Đánh dấu đã xác nhận (không xóa _currentAlerts)
                alertProvider.clearAlerts();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xác nhận và đóng cảnh báo!'),
                  ),
                );
              },
              child: const Text(
                'XÁC NHẬN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
