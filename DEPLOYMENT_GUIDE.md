# 🚀 IoT Smart Flutter - Hướng dẫn Triển khai (Deployment Guide)

> **Tài liệu hướng dẫn chi tiết cho việc triển khai và cấu hình hệ thống IoT Smart Flutter**

---

## 📋 **Mục lục**

1. [🎯 Tổng quan triển khai](#-tổng-quan-triển-khai)
2. [📋 Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
3. [🔧 Cấu hình Firebase](#-cấu-hình-firebase)
4. [🔐 Thiết lập phân quyền](#-thiết-lập-phân-quyền)
5. [🗄️ Kết nối cơ sở dữ liệu](#️-kết-nối-cơ-sở-dữ-liệu)
6. [📁 Giải thích các file quan trọng](#-giải-thích-các-file-quan-trọng)
7. [🌐 Triển khai Web](#-triển-khai-web)
8. [📱 Triển khai Mobile](#-triển-khai-mobile)
9. [⚙️ Cấu hình môi trường](#️-cấu-hình-môi-trường)
10. [🐛 Troubleshooting](#-troubleshooting)

---

## 🎯 **Tổng quan triển khai**

### **Kiến trúc Deploy**
```
Development → Testing → Production
     │           │           │
     │           │           ├─ Web (Firebase Hosting)
     │           │           ├─ Android (Google Play)
     │           │           └─ iOS (App Store)
     │           │
     │           └─ Staging Environment
     │
     └─ Local Development
```

### **Môi trường triển khai**
- **Development**: Local development server
- **Staging**: Testing environment trên Firebase
- **Production**: Live application cho users

---

## 📋 **Yêu cầu hệ thống**

### **Development Environment**
```bash
# Flutter SDK
Flutter 3.32.x hoặc mới hơn
Dart 3.5.x hoặc mới hơn

# IDE (chọn 1)
- Android Studio 2024.x
- Visual Studio Code với Flutter Extension
- IntelliJ IDEA với Dart/Flutter Plugin

# Platform Tools
- Android SDK (cho Android build)
- Xcode (cho iOS build - chỉ trên macOS)
- Chrome (cho Web development)
```

### **Server Requirements**
```bash
# Firebase Project
- Firebase Realtime Database
- Firebase Authentication (optional)
- Firebase Hosting (cho Web deployment)
- Firebase Storage (cho file uploads)

# Domain & SSL
- Custom domain (tùy chọn)
- SSL Certificate (Firebase tự động cung cấp)
```

---

## 🔧 **Cấu hình Firebase**

### **1. Tạo Firebase Project**
```bash
# Truy cập Firebase Console
https://console.firebase.google.com

# Tạo project mới
1. Click "Add project"
2. Nhập tên project: "iot-smart-boarding-house"
3. Chọn region: asia-southeast1 (Singapore)
4. Bật Google Analytics (tùy chọn)
```

### **2. Cài đặt Firebase CLI**
```bash
# Cài đặt Firebase CLI
npm install -g firebase-tools

# Đăng nhập Firebase
firebase login

# Khởi tạo project
firebase init
```

### **3. Cấu hình Realtime Database**
```json
// Database Rules (firebase-rules.json)
{
  "rules": {
    ".read": false,
    ".write": false,
    
    "users": {
      ".read": "auth != null",
      ".write": "auth != null",
      "$uid": {
        ".read": "auth.uid == $uid || root.child('users').child(auth.uid).child('role').val() == 'landlord'",
        ".write": "auth.uid == $uid || root.child('users').child(auth.uid).child('role').val() == 'landlord'"
      }
    },
    
    "rooms": {
      ".read": "auth != null",
      ".write": "root.child('users').child(auth.uid).child('role').val() == 'landlord'",
      "$roomId": {
        ".read": "auth != null && (root.child('users').child(auth.uid).child('role').val() == 'landlord' || root.child('users').child(auth.uid).child('roomId').val() == $roomId)"
      }
    }
  }
}
```

### **4. Database Structure**
```json
{
  "users": {
    "user1": {
      "id": "user1",
      "name": "Nguyễn Văn A",
      "email": "landlord@example.com",
      "role": "landlord",
      "roomId": null,
      "createdAt": "2025-09-24T00:00:00Z"
    },
    "user2": {
      "id": "user2", 
      "name": "Trần Thị B",
      "email": "tenant@example.com",
      "role": "tenant",
      "roomId": "102",
      "createdAt": "2025-09-24T00:00:00Z"
    }
  },
  
  "rooms": {
    "102": {
      "id": "102",
      "name": "102",
      "status": "Có người",
      "occupant": "Trần Thị B",
      "price": "2000000 VND",
      "temperature": "24C",
      "temperatureValue": 24,
      "gasLevel": 15,
      "humidity": 65,
      "lightOn": true,
      "fanOn": false,
      "fanSpeed": 0,
      "gasAlert": false,
      "motionDetected": true,
      "createdAt": "2025-09-24T00:00:00Z",
      "updatedAt": "2025-09-24T10:30:00Z"
    },
    "103": {
      "id": "103",
      "name": "103", 
      "status": "Trống",
      "occupant": null,
      "price": "1800000 VND",
      "temperature": "25C",
      "temperatureValue": 25,
      "gasLevel": 10,
      "humidity": 60,
      "lightOn": false,
      "fanOn": false,
      "fanSpeed": 0,
      "gasAlert": false,
      "motionDetected": false,
      "createdAt": "2025-09-24T00:00:00Z",
      "updatedAt": "2025-09-24T10:30:00Z"
    },
    "105": {
      "id": "105",
      "name": "105",
      "status": "Bảo trì", 
      "occupant": null,
      "price": "2200000 VND",
      "temperature": "23C",
      "temperatureValue": 23,
      "gasLevel": 5,
      "humidity": 70,
      "lightOn": false,
      "fanOn": true,
      "fanSpeed": 60,
      "gasAlert": false,
      "motionDetected": false,
      "createdAt": "2025-09-24T00:00:00Z",
      "updatedAt": "2025-09-24T10:30:00Z"
    }
  }
}
```

---

## 🔐 **Thiết lập phân quyền**

### **1. Role-based Access Control**
```dart
// lib/models/user_profile.dart
enum UserRole {
  landlord,  // Chủ trọ - full access
  tenant     // Người thuê - restricted access
}

class UserProfile {
  final String id;
  final String name; 
  final String email;
  final UserRole role;
  final String? roomId;  // null cho landlord, roomId cho tenant
}
```

### **2. Permission Matrix**
```
┌─────────────────┬──────────┬────────┐
│     Feature     │ Landlord │ Tenant │
├─────────────────┼──────────┼────────┤
│ View all rooms  │    ✅    │   ❌   │
│ Create room     │    ✅    │   ❌   │
│ Edit room       │    ✅    │   ❌   │
│ Delete room     │    ✅    │   ❌   │
│ View own room   │    ✅    │   ✅   │
│ Control devices │    ✅    │   ✅   │
│ User management │    ✅    │   ❌   │
│ Firebase test   │    ✅    │   ❌   │
└─────────────────┴──────────┴────────┘
```

### **3. Access Control Implementation**
```dart
// lib/providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  bool get isLandlord => _currentUser?.role == UserRole.landlord;
  bool get isTenant => _currentUser?.role == UserRole.tenant;
  
  bool canAccessRoom(String roomId) {
    if (isLandlord) return true;
    if (isTenant) return _currentUser?.roomId == roomId;
    return false;
  }
  
  bool canManageUsers() => isLandlord;
  bool canCreateRoom() => isLandlord;
  bool canDeleteRoom() => isLandlord;
}
```

---

## 🗄️ **Kết nối cơ sở dữ liệu**

### **1. Firebase Configuration Files**
```dart
// lib/firebase_options.dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
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
        return web;
    }
  }

  // Web Configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    authDomain: 'iot-smart-5700d.firebaseapp.com',
    databaseURL: 'https://iot-smart-5700d-default-rtdb.firebaseio.com',
    projectId: 'iot-smart-5700d',
    storageBucket: 'iot-smart-5700d.firebasestorage.app',
    messagingSenderId: '123456789',
    appId: '1:123456789:web:abcdefghijklmnop',
  );

  // Android Configuration  
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:123456789:android:abcdefghijklmnop',
    messagingSenderId: '123456789',
    projectId: 'iot-smart-5700d',
    databaseURL: 'https://iot-smart-5700d-default-rtdb.firebaseio.com',
    storageBucket: 'iot-smart-5700d.firebasestorage.app',
  );
}
```

### **2. Database Service**
```dart
// lib/services/firebase_service.dart
class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  // Connection test
  static Future<bool> testConnection() async {
    try {
      await _database.child('.info/connected').once();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Real-time listeners
  static Stream<DatabaseEvent> getRoomsStream() {
    return _database.child('rooms').onValue;
  }
  
  static Stream<DatabaseEvent> getUsersStream() {
    return _database.child('users').onValue;
  }
}
```

### **3. Offline Support**
```dart
// lib/providers/room_provider.dart
class RoomProvider extends ChangeNotifier {
  List<Room> _rooms = [];
  List<Room> _fallbackRooms = [
    // Fallback data for offline mode
    Room(
      id: '102',
      name: '102',
      status: 'Có người',
      temperature: '24C',
      temperatureValue: 24,
      gasLevel: 15,
      humidity: 65,
      lightOn: true,
      fanOn: false,
      // ... other properties
    ),
    // ... more fallback rooms
  ];
  
  Future<void> bootstrap() async {
    if (await FirebaseService.testConnection()) {
      await syncWithFirebase();
    } else {
      _rooms = _fallbackRooms;
      notifyListeners();
    }
  }
}
```

---

## 📁 **Giải thích các file quan trọng**

### **1. Core Application Files**

#### **main.dart**
```dart
// Entry point của ứng dụng
// Chức năng:
// - Khởi tạo Firebase
// - Cấu hình Provider state management  
// - Định nghĩa routing
// - Thiết lập theme và MaterialApp

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

#### **firebase_options.dart**  
```dart
// Cấu hình Firebase cho tất cả platforms
// Chứa:
// - API keys
// - Project ID  
// - Database URL
// - Storage bucket
// - App IDs cho từng platform
```

#### **debug_firebase.dart**
```dart
// File debug và development utilities
// Chức năng:
// - Test Firebase connection
// - Debug database operations
// - Development-only features
// - Logging và error tracking
```

### **2. Data Layer Files**

#### **models/user_profile.dart**
```dart
// Data model cho User
class UserProfile {
  final String id;           // Unique identifier
  final String name;         // Display name
  final String email;        // Login email
  final UserRole role;       // landlord | tenant
  final String? roomId;      // Assigned room (null for landlord)
  final DateTime? createdAt; // Account creation time
  
  // Serialization methods
  Map<String, dynamic> toMap() { ... }
  factory UserProfile.fromMap(Map<String, dynamic> map) { ... }
}
```

#### **models/room.dart**
```dart
// Data model cho Room với IoT sensors
class Room {
  final String id;                    // Room identifier
  final String name;                  // Display name
  final String status;                // Trống | Có người | Bảo trì
  final String? occupant;             // Current tenant name
  final String? price;                // Monthly rent
  
  // IoT Sensor Data
  final String temperature;           // "24C"
  final int temperatureValue;         // 24 (for calculations)
  final int gasLevel;                 // 0-100%
  final int humidity;                 // 0-100%
  final bool lightOn;                 // Device control
  final bool fanOn;                   // Device control
  final int fanSpeed;                 // 0-100%
  final bool gasAlert;                // Alert when gas > 80%
  final bool motionDetected;          // PIR sensor
  
  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Helper methods
  bool get isGasAlertActive => gasLevel > 80;
  String get temperatureStatus { ... }
  String get humidityStatus { ... }
}
```

### **3. Business Logic Files**

#### **providers/auth_provider.dart**
```dart
// Quản lý authentication và user state
class AuthProvider extends ChangeNotifier {
  UserProfile? _currentUser;
  List<UserProfile> _users = [];
  
  // Authentication methods
  Future<bool> login({String email, String password}) { ... }
  Future<bool> register({String email, String password, String name, UserRole role}) { ... }
  Future<void> logout() { ... }
  
  // User management
  Future<void> refreshUsers() { ... }
  Future<void> assignRoomToUser(String userId, String? roomId) { ... }
  
  // Permission checks
  bool get isLandlord => _currentUser?.role == UserRole.landlord;
  bool get isTenant => _currentUser?.role == UserRole.tenant;
  bool canAccessRoom(String roomId) { ... }
}
```

#### **providers/room_provider.dart**
```dart
// Quản lý room data và IoT synchronization
class RoomProvider extends ChangeNotifier {
  List<Room> _rooms = [];
  bool _isLoading = false;
  
  // Data management
  Future<void> bootstrap() { ... }
  Future<void> syncWithFirebase() { ... }
  
  // CRUD operations
  Future<void> createRoom(Room room) { ... }
  Future<void> updateRoom(Room room) { ... }
  Future<void> deleteRoom(String roomId) { ... }
  
  // Real-time updates
  void _listenToFirebaseChanges() { ... }
  
  // Filtering methods
  List<Room> get availableRooms => _rooms.where((r) => r.status == 'Trống').toList();
  List<Room> get occupiedRooms => _rooms.where((r) => r.status == 'Có người').toList();
}
```

### **4. Service Layer Files**

#### **services/firebase_service.dart**
```dart
// Firebase operations và utilities
class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  // Connection management
  static Future<bool> testConnection() { ... }
  static Future<Map<String, dynamic>> getConnectionInfo() { ... }
  
  // Data streams
  static Stream<DatabaseEvent> getRoomsStream() { ... }
  static Stream<DatabaseEvent> getUsersStream() { ... }
  
  // CRUD operations
  static Future<void> setRoomData(String roomId, Map<String, dynamic> data) { ... }
  static Future<void> setUserData(String userId, Map<String, dynamic> data) { ... }
  
  // Batch operations
  static Future<void> migrateRoomIds() { ... }
}
```

### **5. UI Screen Files**

#### **screens/auth/auth_screen.dart**
```dart
// Login và Registration screen
// Features:
// - Purple gradient background matching design
// - Email/password authentication
// - Role selection (landlord/tenant)
// - Form validation
// - Navigation to home screen after login

class AuthScreen extends StatefulWidget {
  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Authentication logic
  void _handleLogin() { ... }
  void _handleRegister() { ... }
}
```

#### **screens/home/home_screen.dart**
```dart
// Main dashboard screen
// Features:
// - Room statistics cards
// - Room list with IoT data
// - Role-based UI (different for landlord vs tenant)
// - Real-time updates
// - Navigation to detail screens

class HomeScreen extends StatelessWidget {
  // UI methods
  Widget _buildWelcomeSection(AuthProvider authProvider) { ... }
  Widget _buildStatsSection(RoomProvider roomProvider) { ... }
  Widget _buildRoomGrid(List<Room> rooms, BuildContext context) { ... }
}
```

#### **screens/room_detail/room_detail_screen.dart**
```dart
// Individual room detail và IoT controls
// Features:
// - IoT sensor readings (temperature, humidity, gas)
// - Device controls (lights, fan)
// - Real-time updates
// - Alert system for gas levels
// - Edit room info (landlord only)

class RoomDetailScreen extends StatefulWidget {
  final String roomId;
  
  // IoT control methods
  void _toggleLight() { ... }
  void _toggleFan() { ... }
  void _adjustFanSpeed(int speed) { ... }
}
```

#### **screens/user_management/user_management_screen.dart**
```dart
// User và room assignment management (Landlord only)
// Features:
// - User list with roles
// - Room assignment interface
// - Drag & drop room assignment
// - User creation/editing
// - Real-time user updates

class UserManagementScreen extends StatefulWidget {
  // Management methods
  void _assignRoom(String userId, String? roomId) { ... }
  void _showEditUserDialog(UserProfile user) { ... }
  void _createNewUser() { ... }
}
```

#### **screens/firebase_test/firebase_test_screen.dart**
```dart
// Firebase debugging và testing interface
// Features:
// - Connection status monitoring
// - Database read/write tests
// - Configuration display
// - Error logging
// - Performance metrics

class FirebaseTestScreen extends StatefulWidget {
  // Test methods
  Future<void> _testConnection() { ... }
  Future<void> _testDataRead() { ... }
  Future<void> _testDataWrite() { ... }
  void _refreshStatus() { ... }
}
```

### **6. Configuration Files**

#### **pubspec.yaml**
```yaml
# Dependencies configuration
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2              # State management
  firebase_core: ^4.1.0         # Firebase SDK
  firebase_database: ^12.0.1    # Realtime Database
  shared_preferences: ^2.4.12   # Local storage

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

# Assets
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

#### **android/app/google-services.json**
```json
// Android Firebase configuration
// Generated from Firebase Console
// Contains:
// - project_info (project_id, project_number)
// - client (package_name, api_key)
// - oauth_client (client_id, client_type)
```

#### **firebase.json**
```json
{
  "database": {
    "rules": "database.rules.json"
  },
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

---

## 🌐 **Triển khai Web**

### **1. Build Web Application**
```bash
# Clean previous builds
flutter clean
flutter pub get

# Build for web production
flutter build web --release

# Optimize for web
flutter build web --web-renderer html --release
```

### **2. Firebase Hosting Deployment**
```bash
# Initialize Firebase Hosting
firebase init hosting

# Configure hosting settings
# Select "build/web" as public directory
# Configure as single-page app: Yes
# Set up automatic builds with GitHub: Optional

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Deploy with custom message
firebase deploy --only hosting -m "Deploy v1.0.0 - IoT Smart Flutter"
```

### **3. Custom Domain Setup**
```bash
# Add custom domain in Firebase Console
# Hosting → Add custom domain
# Follow DNS configuration instructions
# SSL certificate automatically provided

# Example DNS records:
# Type: A
# Name: @
# Value: 151.101.1.195, 151.101.65.195

# Type: CNAME  
# Name: www
# Value: iot-smart-boarding-house.web.app
```

---

## 📱 **Triển khai Mobile**

### **Android Deployment**

#### **1. Build Configuration**
```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.iot.smart.boarding.house"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### **2. Generate Release APK**
```bash
# Create keystore (one-time setup)
keytool -genkey -v -keystore iot-smart-release-key.keystore -alias iot-smart -keyalg RSA -keysize 2048 -validity 10000

# Configure key.properties
# android/key.properties
storePassword=your_store_password
keyPassword=your_key_password  
keyAlias=iot-smart
storeFile=../iot-smart-release-key.keystore

# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### **3. Play Store Upload**
```bash
# Files to upload:
# - build/app/outputs/bundle/release/app-release.aab (App Bundle)
# - build/app/outputs/apk/release/app-release.apk (APK)

# Play Console steps:
# 1. Create app in Play Console
# 2. Complete store listing
# 3. Upload app bundle
# 4. Set pricing & distribution
# 5. Submit for review
```

### **iOS Deployment**

#### **1. Xcode Configuration**
```bash
# Open iOS project in Xcode
open ios/Runner.xcworkspace

# Configure in Xcode:
# - Bundle Identifier: com.iot.smart.boarding.house
# - Team: Select development team
# - Signing: Automatic signing
# - Deployment Target: iOS 12.0+
```

#### **2. Build iOS App**
```bash
# Build for iOS device
flutter build ios --release

# Create IPA for distribution
flutter build ipa --release

# Archive in Xcode
# Product → Archive → Distribute App
```

---

## ⚙️ **Cấu hình môi trường**

### **1. Environment Variables**
```bash
# .env file (development)
FIREBASE_PROJECT_ID=iot-smart-5700d
FIREBASE_DATABASE_URL=https://iot-smart-5700d-default-rtdb.firebaseio.com
FIREBASE_STORAGE_BUCKET=iot-smart-5700d.firebasestorage.app

# Production environment
FLUTTER_ENV=production
FIREBASE_ENV=production
DEBUG_MODE=false
```

### **2. Build Configurations**
```dart
// lib/config/app_config.dart
class AppConfig {
  static const String appName = 'IoT Smart Boarding House';
  static const String version = '1.0.0';
  static const bool isDebug = kDebugMode;
  
  // Firebase configuration
  static const String firebaseProjectId = 'iot-smart-5700d';
  static const String firebaseDatabaseUrl = 'https://iot-smart-5700d-default-rtdb.firebaseio.com';
  
  // API endpoints
  static const String baseUrl = isDebug 
    ? 'https://iot-smart-5700d-default-rtdb.firebaseio.com'
    : 'https://iot-smart-5700d-default-rtdb.firebaseio.com';
}
```

### **3. Build Scripts**
```bash
# scripts/build.sh
#!/bin/bash

echo "Building IoT Smart Flutter..."

# Clean project
flutter clean
flutter pub get

# Build for all platforms
echo "Building Android..."
flutter build apk --release

echo "Building iOS..."  
flutter build ios --release

echo "Building Web..."
flutter build web --release

echo "Build completed!"
```

---

## 🐛 **Troubleshooting**

### **Common Issues & Solutions**

#### **1. Firebase Connection Issues**
```bash
# Problem: Cannot connect to Firebase
# Solutions:
1. Check internet connection
2. Verify Firebase configuration in firebase_options.dart
3. Ensure Firebase project is active
4. Check Firebase service status

# Debug commands:
flutter clean
flutter pub get
firebase projects:list
```

#### **2. Build Errors**
```bash
# Problem: Build fails with dependency conflicts
# Solution:
flutter clean
flutter pub deps
flutter pub upgrade
flutter build [platform]

# Problem: Android build fails
# Solutions:
1. Update Android SDK
2. Check android/app/build.gradle configuration
3. Verify google-services.json is present
```

#### **3. Performance Issues**
```bash
# Problem: Slow app performance
# Solutions:
1. Enable release mode: flutter run --release
2. Optimize images and assets
3. Implement proper state management
4. Use const widgets where possible

# Profiling commands:
flutter run --profile
flutter analyze
```

#### **4. Database Sync Issues**
```bash
# Problem: Data not syncing with Firebase
# Solutions:
1. Check Firebase rules
2. Verify network connectivity
3. Test with Firebase Test screen
4. Check authentication status

# Debug Firebase:
firebase database:get / --project iot-smart-5700d
```

### **Debug Tools**
```dart
// Enable Flutter debugging
flutter run --debug

// Firebase debug logging
FirebaseDatabase.instance.setLoggingEnabled(true);

// Custom debug logging
if (kDebugMode) {
  print('Debug: Firebase connection status: $isConnected');
}
```

### **Monitoring & Analytics**
```bash
# Firebase Performance Monitoring
firebase_performance: ^0.9.4

# Crashlytics for error tracking
firebase_crashlytics: ^4.1.3

# Analytics for user behavior
firebase_analytics: ^11.3.3
```

---

## 📊 **Production Checklist**

### **Pre-deployment Checklist**
```bash
✅ Firebase project configured correctly
✅ Database rules set up and tested
✅ Authentication working properly
✅ All features tested on target devices
✅ Performance optimization completed
✅ Security audit passed
✅ Backup strategy implemented
✅ Monitoring tools configured
✅ SSL certificates valid
✅ Domain configuration complete
```

### **Post-deployment Checklist**
```bash
✅ Application loads correctly in production
✅ Firebase connection working
✅ User authentication functional
✅ Data synchronization working
✅ IoT sensor simulation operating
✅ Performance metrics acceptable
✅ Error tracking active
✅ User feedback collection setup
✅ Documentation updated
✅ Team training completed
```

---

## 📞 **Support & Maintenance**

### **Contact Information**
```
Technical Support: tech-support@iot-smart-team.com
Project Manager: pm@iot-smart-team.com
Development Team: dev-team@iot-smart-team.com

Documentation: https://docs.iot-smart-boarding-house.com
Status Page: https://status.iot-smart-boarding-house.com
```

### **Maintenance Schedule**
```
- Daily: Monitoring and health checks
- Weekly: Performance analysis and optimization
- Monthly: Security updates and patches
- Quarterly: Feature updates and enhancements
- Annually: Major version releases
```

---

> **💡 Lưu ý quan trọng**: Tài liệu này cần được cập nhật khi có thay đổi về cấu hình hoặc quy trình triển khai. Luôn kiểm tra phiên bản mới nhất trước khi thực hiện deployment.

**Tài liệu được chuẩn bị bởi**: IoT Smart Development Team  
**Phiên bản**: 1.0.0  
**Cập nhật lần cuối**: September 2025  
**Người duy trì**: DevOps Team