# 🚀 IoT Smart Flutter Routes

## 📋 Danh sách Routes

### 🔐 Authentication
- **`/login`** - Trang đăng nhập/đăng ký (AuthScreen)
  - Đăng nhập với email/password
  - Đăng ký tài khoản mới
  - Form validation và error handling

### 🏠 Main App
- **`/`** - Root route (RootDecider)
  - Tự động chuyển hướng đến `/home` nếu đã đăng nhập
  - Chuyển hướng đến `/login` nếu chưa đăng nhập

- **`/home`** - Trang chủ (HomeScreen)
  - Dashboard quản lý nhà trọ
  - Danh sách phòng
  - Thống kê tổng quan
  - Navigation cho landlord/tenant

- **`/room`** - Alias cho `/home` 
  - Cùng chức năng với trang home
  - Hiển thị danh sách phòng

### 🏨 Room Management  
- **`/room/{roomId}`** - Chi tiết phòng cụ thể (RoomDetailScreen)
  - Ví dụ: `/room/101`, `/room/A01`
  - Thông tin chi tiết phòng
  - Cảm biến IoT data
  - Điều khiển thiết bị

### 👥 User Management
- **`/management_users`** - Quản lý người dùng (UserManagementScreen)
  - **Landlord only**: Quản lý tenant
  - Gán/bỏ gán phòng cho tenant
  - Tab-based interface: Tất cả/Đã có phòng/Chưa có phòng
  - Real-time Firebase sync

### 🔧 Development/Testing
- **`/firebase-test`** - Firebase Testing (FirebaseTestScreen)
  - Debug Firebase connection
  - Test database operations
  - Development utilities

- **`/test-auth`** - Authentication Testing (TestAuthScreen)  
  - Test auth functions
  - Debug authentication flow
  - Development purposes

## 🔄 Navigation Patterns

### Login Flow
```dart
// Successful login
Navigator.of(context).pushReplacementNamed('/home');

// Logout  
Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
```

### User Management Flow
```dart
// Go to user management (Landlord only)
Navigator.of(context).pushNamed('/management_users');

// Success action - back to home
Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
```

### Room Navigation
```dart
// Go to specific room
Navigator.of(context).pushNamed('/room/${room.id}');

// Dynamic room route handling
if (settings.name!.startsWith('/room/')) {
  final roomId = settings.name!.split('/').last;
  return MaterialPageRoute(
    builder: (_) => RoomDetailScreen(roomId: roomId),
  );
}
```

## 🎯 Route Security

### Role-based Access
- **`/management_users`**: Chỉ dành cho Landlord
- **`/room/{roomId}`**: Tenant chỉ xem được phòng của mình
- **`/home`**: Hiển thị dữ liệu khác nhau theo role

### Auto-redirect
- Chưa đăng nhập → `/login`
- Đã đăng nhập → `/home`  
- Root `/` → Auto-detect và redirect

## 🔧 Implementation Notes

### Route Generation
Routes được handle trong `main.dart` với `onGenerateRoute`:
```dart
onGenerateRoute: (settings) {
  // Dynamic routes first
  if (settings.name!.startsWith('/room/')) { ... }
  
  // Static routes  
  switch (settings.name) {
    case '/login': return MaterialPageRoute(builder: (_) => const AuthScreen());
    case '/home': return MaterialPageRoute(builder: (_) => const HomeScreen());
    // ... more routes
  }
}
```

### State Management
- Routes kết hợp với Provider pattern
- AuthProvider để check authentication state
- RoomProvider để load room data
- Real-time Firebase sync across all routes

---

**Last Updated**: September 24, 2025
**Version**: 1.0.0