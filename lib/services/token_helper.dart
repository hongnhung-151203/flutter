import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';

class TokenHelper {
  static Future<void> saveTokenForUser({
    required String uid,
    required String token,
  }) async {
    try {
      final ref = FirebaseDatabase.instance.ref('deviceTokens/$uid/$token');
      await ref.set(true);
      log("✅ Token saved for $uid");
    } catch (e) {
      log("❌ Save token error: $e");
    }
  }
}