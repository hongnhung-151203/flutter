import 'package:flutter/foundation.dart';
import 'services/firebase_service.dart';

/// Simple debug function to test Firebase connection
Future<void> debugFirebase() async {
  if (!kDebugMode) return;

  debugPrint('=== FIREBASE DEBUG START ===');

  try {
    // Check if Firebase is initialized
    debugPrint('FirebaseService.isReady: ${FirebaseService.isReady}');
    debugPrint('FirebaseService.database: ${FirebaseService.database != null}');

    final database = FirebaseService.database;
    if (database == null) {
      debugPrint('ERROR: Firebase database is null');
      return;
    }

    // Test connection
    debugPrint('Testing Firebase connection...');
    final snapshot = await database.ref('users').get();
    debugPrint('Connection successful! Data exists: ${snapshot.exists}');

    if (snapshot.exists) {
      debugPrint('Raw data: ${snapshot.value}');

      if (snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        debugPrint('Users found: ${data.length}');

        for (final entry in data.entries) {
          final userData = Map<dynamic, dynamic>.from(entry.value);
          debugPrint('User ID: ${entry.key}');
          debugPrint('  Email: ${userData['email']}');
          debugPrint('  Name: ${userData['name']}');
          debugPrint('  Role: ${userData['role']}');
          debugPrint('  Password: ${userData['password']}');
        }
      }
    } else {
      debugPrint('No users data found in Firebase');
    }

    // Test write
    debugPrint('Testing Firebase write...');
    await database.ref('test/timestamp').set(DateTime.now().toIso8601String());
    debugPrint('Write test successful!');
  } catch (error, stackTrace) {
    debugPrint('Firebase error: $error');
    debugPrint('Stack trace: $stackTrace');
  }

  debugPrint('=== FIREBASE DEBUG END ===');
}
