# Hướng dẫn tích hợp API Local

## 1. Cài đặt Dependencies

Chạy lệnh sau để cài đặt các dependencies mới:

```bash
flutter pub get
```

## 2. Cấu hình API URL

Mở file `lib/config/api_config.dart` và cập nhật URL theo API local của bạn:

```dart
class ApiConfig {
  // Cho localhost (nếu chạy trên web hoặc desktop)
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Cho emulator Android
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Cho thiết bị thật (thay IP của máy tính)
  // static const String baseUrl = 'http://192.168.1.100:3000/api';
}
```

## 3. Cấu trúc API Endpoints (Laravel)

API Laravel của bạn cần có các endpoints sau:

### Authentication
- `POST /api/auth/login` - Đăng nhập (trả về token)
- `POST /api/auth/register` - Đăng ký (với role_hint)
- `GET /api/auth/me` - Lấy thông tin user hiện tại
- `POST /api/auth/logout` - Đăng xuất

### Events
- `GET /api/events` - Lấy danh sách events
- `GET /api/events/:id` - Lấy chi tiết event
- `POST /api/events` - Tạo event mới
- `PUT /api/events/:id` - Cập nhật event
- `DELETE /api/events/:id` - Xóa event

### Users
- `GET /api/users` - Lấy danh sách users
- `GET /api/users/:id` - Lấy chi tiết user
- `POST /api/users` - Tạo user mới
- `PUT /api/users/:id` - Cập nhật user
- `DELETE /api/users/:id` - Xóa user

### Attendance
- `GET /api/attendance?event_id=X` - Lấy danh sách attendance
- `POST /api/attendance/checkin` - Check-in với QR code

### Registrations
- `GET /api/registrations?event_id=X` - Lấy danh sách registrations
- `POST /api/registrations` - Tạo registration mới

### Approvals
- `GET /api/approvals` - Lấy danh sách approvals
- `PUT /api/approvals/:id` - Cập nhật trạng thái approval

### Media
- `GET /api/events/:id/media` - Lấy danh sách media
- `POST /api/events/:id/media` - Upload media

## 4. Format Response API (Laravel)

### Authentication Responses:

**Login Success:**
```json
{
  "token": "1|abc123def456..."
}
```

**Login Error:**
```json
{
  "message": "invalid_credentials"
}
```

**Registration Success:**
```json
{
  "message": "registered"
}
```

**Registration Error:**
```json
{
  "message": "invalid_org_email_domain"
}
```

### Other API Responses:

**Success with data:**
```json
{
  "data": [
    // Array of objects
  ]
}
```

**Error:**
```json
{
  "message": "Error description"
}
```

### Ví dụ Event Response:
```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "title": "Hackathon 2025",
      "dateText": "20-10-2025",
      "description": "24h coding marathon",
      "imageAsset": "assets/splash/onboarding_1.png",
      "status": "approved",
      "organizerId": "user123",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z",
      "maxAttendees": 100,
      "currentAttendees": 50,
      "location": "HCM City",
      "category": "Technology"
    }
  ]
}
```

### Ví dụ User Response:
```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "student",
      "avatar": "avatar_url",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z",
      "isActive": true,
      "phone": "0123456789",
      "studentId": "SV001"
    }
  ]
}
```

## 5. Sử dụng trong Code

### Trong Organizer Dashboard:
```dart
// Load events từ API
await context.read<OrganizerStore>().loadEvents();

// Tạo event mới
final success = await context.read<OrganizerStore>().createEvent(newEvent);

// Cập nhật event
final success = await context.read<OrganizerStore>().updateEvent(updatedEvent);
```

### Trong Admin Dashboard:
```dart
// Load users từ API
await context.read<AdminStore>().loadUsers();

// Load approvals từ API
await context.read<AdminStore>().loadApprovals();

// Cập nhật approval status
final success = await context.read<AdminStore>().setApprovalStatus(approvalId, 'approved');
```

## 6. Error Handling

Tất cả API calls đều có error handling tự động. Bạn có thể kiểm tra error:

```dart
// Kiểm tra loading state
ValueListenableBuilder<bool>(
  valueListenable: store.isLoading,
  builder: (context, isLoading, child) {
    if (isLoading) {
      return CircularProgressIndicator();
    }
    return YourWidget();
  },
)

// Kiểm tra error
ValueListenableBuilder<String?>(
  valueListenable: store.error,
  builder: (context, error, child) {
    if (error != null) {
      return Text('Error: $error');
    }
    return YourWidget();
  },
)
```

## 7. Chạy Build Runner (nếu cần)

Nếu có lỗi về JSON serialization, chạy:

```bash
flutter packages pub run build_runner build
```

## 8. Test API Integration

1. Khởi động API server local
2. Cập nhật URL trong `api_config.dart`
3. Chạy app: `flutter run`
4. Kiểm tra console để xem API calls

## 9. Troubleshooting

### Lỗi Connection Refused:
- Kiểm tra API server có đang chạy không
- Kiểm tra URL trong `api_config.dart`
- Kiểm tra firewall/antivirus

### Lỗi JSON Parsing:
- Kiểm tra format response từ API
- Chạy `flutter packages pub run build_runner build`

### Lỗi Authentication:
- Kiểm tra token được lưu trong SharedPreferences
- Kiểm tra API có trả về token không
