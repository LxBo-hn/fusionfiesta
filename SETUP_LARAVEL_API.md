# 🚀 Setup Laravel API - Hướng dẫn nhanh

## ❌ Vấn đề hiện tại
- Laravel server chạy ✅
- Nhưng chưa có API routes ❌
- Flutter app không lấy được data ❌

## 🔧 Giải pháp

### Bước 1: Tìm Laravel project
Tìm thư mục có các file:
- `artisan`
- `composer.json` 
- `app/`
- `routes/`

### Bước 2: Mở file routes/api.php
Mở file `routes/api.php` trong Laravel project

### Bước 3: Copy code này vào routes/api.php
```php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Health check
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now(),
        'message' => 'API is working!'
    ]);
});

// Events API (public - không cần auth)
Route::get('/events', function () {
    return response()->json([
        'success' => true,
        'data' => [
            [
                'id' => 1,
                'title' => 'Tech Conference 2024',
                'description' => 'Annual technology conference featuring latest innovations in AI, blockchain, and cloud computing',
                'date' => '2024-12-20',
                'start_time' => '09:00',
                'end_time' => '17:00',
                'location' => 'Convention Center, Ho Chi Minh City',
                'max_attendees' => 500,
                'current_attendees' => 150,
                'status' => 'published',
                'organizer_id' => 1,
                'category' => 'Technology',
                'created_at' => '2024-01-01T00:00:00Z',
                'updated_at' => '2024-01-01T00:00:00Z'
            ],
            [
                'id' => 2,
                'title' => 'Flutter Workshop',
                'description' => 'Learn Flutter development from basics to advanced concepts with hands-on projects',
                'date' => '2024-12-27',
                'start_time' => '10:00',
                'end_time' => '16:00',
                'location' => 'Tech Hub, District 1',
                'max_attendees' => 50,
                'current_attendees' => 25,
                'status' => 'published',
                'organizer_id' => 1,
                'category' => 'Education',
                'created_at' => '2024-01-01T00:00:00Z',
                'updated_at' => '2024-01-01T00:00:00Z'
            ],
            [
                'id' => 3,
                'title' => 'Networking Event',
                'description' => 'Connect with professionals in your industry and expand your network',
                'date' => '2025-01-03',
                'start_time' => '18:00',
                'end_time' => '21:00',
                'location' => 'Grand Hotel, District 3',
                'max_attendees' => 200,
                'current_attendees' => 80,
                'status' => 'published',
                'organizer_id' => 1,
                'category' => 'Networking',
                'created_at' => '2024-01-01T00:00:00Z',
                'updated_at' => '2024-01-01T00:00:00Z'
            ],
            [
                'id' => 4,
                'title' => 'Startup Pitch Competition',
                'description' => 'Showcase your startup idea and compete for funding opportunities',
                'date' => '2025-01-10',
                'start_time' => '14:00',
                'end_time' => '18:00',
                'location' => 'Innovation Center, District 7',
                'max_attendees' => 100,
                'current_attendees' => 45,
                'status' => 'published',
                'organizer_id' => 1,
                'category' => 'Business',
                'created_at' => '2024-01-01T00:00:00Z',
                'updated_at' => '2024-01-01T00:00:00Z'
            ]
        ],
        'message' => 'Events retrieved successfully'
    ]);
});

// API v1 routes
Route::prefix('v1')->group(function () {
    // Events (public)
    Route::get('/events', function () {
        return response()->json([
            'success' => true,
            'data' => [
                [
                    'id' => 1,
                    'title' => 'Tech Conference 2024',
                    'description' => 'Annual technology conference featuring latest innovations in AI, blockchain, and cloud computing',
                    'date' => '2024-12-20',
                    'start_time' => '09:00',
                    'end_time' => '17:00',
                    'location' => 'Convention Center, Ho Chi Minh City',
                    'max_attendees' => 500,
                    'current_attendees' => 150,
                    'status' => 'published',
                    'organizer_id' => 1,
                    'category' => 'Technology',
                    'created_at' => '2024-01-01T00:00:00Z',
                    'updated_at' => '2024-01-01T00:00:00Z'
                ],
                [
                    'id' => 2,
                    'title' => 'Flutter Workshop',
                    'description' => 'Learn Flutter development from basics to advanced concepts with hands-on projects',
                    'date' => '2024-12-27',
                    'start_time' => '10:00',
                    'end_time' => '16:00',
                    'location' => 'Tech Hub, District 1',
                    'max_attendees' => 50,
                    'current_attendees' => 25,
                    'status' => 'published',
                    'organizer_id' => 1,
                    'category' => 'Education',
                    'created_at' => '2024-01-01T00:00:00Z',
                    'updated_at' => '2024-01-01T00:00:00Z'
                ]
            ],
            'message' => 'Events retrieved successfully'
        ]);
    });
    
    // Auth routes (placeholder)
    Route::post('/auth/login', function (Request $request) {
        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'id' => 1,
                    'name' => 'Test User',
                    'email' => 'test@example.com',
                    'role' => 'organizer'
                ],
                'token' => 'mock-token-123'
            ],
            'message' => 'Login successful'
        ]);
    });
});
```

### Bước 4: Test API
```bash
# Test health check
curl http://127.0.0.1:8000/api/health

# Test events
curl http://127.0.0.1:8000/api/events

# Test events v1
curl http://127.0.0.1:8000/api/v1/events
```

### Bước 5: Chạy Flutter app
```bash
flutter run
```

## ✅ Kết quả mong đợi
- API trả về data ✅
- Flutter app hiển thị events ✅
- Giao diện hoạt động đầy đủ ✅

## 🆘 Nếu vẫn lỗi
1. Kiểm tra Laravel server có chạy không: `php artisan serve --host=127.0.0.1 --port=8000`
2. Kiểm tra file `routes/api.php` có đúng code không
3. Restart Laravel server
4. Kiểm tra console Flutter app có log gì không
