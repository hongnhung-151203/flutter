# Ứng dụng Quản lý Nhà trọ

Ứng dụng React để quản lý nhà trọ với các tính năng:
- Quản lý danh sách phòng
- Theo dõi trạng thái phòng (có người, trống, bảo trì)
- Điều khiển thiết bị (quạt, đèn)
- Giám sát môi trường (nhiệt độ, độ ẩm, khí ga)
- Giao diện đẹp và thân thiện người dùng

## Cài đặt

1. Cài đặt dependencies:
```bash
npm install
```

2. Chạy ứng dụng:
```bash
npm start
```

Ứng dụng sẽ chạy tại [http://localhost:3000](http://localhost:3000)

### Cấu hình Firebase

1. Cài gói SDK Firebase:
```bash
npm install firebase
```

2. Tạo file `.env.local` ở thư mục gốc (cùng cấp `package.json`) với nội dung:
```
REACT_APP_FIREBASE_API_KEY=your_api_key
REACT_APP_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=your_project_id
REACT_APP_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=000000000000
REACT_APP_FIREBASE_APP_ID=1:000000000000:web:xxxxxxxxxxxxxxxxxxxxxx
REACT_APP_FIREBASE_DATABASE_URL=https://your_project-default-rtdb.firebaseio.com
```

3. Truy cập dịch vụ trong mã nguồn qua `src/services/firebase.js` và Firestore helpers ở `src/services/roomsService.js`.

## Công nghệ sử dụng

- **React 18** - Framework chính
- **Material-UI (MUI)** - Component library
- **React Router** - Điều hướng
- **Emotion** - CSS-in-JS styling

## Cấu trúc dự án

```
src/
├── components/
│   ├── HomePage.js          # Trang chính hiển thị danh sách phòng
│   └── RoomDetailPage.js    # Trang chi tiết phòng và điều khiển
├── App.js                   # Component chính với routing
└── index.js                 # Entry point
```

## Tính năng

### Trang chủ (HomePage)
- Hiển thị tổng quan số lượng phòng
- Danh sách phòng với thông tin cơ bản
- Thêm phòng mới
- Xóa phòng
- Thống kê phòng đã thuê và trống

### Trang chi tiết phòng (RoomDetailPage)
- Thông tin chi tiết phòng
- Điều khiển thiết bị (quạt, đèn)
- Giám sát môi trường (nhiệt độ, độ ẩm, khí ga)
- Cảm biến chuyển động
- Thao tác nhanh

## Giao diện

Ứng dụng sử dụng Material Design với:
- Màu sắc hiện đại và dễ nhìn
- Responsive design cho mọi thiết bị
- Animations và transitions mượt mà
- Icons trực quan

## Phát triển

Để thêm tính năng mới:
1. Tạo component mới trong thư mục `components/`
2. Thêm route trong `App.js` nếu cần
3. Cập nhật navigation và state management

## Build production

```bash
npm run build
```

## Tác giả

Ứng dụng được chuyển đổi từ Flutter sang React để quản lý nhà trọ một cách hiệu quả."# flutter" 
