import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<String?> initFCM({required String vapidKey}) async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      log('🔔 Notification permission: ${settings.authorizationStatus}');

      String? token = await _messaging.getToken(vapidKey: vapidKey);
      log('✅ FCM Token: $token');

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        log('🔄 Token refreshed: $newToken');
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('📩 onMessage: ${message.notification?.title} - ${message.notification?.body}');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log('➡️ onMessageOpenedApp: ${message.notification?.title}');
      });

      return token;
    } catch (e) {
      log('❌ FCM init error: $e');
      return null;
    }
  }
}
