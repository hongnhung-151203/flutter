import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Placeholder Firebase options. Replace the values with your own project data
/// (or run `flutterfire configure`) before enabling the realtime connection.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDXCwnaUFM_pAT6uVAGkP0Demz-3J-n5qs',
    appId: '1:730556087229:web:34ab2aaa7810a98680f0d4',
    messagingSenderId: '730556087229',
    projectId: 'iot-smart-5700d',
    authDomain: 'iot-smart-5700d.firebaseapp.com',
    databaseURL: 'https://iot-smart-5700d-default-rtdb.firebaseio.com',
    storageBucket: 'iot-smart-5700d.firebasestorage.app',
    measurementId: 'G-TFTBZM86CW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAB-VTmpiUuTB20xGXgbkombrWGhpTPe7w',
    appId: '1:730556087229:android:34143b0dedd5a7c480f0d4',
    messagingSenderId: '730556087229',
    projectId: 'iot-smart-5700d',
    databaseURL: 'https://iot-smart-5700d-default-rtdb.firebaseio.com',
    storageBucket: 'iot-smart-5700d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVZUQkfl4DiiY5DBGTZnvzcROValNSNGk',
    appId: '1:730556087229:ios:091f441cd438eedf80f0d4',
    messagingSenderId: '730556087229',
    projectId: 'iot-smart-5700d',
    databaseURL: 'https://iot-smart-5700d-default-rtdb.firebaseio.com',
    storageBucket: 'iot-smart-5700d.firebasestorage.app',
    iosBundleId: 'com.example.iotSmartFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDVZUQkfl4DiiY5DBGTZnvzcROValNSNGk',
    appId: '1:730556087229:ios:091f441cd438eedf80f0d4',
    messagingSenderId: '730556087229',
    projectId: 'iot-smart-5700d',
    databaseURL: 'https://iot-smart-5700d-default-rtdb.firebaseio.com',
    storageBucket: 'iot-smart-5700d.firebasestorage.app',
    iosBundleId: 'com.example.iotSmartFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDXCwnaUFM_pAT6uVAGkP0Demz-3J-n5qs',
    appId: '1:730556087229:web:8f9c191f1f8623f680f0d4',
    messagingSenderId: '730556087229',
    projectId: 'iot-smart-5700d',
    authDomain: 'iot-smart-5700d.firebaseapp.com',
    databaseURL: 'https://iot-smart-5700d-default-rtdb.firebaseio.com',
    storageBucket: 'iot-smart-5700d.firebasestorage.app',
    measurementId: 'G-S1L1D9GPTC',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'YOUR_LINUX_API_KEY',
    appId: 'YOUR_LINUX_APP_ID',
    messagingSenderId: 'YOUR_LINUX_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    databaseURL: 'https://your-project-id-default-rtdb.firebaseio.com',
    storageBucket: 'your-project-id.appspot.com',
  );
}