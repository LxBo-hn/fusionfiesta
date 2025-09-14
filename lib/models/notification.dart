import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  // Convenience getters
  bool get isRead => readAt != null;
  bool get isUnread => !isRead;
  
  String get formattedDate {
    if (createdAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  String get formattedFullDate {
    if (createdAt == null) return '';
    return createdAt!.toIso8601String().split('T')[0];
  }
  
  // Type helpers
  bool get isEventNotification => type == 'event';
  bool get isRegistrationNotification => type == 'registration';
  bool get isAttendanceNotification => type == 'attendance';
  bool get isCertificateNotification => type == 'certificate';
  bool get isSystemNotification => type == 'system';
  
  // Icon based on type
  String get iconName {
    switch (type) {
      case 'event': return 'event';
      case 'registration': return 'person_add';
      case 'attendance': return 'check_circle';
      case 'certificate': return 'certificate';
      case 'system': return 'info';
      default: return 'notifications';
    }
  }
  
  // Color based on type
  String get colorHex {
    switch (type) {
      case 'event': return '6C63FF';
      case 'registration': return '4CAF50';
      case 'attendance': return '2196F3';
      case 'certificate': return 'FF9800';
      case 'system': return '9E9E9E';
      default: return '6C63FF';
    }
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
