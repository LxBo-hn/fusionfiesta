import 'package:json_annotation/json_annotation.dart';

part 'api_event.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ApiEventModel {
  final int id;
  final String title;
  final String? description;
  final String slug;
  final int? departmentId;
  final int? categoryId;
  final int organizerId;
  final String? coOrganizers;
  final String? venue;
  final String? contactInfo;
  final String? rules;
  final DateTime startAt;
  final DateTime endAt;
  final int capacity;
  final int seatsLeft;
  final int waitlistEnabled;
  final String? bannerUrl;
  final String? docUrl;
  final String status;
  final String? approvalLog;
  final int? popularityScore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic department;
  final dynamic category;
  final OrganizerModel organizer;

  const ApiEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.slug,
    this.departmentId,
    this.categoryId,
    required this.organizerId,
    this.coOrganizers,
    this.venue,
    this.contactInfo,
    this.rules,
    required this.startAt,
    required this.endAt,
    required this.capacity,
    required this.seatsLeft,
    required this.waitlistEnabled,
    this.bannerUrl,
    this.docUrl,
    required this.status,
    this.approvalLog,
    this.popularityScore,
    required this.createdAt,
    required this.updatedAt,
    this.department,
    this.category,
    required this.organizer,
  });

  factory ApiEventModel.fromJson(Map<String, dynamic> json) => _$ApiEventModelFromJson(json);
  Map<String, dynamic> toJson() => _$ApiEventModelToJson(this);

  // Convert to EventModel for UI
  Map<String, dynamic> toEventModelJson() {
    return {
      'id': id.toString(),
      'title': title ?? 'Untitled Event',
      'description': description ?? 'No description available',
      'dateText': _formatDate(startAt) ?? 'Date TBD',
      // Use banner_url from API if available; fallback to local placeholder
      'imageAsset': (bannerUrl != null && bannerUrl!.isNotEmpty)
          ? bannerUrl!
          : 'assets/splash/onboarding_1.png',
      'status': status ?? 'published',
      'organizerId': organizerId.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'maxAttendees': capacity,
      'currentAttendees': capacity - seatsLeft,
      'location': venue ?? 'Location TBD',
      'category': (category != null && category is Map) ? category['name'] ?? 'General' : 'General',
    };
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OrganizerModel {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String? roleHint;
  final String? orgDomain;

  const OrganizerModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.roleHint,
    this.orgDomain,
  });

  factory OrganizerModel.fromJson(Map<String, dynamic> json) => _$OrganizerModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrganizerModelToJson(this);
}
