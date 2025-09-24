# 🏠 IoT Smart Flutter - Hệ thống Quản lý Nhà Trọ Thông minh

> **Ứng dụng Flutter quản lý nhà trọ tích hợp IoT với Firebase Realtime Database**

![Flutter](https://img.shields.io/badge/Flutter-3.32.x-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Realtime%20Database-FFCA28?logo=firebase)
![Dart](https://img.shields.io/badge/Dart-3.5.x-0175C2?logo=dart)

---

## 📋 **Mục lục**

1. [🎯 Tổng quan dự án](#-tổng-quan-dự-án)
2. [🏗️ Kiến trúc hệ thống](#️-kiến-trúc-hệ-thống)
3. [📱 Tính năng chính](#-tính-năng-chính)
4. [🎨 Giao diện người dùng](#-giao-diện-người-dùng)
5. [📁 Cấu trúc thư mục](#-cấu-trúc-thư-mục)
6. [🔄 Luồng dữ liệu](#-luồng-dữ-liệu)
7. [🛠️ Công nghệ sử dụng](#️-công-nghệ-sử-dụng)
8. [⚙️ Cài đặt và chạy](#️-cài-đặt-và-chạy)
9. [🔐 Bảo mật](#-bảo-mật)
10. [📊 Dữ liệu IoT](#-dữ-liệu-iot)

---

## 🎯 **Tổng quan dự án**

**IoT Smart Flutter** là một hệ thống quản lý nhà trọ thông minh được phát triển bằng Flutter, tích hợp với Firebase Realtime Database và mô phỏng các cảm biến IoT. Ứng dụng hỗ trợ 2 vai trò chính:

### **👨‍💼 Chủ trọ (Landlord)**
- Quản lý tất cả phòng trọ
- Thêm/sửa/xóa phòng
- Gán phòng cho người thuê
- Theo dõi cảm biến IoT của tất cả phòng
- Quản lý người dùng

### **👤 Người thuê (Tenant)**
- Xem thông tin phòng của mình
- Theo dõi cảm biến IoT phòng mình
- Điều khiển thiết bị thông minh (đèn, quạt)

---

## 🏗️ **Kiến trúc hệ thống**

```
┌─────────────────────────────────────────────────────┐
│                    CLIENT (Flutter)                │
├─────────────────────────────────────────────────────┤
│  UI Layer          │  Business Logic Layer          │
│  ┌─────────────┐   │  ┌─────────────┐              │
│  │   Screens   │◄──┤  │  Providers  │              │
│  │ - Auth      │   │  │ - Auth      │              │
│  │ - Home      │   │  │ - Room      │              │
│  │ - Room      │   │  └─────────────┘              │
│  │ - User Mgmt │   │         │                     │
│  └─────────────┘   │  ┌─────────────┐              │
│                     │  │  Services   │              │
│                     │  │ - Firebase  │              │
│                     │  └─────────────┘              │
├─────────────────────────────────────────────────────┤
│                 Data Layer                          │
│  ┌─────────────┐   ┌─────────────┐   ┌───────────┐ │
│  │   Models    │   │ Shared Pref │   │   Cache   │ │
│  │ - Room      │   │ - Settings  │   │ - Data    │ │
│  └─────────────┘   └─────────────┘   └───────────┘ │
└─────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────┐
│              FIREBASE REALTIME DATABASE            │
│  ┌─────────────┐   ┌─────────────────────────────┐ │
│  │    users    │   │            rooms            │ │
│  │ ├─ user1    │   │ ├─ 102                     │ │
│  │ ├─ user2    │   │ │  ├─ name: "102"          │ │
│  │ └─ user3    │   │ │  ├─ status: "Có người"   │ │
│  │             │   │ │  ├─ occupant: "User1"    │ │
│  │             │   │ │  ├─ gasLevel: 20         │ │
│  │             │   │ │  ├─ humidity: 65         │ │
│  │             │   │ │  ├─ lightOn: true        │ │
│  │             │   │ │  └─ temperature: "24C"   │ │
│  │             │   │ ├─ 103                     │ │
│  │             │   │ └─ 105                     │ │
│  └─────────────┘   └─────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

---

## 📁 **Cấu trúc thư mục**

```
lib/
├── main.dart                    # Entry point, Firebase init, routing
├── debug_firebase.dart          # Firebase debug configuration
├── firebase_options.dart       # Firebase project configuration
│
├── models/                      # Data Models
│   ├── user_profile.dart       # User model (name, email, role, roomId)
│   └── room.dart               # Room model (IoT data, occupant info)
│
├── providers/                   # State Management (Provider pattern)
│   ├── auth_provider.dart      # Authentication & user management
│   └── room_provider.dart      # Room data & IoT management
│
├── services/                    # External Services
│   └── firebase_service.dart   # Firebase connection & operations
│
├── screens/                     # UI Screens
│   ├── auth/
│   │   └── auth_screen.dart    # Login/Register (Purple gradient)
│   │
│   ├── home/
│   │   └── home_screen.dart    # Dashboard (Room list, statistics)
│   │
│   ├── room_detail/
│   │   └── room_detail_screen.dart  # IoT controls & monitoring
│   │
│   ├── user_management/
│   │   └── user_management_screen.dart  # User & room assignment
│   │
│   ├── firebase_test/
│   │   └── firebase_test_screen.dart    # Firebase debugging
│   │
│   └── test_auth_screen.dart   # Authentication testing
│
└── widgets/                     # Reusable Components
    └── (Common UI components)
```

---

## 🔄 **Luồng dữ liệu**

### **1. Authentication Flow**
```
User Input → AuthProvider → Firebase Auth → Local Storage → UI Update
    │              │              │              │           │
    │              │              │              │           └─ Navigate to Home
    │              │              │              └─ Save auth token
    │              │              └─ Verify credentials
    │              └─ Call login/register
    └─ Email, Password, Role
```

### **2. Room Management Flow**
```
User Action → RoomProvider → Firebase Database → Local Cache → UI Refresh
    │              │               │                │            │
    │              │               │                │            └─ Update room list
    │              │               │                └─ Store offline data
    │              │               └─ Save/Update room data
    │              └─ CRUD operations
    └─ Add/Edit/Delete room
```

### **3. Real-time Data Sync**
```
Firebase Database Change → RoomProvider Listener → State Update → UI Refresh
    │                           │                      │           │
    │                           │                      │           └─ Update IoT values
    │                           │                      └─ notifyListeners()
    │                           └─ onValue stream
    └─ IoT sensor data update
```

### **4. Offline Support Flow**
```
Network Available? → Use Firebase → Update Local Cache → Display Data
    │                     │              │                   │
    │                     └─ Real-time    └─ Store for       └─ Show latest data
    │                        sync            offline use
    │
Network Unavailable → Use Local Cache → Display Cached Data → Queue Changes
    │                       │                │                    │
    │                       └─ Fallback      └─ Show offline     └─ Sync when online
    │                          data             indicator
    └─ Detect offline state
```

---

## 🛠️ **Công nghệ sử dụng**

### **Frontend Framework**
```yaml
flutter: 3.32.x
dart: 3.5.x
```

### **State Management**
```yaml
provider: ^6.1.2          # State management pattern
```

### **Firebase Services**
```yaml
firebase_core: ^4.1.0     # Firebase initialization
firebase_database: ^12.0.1 # Realtime Database
```

### **Local Storage**
```yaml
shared_preferences: ^2.4.12 # Local data persistence
```

### **Routing**
```dart
// Custom route configuration
Map<String, WidgetBuilder> routes = {
  '/login': (context) => const AuthScreen(),
  '/home': (context) => const HomeScreen(),
  '/room': (context) => const RoomDetailScreen(),
  '/management_users': (context) => const UserManagementScreen(),
  '/firebase-test': (context) => const FirebaseTestScreen(),
};
```

---

## ⚙️ **Cài đặt và chạy**

### **1. Prerequisites**
```bash
# Install Flutter SDK
flutter --version  # Verify installation

# Install dependencies
flutter pub get
```

### **2. Firebase Configuration**
```bash
# Firebase project: iot-smart-5700d
# Database URL: https://iot-smart-5700d-default-rtdb.firebaseio.com
# Storage: iot-smart-5700d.firebasestorage.app
```

### **3. Run Application**
```bash
# Debug mode
flutter run

# Web (port 8080)
flutter run -d chrome --web-port=8080

# Release mode
flutter run --release
```

### **4. Build Production**
```bash
# Android APK
flutter build apk --release

# Web
flutter build web

# Windows
flutter build windows
```

---

## 🔐 **Bảo mật**

### **Authentication**
- Firebase Authentication cho secure login
- JWT tokens cho session management
- Role-based access control (RBAC)

### **Data Protection**
```dart
// Example: Room access control
bool canAccessRoom(UserProfile user, String roomId) {
  if (user.role == UserRole.landlord) return true;
  if (user.role == UserRole.tenant) return user.roomId == roomId;
  return false;
}
```

### **Firebase Rules** (Recommended)
```json
{
  "rules": {
    "users": {
      ".read": "auth != null",
      "$uid": {
        ".write": "auth.uid == $uid"
      }
    },
    "rooms": {
      ".read": "auth != null",
      ".write": "root.child('users').child(auth.uid).child('role').val() == 'landlord'"
    }
  }
}
```

---

## 📊 **Dữ liệu IoT**

### **Room Data Structure**
```dart
class Room {
  final String id;                    // "102", "103", "105"
  final String name;                  // Display name
  final String status;                // "Trống", "Có người", "Bảo trì"
  final String temperature;           // "24C", "25C"
  final int temperatureValue;         // 24, 25 (for calculations)
  final String? price;                // "2000000 VND"
  final String? occupant;             // User name or null
  final int gasLevel;                 // 0-100 (%)
  final int humidity;                 // 0-100 (%)
  final bool lightOn;                 // true/false
  final bool fanOn;                   // true/false
  final int fanSpeed;                 // 0-100 (%)
  final bool gasAlert;                // true if gas > 80%
  final bool motionDetected;          // PIR sensor
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### **IoT Sensor Simulation**
```dart
// Example: Gas sensor alert
bool get isGasAlertActive => gasLevel > 80;

// Temperature comfort level
String get temperatureStatus {
  if (temperatureValue < 18) return "Lạnh";
  if (temperatureValue > 30) return "Nóng"; 
  return "Bình thường";
}

// Humidity comfort level  
String get humidityStatus {
  if (humidity < 40) return "Khô";
  if (humidity > 70) return "Ẩm";
  return "Thoải mái";
}
```

### **Real-time Updates**
```dart
// Firebase listener for real-time IoT data
_databaseRef.child('rooms').onValue.listen((event) {
  if (event.snapshot.exists) {
    final data = event.snapshot.value as Map<dynamic, dynamic>;
    // Update UI with new sensor values
    _processIoTData(data);
  }
});
```

---

## 🌟 **Tính năng nổi bật**

### **1. 🎨 Modern UI/UX**
- Material 3 design system
- Purple gradient theme
- Smooth animations
- Responsive design

### **2. ⚡ Real-time Sync**
- Firebase real-time database
- Live IoT data updates
- Offline support with cache

### **3. 🔧 Smart Controls**
- IoT device simulation
- Remote control capabilities
- Automated alerts

### **4. 👥 Multi-role Support**
- Landlord full access
- Tenant restricted access
- Role-based permissions

### **5. 🛠️ Developer Tools**
- Firebase test screen
- Debug logging
- Error handling

---

## 📝 **API Reference**

### **AuthProvider Methods**
```dart
// Authentication
Future<bool> login({required String email, required String password});
Future<bool> register({required String email, required String password, required String name, required UserRole role});
Future<void> logout();

// User Management  
Future<void> refreshUsers();
Future<void> assignRoomToUser(String userId, String? roomId);
```

### **RoomProvider Methods**  
```dart
// Room CRUD
Future<void> createRoom(Room room);
Future<void> updateRoom(Room room);
Future<void> deleteRoom(String roomId);

// Data Sync
Future<void> bootstrap();
Future<void> syncWithFirebase();
```

---

## 🚀 **Triển khai**

### **Development Environment**
```bash
# Local development
flutter run -d chrome

# Hot reload enabled
# Firebase emulator (optional)
```

### **Production Deployment**
```bash
# Web deployment
flutter build web --release
# Deploy to Firebase Hosting or other web servers

# Mobile deployment  
flutter build apk --release
# Upload to Google Play Store / App Store
```

---

## 📞 **Support & Documentation**

### **Project Structure**
- `main.dart`: Application entry point
- `providers/`: Business logic và state management
- `screens/`: UI screens và navigation
- `models/`: Data models và validation
- `services/`: External service integrations

### **Key Features Documentation**
- Authentication system với Firebase
- Real-time IoT data synchronization
- Role-based access control
- Offline support với local caching
- Modern UI với gradient themes

### **Debugging Tools**
- Firebase Test screen cho connection testing
- Debug logging cho development
- Error boundaries cho production stability

---

## 🔑 **Demo Credentials**

### **Local Testing**
```
Landlord: landlord@example.com / 123456
Tenant: tenant@example.com / 123456
```

### **Firebase Project**
```
Project ID: iot-smart-5700d
Database URL: https://iot-smart-5700d-default-rtdb.firebaseio.com
```



---

## 📱 **Hướng dẫn sử dụng**

### **Cho Chủ trọ:**
1. Đăng nhập với tài khoản landlord
2. Xem tổng quan tất cả phòng trọ
3. Thêm phòng mới hoặc chỉnh sửa phòng hiện có
4. Gán phòng cho người thuê trong phần User Management
5. Theo dõi cảm biến IoT của tất cả phòng

### **Cho Người thuê:**
1. Đăng nhập với tài khoản tenant
2. Xem thông tin phòng được gán
3. Điều khiển thiết bị trong phòng (đèn, quạt)
4. Theo dõi cảm biến (nhiệt độ, độ ẩm, khí gas)

---

 **💡 Lưu ý**: Đây là một dự án demo mô phỏng hệ thống IoT. Trong thực tế, cần tích hợp với các cảm biến IoT thật và thiết lập Firebase Security Rules phù hợp.

**Phát triển bởi**: IoT Smart Team  
**Phiên bản**: 1.0.0  
**Cập nhật lần cuối**: September 2025

---

## 📱 **Tính năng chính**

### **🔐 Xác thực và Phân quyền**
```
Đăng ký/Đăng nhập → Xác thực Firebase → Phân quyền vai trò → Chuyển hướng màn hình
```

### **🏠 Quản lý Phòng**
- **CRUD Operations**: Tạo, Đọc, Cập nhật, Xóa phòng
- **Gán phòng**: Chủ trọ gán phòng cho người thuê
- **Trạng thái**: "Trống", "Có người", "Bảo trì"
- **Thông tin chi tiết**: Giá thuê, người thuê hiện tại

### **📊 Giám sát IoT**
- **Cảm biến khí gas**: Mức độ khí gas (0-100%)
- **Độ ẩm**: Độ ẩm không khí (0-100%)
- **Nhiệt độ**: Nhiệt độ phòng (°C)
- **Phát hiện chuyển động**: Có/Không
- **Điều khiển thiết bị**: Đèn, quạt (Bật/Tắt)

### **👥 Quản lý Người dùng**
- **Danh sách người dùng**: Hiển thị tất cả users
- **Gán phòng**: Interface kéo thả để gán phòng
- **Thông tin chi tiết**: Tên, email, vai trò, phòng hiện tại

---

## 🎨 **Giao diện người dùng**

### **🌈 Design System**
```css
/* Color Palette */
Primary Gradient: Linear(#8E2DE2 → #4A00E0 → #92FE9D)
Accent Colors: #667eea, #764ba2
Surface: #FFFFFF
Background: Gradient overlay
Text: #1C2534 (Dark), #FFFFFF (Light)
```

### **📱 Screen Flow**
```
Splash → Auth (Login/Register) → Home → Detail Screens
    │
    └─ Firebase Test (Debug)
    └─ User Management (Landlord only)
    └─ Room Detail (All users)
```

### **🎭 UI Components**
- **Gradient Backgrounds**: Purple to green gradient
- **Glass Cards**: Semi-transparent cards with blur
- **Custom Buttons**: Gradient buttons with shadows
- **Modern Icons**: Rounded icons with gradient backgrounds
- **Smooth Animations**: Page transitions và loading states

```bash
flutter pub get
flutter run
```

Use the landlord account to exercise full CRUD flows, or the tenant account to verify restricted access.

## Next steps

- Connect to actual IoT device APIs when available
- Build out the user management screen (role assignment, room linkage)
- Add automated tests once business rules stabilise
- Localise the UI strings and tighten validation rules
