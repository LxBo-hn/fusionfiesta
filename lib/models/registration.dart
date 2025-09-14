import 'package:json_annotation/json_annotation.dart';

part 'registration.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RegistrationModel {
  final int id;
  final int eventId;
  final int userId;
  final String status; // 'pending', 'confirmed', 'cancelled'
  @JsonKey(fromJson: _boolFromIntOrBool)
  final bool onWaitlist;
  @JsonKey(fromJson: _boolFromIntOrBool)
  final bool feePaid;
  final String? checkinCode;
  final String? qrCode;
  final String? notes;
  final dynamic fieldsSnapshot;
  final DateTime? registeredAt;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  @JsonKey(fromJson: _mapOrListToMap)
  final Map<String, dynamic>? user; // User relationship data
  @JsonKey(fromJson: _mapOrListToMap)
  final Map<String, dynamic>? event; // Event relationship data

  const RegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    this.onWaitlist = false,
    this.feePaid = false,
    this.checkinCode,
    this.qrCode,
    this.notes,
    this.fieldsSnapshot,
    this.registeredAt,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.event,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) => _$RegistrationModelFromJson(json);
  Map<String, dynamic> toJson() => _$RegistrationModelToJson(this);

  // Convenience getters
  String get userName => user?['name'] ?? 'Unknown User';
  String get userEmail => user?['email'] ?? '';
  String get eventTitle => event?['title'] ?? 'Unknown Event';
  String get formattedRegisteredDate => registeredAt?.toIso8601String().split('T')[0] ?? '';
  String get formattedApprovedDate => approvedAt?.toIso8601String().split('T')[0] ?? '';
  
  // Status helpers
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isApproved => status == 'confirmed';
  bool get isRejected => status == 'cancelled';
  
  // Display helpers
  String get statusDisplayName {
    if (onWaitlist) return 'Waitlist';
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'cancelled': return 'Cancelled';
      default: return 'Unknown';
    }
  }
  
  String get statusColor {
    if (onWaitlist) return 'FF5722'; // Deep Orange
    switch (status) {
      case 'pending': return 'FF9800'; // Orange
      case 'confirmed': return '4CAF50'; // Green
      case 'cancelled': return '9E9E9E'; // Gray
      default: return '6C63FF'; // Purple
    }
  }

  RegistrationModel copyWith({
    int? id,
    int? eventId,
    int? userId,
    String? status,
    bool? onWaitlist,
    bool? feePaid,
    String? checkinCode,
    String? qrCode,
    String? notes,
    dynamic fieldsSnapshot,
    DateTime? registeredAt,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? user,
    Map<String, dynamic>? event,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      onWaitlist: onWaitlist ?? this.onWaitlist,
      feePaid: feePaid ?? this.feePaid,
      checkinCode: checkinCode ?? this.checkinCode,
      qrCode: qrCode ?? this.qrCode,
      notes: notes ?? this.notes,
      fieldsSnapshot: fieldsSnapshot ?? this.fieldsSnapshot,
      registeredAt: registeredAt ?? this.registeredAt,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      event: event ?? this.event,
    );
  }
}

// Accept 0/1, '0'/'1', 'true'/'false', or bool
bool _boolFromIntOrBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.toLowerCase();
    if (v == 'true') return true;
    if (v == 'false') return false;
    final n = num.tryParse(value);
    if (n != null) return n != 0;
  }
  return false;
}

// Accept map or list-of-map and return first map
Map<String, dynamic>? _mapOrListToMap(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return v;
  if (v is List) {
    if (v.isEmpty) return null;
    final first = v.first;
    if (first is Map) {
      return Map<String, dynamic>.from(first as Map);
    }
    return null;
  }
  return null;
}
