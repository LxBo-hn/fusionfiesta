# 🔓 Tạo Public Events Endpoint

## Vấn đề
- API `/events` cần authentication
- Chưa có user để login
- Flutter app không lấy được data

## Giải pháp
Tạo endpoint public cho events trong Laravel:

### Bước 1: Mở file `routes/api.php` trong Laravel project

### Bước 2: Thêm route public này:
```php
// Public events endpoint (không cần auth)
Route::get('/public/events', function () {
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
```

### Bước 3: Cập nhật Flutter app
Sửa `ApiService.getEvents()` để dùng endpoint public:

```dart
Future<Map<String, dynamic>> getEvents() async {
  return await get('/public/events');
}
```

### Bước 4: Test
```bash
# Test endpoint mới
curl http://127.0.0.1:8000/api/v1/public/events
```

## ✅ Kết quả
- Flutter app sẽ lấy được data từ API
- Không cần authentication
- App hoạt động đầy đủ
