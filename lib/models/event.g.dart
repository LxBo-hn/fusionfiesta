// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
  id: json['id'] as String,
  title: json['title'] as String,
  dateText: json['dateText'] as String,
  description: json['description'] as String,
  imageAsset: json['imageAsset'] as String,
  status: json['status'] as String?,
  organizerId: json['organizerId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  maxAttendees: (json['maxAttendees'] as num?)?.toInt(),
  currentAttendees: (json['currentAttendees'] as num?)?.toInt(),
  location: json['location'] as String?,
  category: json['category'] as String?,
);

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'dateText': instance.dateText,
      'description': instance.description,
      'imageAsset': instance.imageAsset,
      'status': instance.status,
      'organizerId': instance.organizerId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'maxAttendees': instance.maxAttendees,
      'currentAttendees': instance.currentAttendees,
      'location': instance.location,
      'category': instance.category,
    };
