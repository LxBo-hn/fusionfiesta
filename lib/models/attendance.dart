import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';

@JsonSerializable()
class AttendanceModel {
  final String id;
  final String eventId;
  final String userId;
  final String qrCode;
  final DateTime checkInTime;
  final DateTime? createdAt;
  final String? status; // checked_in, checked_out

  const AttendanceModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.qrCode,
    required this.checkInTime,
    this.createdAt,
    this.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => _$AttendanceModelFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  AttendanceModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? qrCode,
    DateTime? checkInTime,
    DateTime? createdAt,
    String? status,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      qrCode: qrCode ?? this.qrCode,
      checkInTime: checkInTime ?? this.checkInTime,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
