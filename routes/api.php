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
