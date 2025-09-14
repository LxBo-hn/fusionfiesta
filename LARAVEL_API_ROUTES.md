# Laravel API Routes Configuration

## Cấu hình Routes cho API v1

### 1. Tạo file routes/api.php

```php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// API v1 routes
Route::prefix('v1')->group(function () {
    
    // Authentication routes
    Route::post('/auth/login', [App\Http\Controllers\Api\AuthController::class, 'login']);
    Route::post('/auth/register', [App\Http\Controllers\Api\AuthController::class, 'register']);
    Route::post('/auth/logout', [App\Http\Controllers\Api\AuthController::class, 'logout'])->middleware('auth:sanctum');
    Route::get('/auth/me', [App\Http\Controllers\Api\AuthController::class, 'me'])->middleware('auth:sanctum');
    
    // Events routes
    Route::get('/events', [App\Http\Controllers\Api\EventController::class, 'index']);
    Route::get('/events/{event}', [App\Http\Controllers\Api\EventController::class, 'show']);
    Route::post('/events', [App\Http\Controllers\Api\EventController::class, 'store'])->middleware('auth:sanctum');
    Route::put('/events/{event}', [App\Http\Controllers\Api\EventController::class, 'update'])->middleware('auth:sanctum');
    Route::delete('/events/{event}', [App\Http\Controllers\Api\EventController::class, 'destroy'])->middleware('auth:sanctum');
    
    // Registration routes
    Route::get('/registrations/my', [App\Http\Controllers\Api\RegistrationController::class, 'myRegistrations'])->middleware('auth:sanctum');
    Route::post('/events/{event}/register', [App\Http\Controllers\Api\RegistrationController::class, 'register'])->middleware('auth:sanctum');
    Route::delete('/events/{event}/unregister', [App\Http\Controllers\Api\RegistrationController::class, 'unregister'])->middleware('auth:sanctum');
    
    // Profile routes
    Route::get('/profile/me', [App\Http\Controllers\Api\ProfileController::class, 'me'])->middleware('auth:sanctum');
    Route::put('/profile/update', [App\Http\Controllers\Api\ProfileController::class, 'update'])->middleware('auth:sanctum');
    Route::post('/profile/change-password', [App\Http\Controllers\Api\ProfileController::class, 'changePassword'])->middleware('auth:sanctum');
    
    // Password Reset routes
    Route::post('/password/forgot', [App\Http\Controllers\Api\PasswordResetController::class, 'forgot']);
    Route::post('/password/reset', [App\Http\Controllers\Api\PasswordResetController::class, 'reset']);
    
    // Email Verification routes
    Route::post('/email/verification/send', [App\Http\Controllers\Api\EmailVerificationController::class, 'send'])->middleware('auth:sanctum');
    Route::get('/email/verification/verify', [App\Http\Controllers\Api\EmailVerificationController::class, 'verify']);
    
    // Notification routes
    Route::get('/notifications', [App\Http\Controllers\Api\NotificationController::class, 'index'])->middleware('auth:sanctum');
    Route::post('/notifications/{notification}/read', [App\Http\Controllers\Api\NotificationController::class, 'markRead'])->middleware('auth:sanctum');
    
    // Feedback routes
    Route::post('/events/{event}/feedback', [App\Http\Controllers\Api\FeedbackController::class, 'store'])->middleware('auth:sanctum');
    Route::get('/events/{event}/feedback', [App\Http\Controllers\Api\FeedbackController::class, 'show'])->middleware('auth:sanctum');
    
    // Media routes
    Route::get('/media', [App\Http\Controllers\Api\MediaController::class, 'index'])->middleware('auth:sanctum');
    Route::post('/media/{media}/favorite', [App\Http\Controllers\Api\MediaController::class, 'toggleFavorite'])->middleware('auth:sanctum');
    
    // Organizer routes
    Route::get('/organizer/events/{event}/registrants', [App\Http\Controllers\Api\OrganizerController::class, 'registrants'])->middleware('auth:sanctum');
    
    // Attendance routes
    Route::get('/attendance', [App\Http\Controllers\Api\AttendanceController::class, 'index'])->middleware('auth:sanctum');
    Route::post('/attendance/checkin', [App\Http\Controllers\Api\AttendanceController::class, 'checkin'])->middleware('auth:sanctum');
    
    // Certificate routes
    Route::get('/certificates/mine', [App\Http\Controllers\Api\CertificateController::class, 'mine'])->middleware('auth:sanctum');
    Route::post('/certificates/issue', [App\Http\Controllers\Api\CertificateController::class, 'issue'])->middleware('auth:sanctum');
    
});

// Health check endpoint
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now(),
        'version' => '1.0.0'
    ]);
});
```

