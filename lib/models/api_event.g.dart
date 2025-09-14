// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiEventModel _$ApiEventModelFromJson(Map<String, dynamic> json) =>
    ApiEventModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      slug: json['slug'] as String,
      departmentId: (json['department_id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      organizerId: (json['organizer_id'] as num).toInt(),
      coOrganizers: json['co_organizers'] as String?,
      venue: json['venue'] as String?,
      contactInfo: json['contact_info'] as String?,
      rules: json['rules'] as String?,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
      capacity: (json['capacity'] as num).toInt(),
      seatsLeft: (json['seats_left'] as num).toInt(),
      waitlistEnabled: (json['waitlist_enabled'] as num).toInt(),
      bannerUrl: json['banner_url'] as String?,
      docUrl: json['doc_url'] as String?,
      status: json['status'] as String,
      approvalLog: json['approval_log'] as String?,
      popularityScore: (json['popularity_score'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      department: json['department'],
      category: json['category'],
      organizer: OrganizerModel.fromJson(
        json['organizer'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ApiEventModelToJson(ApiEventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'slug': instance.slug,
      'department_id': instance.departmentId,
      'category_id': instance.categoryId,
      'organizer_id': instance.organizerId,
      'co_organizers': instance.coOrganizers,
      'venue': instance.venue,
      'contact_info': instance.contactInfo,
      'rules': instance.rules,
      'start_at': instance.startAt.toIso8601String(),
      'end_at': instance.endAt.toIso8601String(),
      'capacity': instance.capacity,
      'seats_left': instance.seatsLeft,
      'waitlist_enabled': instance.waitlistEnabled,
      'banner_url': instance.bannerUrl,
      'doc_url': instance.docUrl,
      'status': instance.status,
      'approval_log': instance.approvalLog,
      'popularity_score': instance.popularityScore,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'department': instance.department,
      'category': instance.category,
      'organizer': instance.organizer,
    };

OrganizerModel _$OrganizerModelFromJson(Map<String, dynamic> json) =>
    OrganizerModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] == null
          ? null
          : DateTime.parse(json['email_verified_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: json['status'] as String,
      roleHint: json['role_hint'] as String?,
      orgDomain: json['org_domain'] as String?,
    );

Map<String, dynamic> _$OrganizerModelToJson(OrganizerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'email_verified_at': instance.emailVerifiedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'status': instance.status,
      'role_hint': instance.roleHint,
      'org_domain': instance.orgDomain,
    };
