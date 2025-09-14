<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Event;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    public function checkIn(Request $request)
    {
        $validated = $request->validate([
            'checkin_code' => ['required', 'string'],
            'event_id' => ['required', 'integer', 'exists:events,id'],
        ]);

        $event = Event::find($validated['event_id']);
        $now = now();
        
        // Kiểm tra thời gian sự kiện
        if ($now->lt($event->start_at) || $now->gt($event->end_at)) {
            return response()->json(['message' => 'invalid_time_window'], 422);
        }

        // Tạo attendance record trực tiếp trong bảng attendance
        $attendance = Attendance::create([
            'event_id' => $validated['event_id'],
            'checkin_code' => $validated['checkin_code'],
            'checked_in_at' => $now,
            'created_at' => $now,
            'updated_at' => $now,
        ]);

        return response()->json($attendance);
    }
}