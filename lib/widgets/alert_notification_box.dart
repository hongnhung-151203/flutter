import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/alert_provider.dart';
import '../providers/auth_provider.dart';

class AlertNotificationBox extends StatelessWidget {
  const AlertNotificationBox({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Lắng nghe AlertProvider
    final alertProvider = context.watch<AlertProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const SizedBox.shrink(); // hoặc hiển thị widget khác khi chưa đăng nhập
    }
    final alerts = alertProvider.getAlertsForUser(user);
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }
    // =========================================================

    // 2. Xác định nội dung
    String title = '🔥 CẢNH BÁO KHẨN CẤP (${alerts.length})🔥';
    Color color = const Color.fromARGB(223, 183, 30, 19);

    // 3. Xây dựng giao diện Hộp Thông báo
    return Container(
      constraints: BoxConstraints(
        minHeight: 100,
        maxWidth: 400,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const Divider(color: Colors.white70, height: 12),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: alerts.map((alert) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        children: _highlightRoomName(alert.message),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton(
              onPressed: () {
                alertProvider.acknowledgeAlertsForUser(user.id);
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

  // ✅ Hàm tô đậm và làm nổi chữ "Phòng ..."
  List<TextSpan> _highlightRoomName(String message) {
    final regex = RegExp(r'(Phòng\s+\d+)');
    final matches = regex.allMatches(message);

    if (matches.isEmpty) {
      return [TextSpan(text: message)];
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: message.substring(lastIndex, match.start)));
      }

      spans.add(
        TextSpan(
          text: message.substring(match.start, match.end),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.yellowAccent, // 🌟 Làm nổi bật chữ “Phòng …”
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < message.length) {
      spans.add(TextSpan(text: message.substring(lastIndex)));
    }

    return spans;
  }
}
