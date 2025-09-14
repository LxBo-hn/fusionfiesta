# Khởi động Laravel Backend

## 1. Cài đặt Laravel

### Yêu cầu:
- PHP 8.1+
- Composer
- MySQL 8.0+
- Node.js & NPM

### Cài đặt:
```bash
# Tạo project Laravel mới
composer create-project laravel/laravel fusionfiesta-backend

# Di chuyển vào thư mục
cd fusionfiesta-backend

# Cài đặt dependencies
composer install
npm install
```

## 2. Cấu hình Database

### Tạo database MySQL:
```sql
CREATE DATABASE fusionfiesta_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Cấu hình .env:
```env
APP_NAME=FusionFiesta
APP_ENV=local
APP_KEY=base64:your-app-key-here
APP_DEBUG=true
APP_URL=http://127.0.0.1:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=fusionfiesta_db
DB_USERNAME=root
DB_PASSWORD=your-password

# CORS settings
CORS_ALLOWED_ORIGINS=http://127.0.0.1:3000,http://10.0.2.2:3000
```

## 3. Chạy Migrations

```bash
# Tạo app key
php artisan key:generate

# Chạy migrations
php artisan migrate

# Tạo seeders (optional)
php artisan db:seed
```

## 4. Cấu hình CORS

### Cài đặt package:
```bash
composer require fruitcake/laravel-cors
```

### Cấu hình config/cors.php:
```php
'paths' => ['api/*', 'sanctum/csrf-cookie'],
'allowed_methods' => ['*'],
'allowed_origins' => ['*'], // Hoặc chỉ định domain cụ thể
'allowed_origins_patterns' => [],
'allowed_headers' => ['*'],
'exposed_headers' => [],
'max_age' => 0,
'supports_credentials' => false,
```

## 5. Tạo API Controllers

### Tạo các controller cần thiết:
```bash
php artisan make:controller Api/AuthController
php artisan make:controller Api/EventController
php artisan make:controller Api/RegistrationController
php artisan make:controller Api/ProfileController
php artisan make:controller Api/MediaController
php artisan make:controller Api/NotificationController
php artisan make:controller Api/FeedbackController
php artisan make:controller Api/CertificateController
php artisan make:controller Api/AttendanceController
php artisan make:controller Api/OrganizerController
php artisan make:controller Api/PasswordResetController
php artisan make:controller Api/EmailVerificationController
```

## 6. Cấu hình Routes

### Thêm vào routes/api.php:
```php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Authentication
Route::post('/auth/login', [App\Http\Controllers\Api\AuthController::class, 'login']);
Route::post('/auth/register', [App\Http\Controllers\Api\AuthController::class, 'register']);
Route::post('/auth/logout', [App\Http\Controllers\Api\AuthController::class, 'logout'])->middleware('auth:sanctum');
Route::get('/auth/me', [App\Http\Controllers\Api\AuthController::class, 'me'])->middleware('auth:sanctum');

// Events
Route::get('/events', [App\Http\Controllers\Api\EventController::class, 'index']);
Route::get('/events/{event}', [App\Http\Controllers\Api\EventController::class, 'show']);
Route::post('/events', [App\Http\Controllers\Api\EventController::class, 'store'])->middleware('auth:sanctum');
Route::put('/events/{event}', [App\Http\Controllers\Api\EventController::class, 'update'])->middleware('auth:sanctum');
Route::delete('/events/{event}', [App\Http\Controllers\Api\EventController::class, 'destroy'])->middleware('auth:sanctum');

// Registrations
Route::get('/registrations/my', [App\Http\Controllers\Api\RegistrationController::class, 'myRegistrations'])->middleware('auth:sanctum');
Route::post('/events/{event}/register', [App\Http\Controllers\Api\RegistrationController::class, 'register'])->middleware('auth:sanctum');
Route::delete('/events/{event}/unregister', [App\Http\Controllers\Api\RegistrationController::class, 'unregister'])->middleware('auth:sanctum');

