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
}
