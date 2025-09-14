# 🔧 Fix Laravel Database - Hướng dẫn nhanh

## ❌ Vấn đề hiện tại
- Laravel API hoạt động ✅
- Nhưng database thiếu cột `expires_at` trong bảng `personal_access_tokens` ❌
- Flutter app đang dùng mock data ✅

## 🔧 Giải pháp

### Bước 1: Chạy migration Laravel
```bash
# Trong thư mục Laravel project
php artisan migrate:fresh
```

### Bước 2: Hoặc tạo cột thiếu
```bash
# Tạo migration mới
php artisan make:migration add_expires_at_to_personal_access_tokens_table

# Nội dung migration:
# Schema::table('personal_access_tokens', function (Blueprint $table) {
#     $table->timestamp('expires_at')->nullable();
# });

# Chạy migration
php artisan migrate
```

### Bước 3: Tạo user test
```bash
# Tạo seeder
php artisan make:seeder UserSeeder

# Nội dung seeder:
# User::create([
#     'name' => 'Test User',
#     'email' => 'test@example.com',
#     'password' => Hash::make('password123'),
# ]);

# Chạy seeder
php artisan db:seed --class=UserSeeder
```

### Bước 4: Test API
```bash
# Test login
curl -X POST http://127.0.0.1:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Test events với token
curl -X GET http://127.0.0.1:8000/api/v1/events \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Bước 5: Cập nhật Flutter app
Sau khi Laravel database hoạt động, uncomment code trong `organizer_store.dart`:

```dart
// Uncomment dòng này:
final response = await _apiService.getEvents();
```

## ✅ Kết quả mong đợi
- Laravel database hoạt động ✅
- API trả về data thật ✅
- Flutter app hiển thị data từ API ✅

## 🆘 Nếu vẫn lỗi
1. Kiểm tra MySQL có chạy không
2. Kiểm tra file `.env` có đúng database config không
3. Chạy `php artisan config:clear`
4. Restart Laravel server
