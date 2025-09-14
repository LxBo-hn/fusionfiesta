# FusionFiesta App - Quick Start Guide

## 🚀 Khởi động nhanh

### 1. Khởi động Laravel Backend
```bash
# Mở terminal mới và chạy:
cd your-laravel-project
php artisan serve

# Server sẽ chạy tại: http://localhost:8000
```

### 2. Chạy Flutter App
```bash
# Trong terminal hiện tại:
flutter run

# App sẽ tự động kết nối với Laravel API
```

## 🔧 Cấu hình API

### Tự động phát hiện platform:
- **Android Emulator**: `http://10.0.2.2:8000/api/v1`
- **iOS Simulator**: `http://127.0.0.1:8000/api/v1`
- **Desktop/Web**: `http://127.0.0.1:8000/api/v1`

### Thay đổi URL thủ công:
Chỉnh sửa `lib/config/api_config.dart`:
```dart
static String get baseUrl {
  // Thay đổi URL theo nhu cầu
  return 'http://your-custom-url:8000/api';
}
```

## 🐛 Troubleshooting

### Lỗi "Connection refused":
1. ✅ **Kiểm tra Laravel server đang chạy**
   ```bash
   php artisan serve
   ```

2. ✅ **Kiểm tra port 8000**
   ```bash
   # Nếu port 8000 bị chiếm, thử port khác:
   php artisan serve --port=8001
   ```

3. ✅ **Kiểm tra firewall**
   - Tắt Windows Firewall tạm thời
   - Hoặc thêm exception cho port 8000

4. ✅ **Kiểm tra URL trong Flutter**
   - Android: `http://10.0.2.2:8000/api/v1`
   - iOS: `http://127.0.0.1:8000/api/v1`

### Lỗi CORS:
1. ✅ **Cài đặt CORS package**
   ```bash
   composer require fruitcake/laravel-cors
   ```

2. ✅ **Cấu hình CORS**
   ```php
   // config/cors.php
   'allowed_origins' => ['*'],
   'allowed_methods' => ['*'],
   'allowed_headers' => ['*'],
   ```

### Lỗi Database:
1. ✅ **Tạo database MySQL**
   ```sql
   CREATE DATABASE fusionfiesta_db;
   ```

2. ✅ **Cấu hình .env**
   ```env
   DB_DATABASE=fusionfiesta_db
   DB_USERNAME=root
   DB_PASSWORD=your-password
   ```

3. ✅ **Chạy migrations**
   ```bash
   php artisan migrate
   ```

## 📱 Test App

### 1. Test kết nối API:
- Mở app và xem console logs
- Tìm dòng: `🌐 API Request: GET http://10.0.2.2:8000/api/v1/events`
- Nếu thấy lỗi, kiểm tra Laravel server

### 2. Test tính năng:
- Đăng nhập/Đăng ký
- Xem danh sách sự kiện
- Đăng ký sự kiện
- Xem profile

## 🔄 Workflow Development

### 1. Khởi động development:
```bash
# Terminal 1: Laravel Backend
cd fusionfiesta-backend
php artisan serve

# Terminal 2: Flutter App
cd fusionfiesta_app
flutter run
```

### 2. Hot reload:
- Flutter: `r` để hot reload
- Laravel: Tự động reload khi thay đổi code

### 3. Debug:
- Flutter: Sử dụng VS Code debugger
- Laravel: Sử dụng `dd()` hoặc `Log::info()`

## 📊 Monitoring

### 1. Flutter logs:
```bash
flutter logs
```

### 2. Laravel logs:
```bash
tail -f storage/logs/laravel.log
```

### 3. API testing:
```bash
# Test với curl
curl http://127.0.0.1:8000/api/v1/events

# Test với Postman
GET http://127.0.0.1:8000/api/v1/events
```

## 🎯 Next Steps

### 1. Hoàn thiện Laravel Backend:
- Tạo các API endpoints
- Implement authentication
- Tạo database migrations
- Thêm validation

### 2. Enhance Flutter App:
- Thêm error handling
- Implement offline support
- Thêm push notifications
- Optimize performance

### 3. Deploy:
- Deploy Laravel lên server
- Deploy Flutter lên Play Store/App Store
- Cấu hình production database

## 🆘 Support

### Nếu gặp vấn đề:
1. Kiểm tra logs trong console
2. Xem file `FIXES_SUMMARY.md`
3. Xem file `START_LARAVEL_BACKEND.md`
4. Kiểm tra network connectivity

### Common Issues:
- **"Connection refused"**: Laravel server chưa chạy
- **"CORS error"**: Cấu hình CORS chưa đúng
- **"Database error"**: MySQL chưa được cấu hình
- **"Build error"**: Chạy `flutter clean && flutter pub get`

## 🎉 Success!

Khi thấy app chạy thành công:
- ✅ Flutter app hiển thị UI
- ✅ Không có lỗi "Connection refused"
- ✅ Có thể đăng nhập/đăng ký
- ✅ Có thể xem danh sách sự kiện

**Chúc mừng! App đã sẵn sàng để phát triển tiếp!** 🚀
