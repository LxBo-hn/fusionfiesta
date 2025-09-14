# FusionFiesta App - Setup Guide

## Tổng quan
FusionFiesta là một ứng dụng Flutter quản lý sự kiện với backend Laravel và database MySQL.

## Cấu trúc dự án
```
fusionfiesta_app/
├── lib/
│   ├── config/           # Cấu hình API
│   ├── models/           # Data models với JSON serialization
│   ├── services/         # API services và business logic
│   ├── state/            # State management stores
│   ├── screens/          # UI screens
│   └── routes/           # App routing
├── assets/               # Images và resources
└── pubspec.yaml         # Dependencies
```

## Yêu cầu hệ thống
- Flutter SDK 3.8.1+
- Dart 3.0+
- Android Studio / VS Code
- Laravel backend (PHP 8.1+, MySQL 8.0+)

## Cài đặt

### 1. Cài đặt dependencies
```bash
flutter pub get
```

### 2. Tạo code generation files
```bash
flutter packages pub run build_runner build
```

### 3. Cấu hình API endpoint
Chỉnh sửa file `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://your-laravel-api.com/api';
```

### 4. Chạy ứng dụng
```bash
flutter run
```

## Tính năng chính

### 🔐 Authentication
- Đăng nhập/Đăng ký
- Quên mật khẩu
- Xác thực email
- Đổi mật khẩu

### 👤 User Management
- Quản lý profile
- Phân quyền (Student, Organizer, Admin)
- Avatar và thông tin cá nhân

### 🎉 Event Management
- Tạo/sửa/xóa sự kiện
- Đăng ký sự kiện
- QR code check-in
- Quản lý người tham dự

### 📊 Dashboard
- Dashboard cho từng role
- Thống kê và analytics
- Quản lý media
- Quản lý feedback

### 📱 Notifications
- Thông báo real-time
- Email notifications
- Push notifications

### 🏆 Certificates
- Tạo chứng chỉ
- Quản lý certificates
- Download PDF

## API Integration

### Endpoints được hỗ trợ:
- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/register` - Đăng ký
- `GET /api/events` - Lấy danh sách sự kiện
- `POST /api/events/{id}/register` - Đăng ký sự kiện
- `GET /api/profile/me` - Lấy thông tin profile
- `PUT /api/profile/update` - Cập nhật profile
- Và nhiều endpoints khác...

### Response Format:
```json
{
  "success": true,
  "data": {...},
  "message": "Success message"
}
```

## Database Schema

### MySQL Tables:
- `users` - Thông tin người dùng
- `events` - Sự kiện
- `registrations` - Đăng ký sự kiện
- `attendances` - Điểm danh
- `certificates` - Chứng chỉ
- `notifications` - Thông báo
- `feedback` - Đánh giá
- `media` - Media files

## State Management

Sử dụng Provider pattern với các services:
- `AuthService` - Quản lý authentication
- `ProfileService` - Quản lý profile
- `RegistrationService` - Quản lý đăng ký
- `NotificationService` - Quản lý thông báo
- `MediaService` - Quản lý media
- `FeedbackService` - Quản lý feedback

## Troubleshooting

### Lỗi thường gặp:

1. **Build runner errors:**
   ```bash
   flutter clean
   flutter pub get
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

2. **API connection errors:**
   - Kiểm tra URL trong `api_config.dart`
   - Đảm bảo Laravel backend đang chạy
   - Kiểm tra CORS settings

3. **JSON serialization errors:**
   - Chạy lại build runner
   - Kiểm tra model annotations

## Development

### Thêm tính năng mới:
1. Tạo model trong `lib/models/`
2. Tạo service trong `lib/services/`
3. Tạo screen trong `lib/screens/`
4. Thêm route trong `lib/routes/app_routes.dart`
5. Cập nhật `main.dart` nếu cần

### Code style:
- Sử dụng `flutter_lints` rules
- Format code với `dart format`
- Comment code rõ ràng
- Tên biến và function có ý nghĩa

## Deployment

### Android:
```bash
flutter build apk --release
```

### iOS:
```bash
flutter build ios --release
```

### Web:
```bash
flutter build web --release
```

## Support

Nếu gặp vấn đề, hãy kiểm tra:
1. Flutter version compatibility
2. Dependencies conflicts
3. API endpoint availability
4. Database connection

## License

Private project - All rights reserved.
