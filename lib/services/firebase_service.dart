import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Handles Firebase initialization and exposes shared instances.
class FirebaseService {
  FirebaseService._();

  static FirebaseApp? _app;
  static FirebaseDatabase? _database;
  static bool _initialised = false;

  static bool get isReady => _initialised && _database != null;
  static FirebaseDatabase? get database => _database;

  /// Attempt to initialise Firebase; falls back silently when configuration is
  /// missing so the rest of the app can continue with local demo data.
  static Future<void> initialise() async {
    if (_initialised) return;
    try {
      _app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final databaseURL = DefaultFirebaseOptions.currentPlatform.databaseURL;
      _database = FirebaseDatabase.instanceFor(
        app: _app!,
        databaseURL: databaseURL,
      );
      _initialised = true;
      log('Firebase initialised with database: $databaseURL');
    } catch (error, stackTrace) {
      _initialised = false;
      _database = null;
      if (kDebugMode) {
        log('Firebase initialisation skipped: $error', stackTrace: stackTrace);
      }
    }
  }

  /// Tạo userId dạng user_001, user_002, ...
  static Future<String> generateNextUserId() async {
    final ref = _database!.ref('users');
    final snapshot = await ref.get();
    int maxIndex = 0;
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      for (var key in data.keys) {
        final match = RegExp(r'user_(\d{3})').firstMatch(key.toString());
        if (match != null) {
          final num = int.tryParse(match.group(1)!);
          if (num != null && num > maxIndex) maxIndex = num;
        }
      }
    }
    final nextIndex = maxIndex + 1;
    return 'user_${nextIndex.toString().padLeft(3, '0')}';
  }

  /// Đổi tất cả user id cũ sang dạng user_00x (tăng dần theo thứ tự)
  static Future<void> migrateUserIds() async {
    final ref = _database!.ref('users');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      int index = 1;
      for (var oldKey in data.keys) {
        final newKey = 'user_${index.toString().padLeft(3, '0')}';
        await ref.child(newKey).set(data[oldKey]);
        await ref.child(oldKey).remove();
        index++;
      }
    }
  }
}
