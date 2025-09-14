# Laravel Backend - Database Setup Guide

## Database Configuration

### 1. MySQL Database Setup
```sql
-- Tạo database
CREATE DATABASE fusionfiesta_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Tạo user (optional)
CREATE USER 'fusionfiesta_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON fusionfiesta_db.* TO 'fusionfiesta_user'@'localhost';
FLUSH PRIVILEGES;
```

### 2. Laravel .env Configuration
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=fusionfiesta_db
DB_USERNAME=fusionfiesta_user
DB_PASSWORD=your_password
```

### 3. Required Tables

#### Users Table
```sql
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('student', 'organizer', 'admin', 'super_admin', 'staff_admin') DEFAULT 'student',
    status ENUM('active', 'pending', 'suspended') DEFAULT 'active',
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);
```

#### User Details Table
```sql
CREATE TABLE user_details (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    department_id BIGINT UNSIGNED NULL,
    student_code VARCHAR(64) NULL,
    phone VARCHAR(32) NULL,
    dob DATE NULL,
    gender VARCHAR(16) NULL,
    avatar_url VARCHAR(255) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### Events Table
```sql
CREATE TABLE events (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(255) NULL,
    max_attendees INT UNSIGNED NULL,
    current_attendees INT UNSIGNED DEFAULT 0,
    seats_left INT UNSIGNED NULL,
    waitlist_enabled BOOLEAN DEFAULT FALSE,
    organizer_id BIGINT UNSIGNED NOT NULL,
    status ENUM('draft', 'published', 'cancelled') DEFAULT 'draft',
    category VARCHAR(100) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (organizer_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### Registrations Table
```sql
CREATE TABLE registrations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    event_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    status ENUM('pending', 'confirmed', 'cancelled') DEFAULT 'pending',
    on_waitlist BOOLEAN DEFAULT FALSE,
    fee_paid BOOLEAN DEFAULT FALSE,
    checkin_code VARCHAR(255) UNIQUE NOT NULL,
    qr_code TEXT NULL,
    notes TEXT NULL,
    fields_snapshot JSON NULL,
    registered_at TIMESTAMP NULL,
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_registration (event_id, user_id)
);
```

#### Attendances Table
```sql
CREATE TABLE attendances (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    registration_id BIGINT UNSIGNED NOT NULL,
    checked_in_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (registration_id) REFERENCES registrations(id) ON DELETE CASCADE
);
```

#### Certificates Table
```sql
CREATE TABLE certificates (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    event_id BIGINT UNSIGNED NOT NULL,
    student_id BIGINT UNSIGNED NOT NULL,
    certificate_id VARCHAR(255) UNIQUE NOT NULL,
    pdf_url VARCHAR(255) NOT NULL,
    issued_on TIMESTAMP NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### Notifications Table
```sql
CREATE TABLE notifications (
    id CHAR(36) PRIMARY KEY,
    type VARCHAR(255) NOT NULL,
    notifiable_type VARCHAR(255) NOT NULL,
    notifiable_id BIGINT UNSIGNED NOT NULL,
    data JSON NOT NULL,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    INDEX (notifiable_type, notifiable_id)
);
```

#### Feedback Table
```sql
CREATE TABLE feedback (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    event_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    rating TINYINT UNSIGNED NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_feedback (event_id, user_id)
);
```

#### Media Table
```sql
CREATE TABLE media (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    event_id BIGINT UNSIGNED NULL,
    uploader_id BIGINT UNSIGNED NOT NULL,
    type ENUM('image', 'video', 'document') NOT NULL,
    url VARCHAR(255) NOT NULL,
    thumbnail_url VARCHAR(255) NULL,
    title VARCHAR(255) NULL,
    description TEXT NULL,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (uploader_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### Favorites Table
```sql
CREATE TABLE favorites (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE CASCADE,
    UNIQUE KEY unique_favorite (user_id, media_id)
);
```

### 4. Laravel Migrations

Tạo migrations cho Laravel:

```bash
# Tạo migration files
php artisan make:migration create_users_table
php artisan make:migration create_user_details_table
php artisan make:migration create_events_table
php artisan make:migration create_registrations_table
php artisan make:migration create_attendances_table
php artisan make:migration create_certificates_table
php artisan make:migration create_notifications_table
php artisan make:migration create_feedback_table
php artisan make:migration create_media_table
php artisan make:migration create_favorites_table

# Chạy migrations
php artisan migrate
```

### 5. Seeders

Tạo seeders cho dữ liệu mẫu:

```bash
php artisan make:seeder UserSeeder
php artisan make:seeder EventSeeder
php artisan make:seeder RegistrationSeeder
```

### 6. API Routes

Đảm bảo các routes sau được định nghĩa trong `routes/api.php`:

```php
// Authentication
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
Route::get('/auth/me', [AuthController::class, 'me'])->middleware('auth:sanctum');

// Events
Route::get('/events', [EventController::class, 'index']);
Route::get('/events/{event}', [EventController::class, 'show']);
Route::post('/events', [EventController::class, 'store'])->middleware('auth:sanctum');
Route::put('/events/{event}', [EventController::class, 'update'])->middleware('auth:sanctum');
Route::delete('/events/{event}', [EventController::class, 'destroy'])->middleware('auth:sanctum');

// Registrations
Route::get('/registrations/my', [RegistrationController::class, 'myRegistrations'])->middleware('auth:sanctum');
Route::post('/events/{event}/register', [RegistrationController::class, 'register'])->middleware('auth:sanctum');
Route::delete('/events/{event}/unregister', [RegistrationController::class, 'unregister'])->middleware('auth:sanctum');

// Profile
Route::get('/profile/me', [ProfileController::class, 'me'])->middleware('auth:sanctum');
Route::put('/profile/update', [ProfileController::class, 'update'])->middleware('auth:sanctum');
Route::post('/profile/change-password', [ProfileController::class, 'changePassword'])->middleware('auth:sanctum');

// Password Reset
Route::post('/password/forgot', [PasswordResetController::class, 'forgot']);
Route::post('/password/reset', [PasswordResetController::class, 'reset']);

// Email Verification
Route::post('/email/verification/send', [EmailVerificationController::class, 'send'])->middleware('auth:sanctum');
Route::get('/email/verification/verify', [EmailVerificationController::class, 'verify']);

// Notifications
Route::get('/notifications', [NotificationController::class, 'index'])->middleware('auth:sanctum');
Route::post('/notifications/{notification}/read', [NotificationController::class, 'markRead'])->middleware('auth:sanctum');

// Feedback
Route::post('/events/{event}/feedback', [FeedbackController::class, 'store'])->middleware('auth:sanctum');
Route::get('/events/{event}/feedback', [FeedbackController::class, 'show'])->middleware('auth:sanctum');

// Media
Route::get('/media', [MediaController::class, 'index'])->middleware('auth:sanctum');
Route::post('/media/{media}/favorite', [MediaController::class, 'toggleFavorite'])->middleware('auth:sanctum');

// Organizer
Route::get('/organizer/events/{event}/registrants', [OrganizerController::class, 'registrants'])->middleware('auth:sanctum');
```

### 7. CORS Configuration

Cấu hình CORS trong `config/cors.php`:

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

### 8. Testing Database Connection

```bash
# Test database connection
php artisan tinker
>>> DB::connection()->getPdo();
```

### 9. Backup Database

```bash
# Backup
mysqldump -u username -p fusionfiesta_db > backup.sql

# Restore
mysql -u username -p fusionfiesta_db < backup.sql
```

## Troubleshooting

### Common Issues:

1. **Connection refused:**
   - Kiểm tra MySQL service đang chạy
   - Kiểm tra port 3306
   - Kiểm tra firewall settings

2. **Access denied:**
   - Kiểm tra username/password
   - Kiểm tra user privileges
   - Kiểm tra host permissions

3. **Table doesn't exist:**
   - Chạy migrations: `php artisan migrate`
   - Kiểm tra migration files
   - Kiểm tra database name

4. **Foreign key constraints:**
   - Kiểm tra thứ tự tạo bảng
   - Kiểm tra data integrity
   - Sử dụng `SET FOREIGN_KEY_CHECKS=0;` nếu cần

## Performance Optimization

1. **Indexes:**
   ```sql
   CREATE INDEX idx_events_date ON events(date);
   CREATE INDEX idx_registrations_user ON registrations(user_id);
   CREATE INDEX idx_registrations_event ON registrations(event_id);
   ```

2. **Query Optimization:**
   - Sử dụng eager loading
   - Sử dụng pagination
   - Cache frequently accessed data

3. **Database Configuration:**
   ```ini
   # my.cnf
   innodb_buffer_pool_size = 1G
   max_connections = 200
   query_cache_size = 64M
   ```
