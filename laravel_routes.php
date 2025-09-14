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
    
    // Certificate routes
    Route::get('/certificates/mine', function (Request $request) {
        return response()->json([
            'success' => true,
            'data' => [
                'data' => [
                    [
                        'id' => 1,
                        'event_id' => 1,
                        'student_id' => 1,
                        'certificate_id' => 'CERT-001',
                        'pdf_url' => 'https://example.com/certificates/cert-001.pdf',
                        'issued_on' => '2024-01-15T10:30:00Z',
                        'event' => [
                            'id' => 1,
                            'title' => 'Tech Conference 2024',
                            'description' => 'Annual technology conference'
                        ]
                    ],
                    [
                        'id' => 2,
                        'event_id' => 2,
                        'student_id' => 1,
                        'certificate_id' => 'CERT-002',
                        'pdf_url' => 'https://example.com/certificates/cert-002.pdf',
                        'issued_on' => '2024-01-20T14:00:00Z',
                        'event' => [
                            'id' => 2,
                            'title' => 'Flutter Workshop',
                            'description' => 'Learn Flutter development'
                        ]
                    ]
                ],
                'current_page' => 1,
                'last_page' => 1,
                'per_page' => 15,
                'total' => 2
            ],
            'message' => 'Certificates retrieved successfully'
        ]);
    });
});