// Profile
Route::get('/profile/me', [App\Http\Controllers\Api\ProfileController::class, 'me'])->middleware('auth:sanctum');
Route::put('/profile/update', [App\Http\Controllers\Api\ProfileController::class, 'update'])->middleware('auth:sanctum');
Route::post('/profile/change-password', [App\Http\Controllers\Api\ProfileController::class, 'changePassword'])->middleware('auth:sanctum');

// Password Reset
Route::post('/password/forgot', [App\Http\Controllers\Api\PasswordResetController::class, 'forgot']);
Route::post('/password/reset', [App\Http\Controllers\Api\PasswordResetController::class, 'reset']);

// Email Verification
Route::post('/email/verification/send', [App\Http\Controllers\Api\EmailVerificationController::class, 'send'])->middleware('auth:sanctum');
Route::get('/email/verification/verify', [App\Http\Controllers\Api\EmailVerificationController::class, 'verify']);

// Notifications
Route::get('/notifications', [App\Http\Controllers\Api\NotificationController::class, 'index'])->middleware('auth:sanctum');
Route::post('/notifications/{notification}/read', [App\Http\Controllers\Api\NotificationController::class, 'markRead'])->middleware('auth:sanctum');

// Feedback
Route::post('/events/{event}/feedback', [App\Http\Controllers\Api\FeedbackController::class, 'store'])->middleware('auth:sanctum');
Route::get('/events/{event}/feedback', [App\Http\Controllers\Api\FeedbackController::class, 'show'])->middleware('auth:sanctum');

// Media
Route::get('/media', [App\Http\Controllers\Api\MediaController::class, 'index'])->middleware('auth:sanctum');
Route::post('/media/{media}/favorite', [App\Http\Controllers\Api\MediaController::class, 'toggleFavorite'])->middleware('auth:sanctum');

// Organizer
Route::get('/organizer/events/{event}/registrants', [App\Http\Controllers\Api\OrganizerController::class, 'registrants'])->middleware('auth:sanctum');
```

## 7. Khởi động Server

```bash
# Khởi động Laravel server
php artisan serve --host=127.0.0.1 --port=8000

# Server sẽ chạy tại: http://127.0.0.1:8000
# API endpoints: http://127.0.0.1:8000/api/v1
```

## 8. Test API

### Test với curl:
```bash
# Test events endpoint
curl http://127.0.0.1:8000/api/v1/events

# Test với Postman hoặc browser
# GET http://127.0.0.1:8000/api/v1/events
```

### Test với Flutter:
```bash
# Chạy Flutter app
flutter run

# App sẽ kết nối với Laravel API
```

## 9. Troubleshooting

### Lỗi "Connection refused":
1. Kiểm tra Laravel server đang chạy
2. Kiểm tra port 8000 có bị chiếm không
3. Kiểm tra firewall settings
4. Thử đổi port: `php artisan serve --port=8001`

### Lỗi CORS:
1. Kiểm tra cấu hình CORS
2. Thêm domain vào allowed_origins
3. Kiểm tra headers

### Lỗi Database:
1. Kiểm tra kết nối MySQL
2. Kiểm tra credentials trong .env
3. Chạy migrations: `php artisan migrate:fresh`

## 10. Production Setup

### Cấu hình production:
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

DB_HOST=your-production-db-host
DB_DATABASE=your-production-db
DB_USERNAME=your-production-user
DB_PASSWORD=your-production-password
```

### Deploy:
```bash
# Build assets
npm run production

# Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## 🎉 Kết luận

Sau khi hoàn thành các bước trên:
1. Laravel backend sẽ chạy tại `http://localhost:8000`
2. API endpoints sẽ có sẵn tại `http://localhost:8000/api`
3. Flutter app có thể kết nối thành công
4. Tất cả tính năng sẽ hoạt động bình thường

**Lưu ý:** Đảm bảo Laravel server đang chạy trước khi test Flutter app!
