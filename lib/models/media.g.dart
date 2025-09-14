// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaModel _$MediaModelFromJson(Map<String, dynamic> json) => MediaModel(
  id: (json['id'] as num).toInt(),
  eventId: (json['eventId'] as num?)?.toInt(),
  uploaderId: (json['uploaderId'] as num).toInt(),
  type: json['type'] as String,
  url: json['url'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  status: json['status'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  uploader: json['uploader'] as Map<String, dynamic>?,
  event: json['event'] as Map<String, dynamic>?,
  isFavorited: json['isFavorited'] as bool?,
);

Map<String, dynamic> _$MediaModelToJson(MediaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'uploaderId': instance.uploaderId,
      'type': instance.type,
      'url': instance.url,
      'thumbnailUrl': instance.thumbnailUrl,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'uploader': instance.uploader,
      'event': instance.event,
      'isFavorited': instance.isFavorited,
    };
