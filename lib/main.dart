import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // thêm để FCM hoạt động

import 'debug_firebase.dart';
import 'providers/auth_provider.dart';
import 'providers/room_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/firebase_test/firebase_test_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/room_detail/room_detail_screen.dart';
import 'screens/test_auth_screen.dart';
import 'screens/user_management/user_management_screen.dart';
import 'services/firebase_service.dart';
import 'services/fcm_service.dart'; // ✅ thêm dòng này

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialise();

  // Nếu muốn khôi phục user mẫu, giữ dòng này. Nếu không cần, hãy xóa/comment lại.
  // await FirebaseService.migrateUserIds(); // XÓA dòng này nếu đã chuyển đổi id cũ rồi
  // await authProvider.restoreDefaultUsers(); // XÓA hoặc COMMENT dòng này sau khi đã khôi phục user mẫu

  await debugFirebase();

  final authProvider = AuthProvider(FirebaseService.database);
  await authProvider.bootstrap();

  final roomProvider = RoomProvider(FirebaseService.database);
  await roomProvider.bootstrap();

  // =======================
  // ✅ Thêm đoạn này vào đây, ngay sau khi khởi tạo authProvider và roomProvider
  // Khởi tạo FCM, lấy token và cập nhật token lên user profile trong DB
  final token = await FCMService.initFCM(
    vapidKey:
        "BCLIBwAryx2xBb90NNWGZer1z2yorahY5NDFGjP5vy-5AIlsyerLKbjeFFuvs6OXS6bStxNDNMXyndV1g4ASzZc",
  );

  // Cập nhật token FCM cho user đang đăng nhập
  if (token != null && authProvider.currentUser != null) {
    final updatedUser = authProvider.currentUser!.copyWith(fcmToken: token);
    await authProvider.updateUserProfile(updatedUser);
  }
  // =======================

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<RoomProvider>.value(value: roomProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý nhà trọ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == null) {
          return MaterialPageRoute(builder: (_) => const AuthScreen());
        }

        if (settings.name!.startsWith('/room/')) {
          final roomId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (_) => RoomDetailScreen(roomId: roomId),
            settings: settings,
          );
        }

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const RootDecider());
          case '/login':
            return MaterialPageRoute(builder: (_) => const AuthScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/room':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/management_users':
            return MaterialPageRoute(
              builder: (_) => const UserManagementScreen(),
            );
          case '/firebase-test':
            return MaterialPageRoute(
              builder: (_) => const FirebaseTestScreen(),
            );
          case '/test-auth':
            return MaterialPageRoute(builder: (_) => const TestAuthScreen());
          default:
            return MaterialPageRoute(builder: (_) => const AuthScreen());
        }
      },
    );
  }
}

class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isAuthenticated) {
      return const HomeScreen();
    }
    return const AuthScreen();
  }
}
