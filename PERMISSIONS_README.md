# Hệ thống phân quyền - Ứng dụng Quản lý nhà trọ

## Tổng quan

Ứng dụng này có hệ thống phân quyền để đảm bảo:
- **Chủ trọ** có thể giám sát và điều khiển tất cả phòng
- **Người thuê** chỉ được xem và điều khiển phòng của mình
- **Hỗ trợ nhiều người truy cập** đồng thời

## Các vai trò (Roles)

### 1. Chủ trọ (Landlord)
- **Quyền xem**: Tất cả phòng trong hệ thống
- **Quyền điều khiển**: Tất cả phòng (đèn, quạt, cảm biến)
- **Quyền quản lý**: 
  - Thêm/xóa/sửa phòng
  - Quản lý người dùng
  - Xem thống kê tổng quan
- **Quyền giám sát**: Tất cả cảm biến và trạng thái phòng

### 2. Người thuê (Tenant)
- **Quyền xem**: Chỉ phòng của mình
- **Quyền điều khiển**: Chỉ phòng của mình (đèn, quạt)
- **Quyền quản lý**: Không có
- **Quyền giám sát**: Chỉ cảm biến và trạng thái phòng của mình

## Cấu trúc dữ liệu Firebase

### Users Collection
```
users/
├── landlord1/
│   ├── uid: "landlord1"
│   ├── name: "Nguyễn Văn Chủ"
│   ├── email: "landlord@example.com"
│   ├── role: "landlord"
│   ├── phone: "0901234567"
│   ├── createdAt: "2024-01-01T00:00:00.000Z"
│   └── status: "active"
└── tenant1/
    ├── uid: "tenant1"
    ├── name: "Nguyễn Văn A"
    ├── email: "tenant@example.com"
    ├── role: "tenant"
    ├── phone: "0901234568"
    ├── createdAt: "2024-01-01T00:00:00.000Z"
    └── status: "active"
```

### Tenants Collection (Mapping người thuê - phòng)
```
tenants/
├── tenant1/
│   ├── roomId: "101"
│   └── linkedAt: "2024-01-01T00:00:00.000Z"
└── tenant2/
    ├── roomId: "103"
    └── linkedAt: "2024-01-01T00:00:00.000Z"
```

### Rooms Collection
```
rooms/
├── 101/
│   ├── name: "Phòng 101"
│   ├── status: "Có người"
│   ├── occupant: "Nguyễn Văn A"
│   ├── temperature: "26°C"
│   ├── humidity: 55
│   ├── gasAlert: false
│   ├── motionDetected: false
│   ├── fanOn: false
│   └── lightOn: true
└── 102/
    ├── name: "Phòng 102"
    ├── status: "Trống"
    ├── occupant: null
    ├── temperature: "24°C"
    ├── humidity: 48
    ├── gasAlert: false
    ├── motionDetected: false
    ├── fanOn: false
    └── lightOn: false
```

## Các hàm kiểm tra quyền

### AuthContext
```javascript
const {
    role,                    // 'landlord' | 'tenant'
    isLandlord,             // boolean
    isTenant,               // boolean
    canControlRoom,         // function(roomId) => boolean
    canViewRoom,            // function(roomId) => boolean
    canManageUsers,         // boolean
    canManageRooms,         // boolean
    canViewAllRooms,        // boolean
    canViewOwnRoom,         // boolean
} = useAuth();
```

### RoomsContext
```javascript
const {
    rooms,                  // Phòng được lọc theo quyền
    allRooms,              // Tất cả phòng (cho internal operations)
    canManageRooms,        // boolean
    canViewAllRooms,       // boolean
    canViewOwnRoom,        // boolean
} = useRooms();
```

## Luồng xác thực và phân quyền

1. **Đăng nhập**: Người dùng đăng nhập qua Firebase Auth
2. **Lấy profile**: Hệ thống lấy thông tin profile từ `users/{uid}`
3. **Xác định vai trò**: Role được set từ profile
4. **Lấy phòng được phép**: 
   - Landlord: Tất cả phòng
   - Tenant: Chỉ phòng được map trong `tenants/{uid}`
5. **Kiểm tra quyền**: Mỗi action đều kiểm tra quyền trước khi thực hiện

## Bảo mật

- **Client-side**: Kiểm tra quyền để ẩn/hiện UI elements
- **Server-side**: Firebase Security Rules (cần cấu hình thêm)
- **Data filtering**: Dữ liệu được lọc theo quyền trước khi gửi về client

## Sử dụng

### Đăng nhập mẫu
- **Chủ trọ**: `landlord@example.com` / `password`
- **Người thuê**: `tenant@example.com` / `password`

### Chuyển đổi vai trò
- Sử dụng dropdown "Vai trò" trong header
- Chỉ có tác dụng khi chưa đăng nhập
- Sau khi đăng nhập, vai trò được set từ profile

### Quản lý người dùng
- Truy cập `/users` (chỉ chủ trọ)
- Thêm/sửa/xóa người dùng
- Phân quyền vai trò

## Mở rộng

Để thêm vai trò mới:
1. Cập nhật `AuthContext.js` với quyền mới
2. Cập nhật `RoomsContext.js` với logic phân quyền mới
3. Cập nhật UI components để hiển thị quyền mới
4. Cập nhật Firebase Security Rules

## Troubleshooting

### Lỗi thường gặp
1. **"Bạn không có quyền..."**: Kiểm tra vai trò và mapping phòng
2. **Không thấy phòng**: Kiểm tra `tenants/{uid}` mapping
3. **Không thể điều khiển**: Kiểm tra `canControlRoom(roomId)`

### Debug
- Mở Console để xem log phân quyền
- Kiểm tra Firebase Database để xem dữ liệu
- Sử dụng React DevTools để xem state