## 2. Cấu hình CORS

### Cài đặt package:
```bash
composer require fruitcake/laravel-cors
```

### Cấu hình config/cors.php:
```php
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'http://127.0.0.1:3000',
        'http://localhost:3000',
        'http://10.0.2.2:3000',
        'http://localhost:8000',
        'http://127.0.0.1:8000',
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
```

## 3. Cấu hình Sanctum

### Cài đặt package:
```bash
composer require laravel/sanctum
```

### Publish config:
```bash
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### Cấu hình config/sanctum.php:
```php
'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
    '%s%s',
    'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
    Sanctum::currentApplicationUrlWithPort()
))),
```

## 4. Test API Endpoints

### Test với curl:
```bash
# Health check
curl http://127.0.0.1:8000/api/health

# Events (public)
curl http://127.0.0.1:8000/api/v1/events

# Login
curl -X POST http://127.0.0.1:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

### Test với Postman:
```
GET http://127.0.0.1:8000/api/health
GET http://127.0.0.1:8000/api/v1/events
POST http://127.0.0.1:8000/api/v1/auth/login
```

## 5. Response Format

### Success Response:
```json
{
  "success": true,
  "data": {...},
  "message": "Success message"
}
```

### Error Response:
```json
{
  "success": false,
  "message": "Error message",
  "errors": {
    "field": ["Validation error"]
  }
}
```

## 6. Authentication

### Login Response:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "student"
    },
    "token": "1|abcdef123456..."
  },
  "message": "Login successful"
}
```

### Protected Route Headers:
```
Authorization: Bearer 1|abcdef123456...
Content-Type: application/json
Accept: application/json
```

## 7. Error Handling

### Common HTTP Status Codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Validation Error
- `500` - Server Error

### Validation Error Example:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password must be at least 8 characters."]
  }
}
```

## 8. Rate Limiting

### Cấu hình trong RouteServiceProvider:
```php
protected function configureRateLimiting()
{
    RateLimiter::for('api', function (Request $request) {
        return Limit::perMinute(60)->by(optional($request->user())->id ?: $request->ip());
    });
}
```

## 9. API Documentation

### Sử dụng Swagger/OpenAPI:
```bash
composer require darkaonline/l5-swagger
php artisan vendor:publish --provider "L5Swagger\L5SwaggerServiceProvider"
```

### Generate documentation:
```bash
php artisan l5-swagger:generate
```

## 10. Monitoring & Logging

### Log API requests:
```php
// In App\Http\Middleware\LogApiRequests
public function handle($request, Closure $next)
{
    Log::info('API Request', [
        'method' => $request->method(),
        'url' => $request->fullUrl(),
        'ip' => $request->ip(),
        'user_agent' => $request->userAgent(),
    ]);
    
    return $next($request);
}
```

## 🎉 Kết luận

Sau khi cấu hình xong:
- API sẽ có sẵn tại `http://127.0.0.1:8000/api/v1`
- Flutter app có thể kết nối thành công
- Tất cả endpoints được bảo vệ bởi authentication
- CORS được cấu hình đúng cho development

**Lưu ý:** Đảm bảo Laravel server chạy với `php artisan serve --host=127.0.0.1 --port=8000` để Flutter app có thể kết nối!
