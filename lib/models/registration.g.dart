// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistrationModel _$RegistrationModelFromJson(Map<String, dynamic> json) =>
    RegistrationModel(
      id: (json['id'] as num).toInt(),
      eventId: (json['event_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      status: json['status'] as String,
      onWaitlist: json['on_waitlist'] == null
          ? false
          : _boolFromIntOrBool(json['on_waitlist']),
      feePaid: json['fee_paid'] == null
          ? false
          : _boolFromIntOrBool(json['fee_paid']),
      checkinCode: json['checkin_code'] as String?,
      qrCode: json['qr_code'] as String?,
      notes: json['notes'] as String?,
      fieldsSnapshot: json['fields_snapshot'],
      registeredAt: json['registered_at'] == null
          ? null
          : DateTime.parse(json['registered_at'] as String),
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      user: _mapOrListToMap(json['user']),
      event: _mapOrListToMap(json['event']),
    );

Map<String, dynamic> _$RegistrationModelToJson(RegistrationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'user_id': instance.userId,
      'status': instance.status,
      'on_waitlist': instance.onWaitlist,
      'fee_paid': instance.feePaid,
      'checkin_code': instance.checkinCode,
      'qr_code': instance.qrCode,
      'notes': instance.notes,
      'fields_snapshot': instance.fieldsSnapshot,
      'registered_at': instance.registeredAt?.toIso8601String(),
      'approved_at': instance.approvedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'user': instance.user,
      'event': instance.event,
    };
