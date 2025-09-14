import 'package:json_annotation/json_annotation.dart';

part 'media.g.dart';

@JsonSerializable()
class MediaModel {
  final int id;
  final int? eventId;
  final int uploaderId;
  final String type; // 'image', 'video', 'document'
  final String url;
  final String? thumbnailUrl;
  final String? title;
  final String? description;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? uploader; // User relationship data
  final Map<String, dynamic>? event; // Event relationship data
  final bool? isFavorited; // Whether current user has favorited this media

  const MediaModel({
    required this.id,
    this.eventId,
    required this.uploaderId,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.title,
    this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.uploader,
    this.event,
    this.isFavorited,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) => _$MediaModelFromJson(json);
  Map<String, dynamic> toJson() => _$MediaModelToJson(this);

  // Convenience getters
  String get uploaderName => uploader?['name'] ?? 'Unknown';
  String get eventTitle => event?['title'] ?? 'Unknown Event';
  String get formattedDate => createdAt?.toIso8601String().split('T')[0] ?? '';
  
  // Type helpers
  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isDocument => type == 'document';
  
  // Status helpers
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  
  // Display helpers
  String get typeDisplayName {
    switch (type) {
      case 'image': return 'Image';
      case 'video': return 'Video';
      case 'document': return 'Document';
      default: return 'Media';
    }
  }
  
  String get statusDisplayName {
    switch (status) {
      case 'pending': return 'Pending';
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      default: return 'Unknown';
    }
  }

  MediaModel copyWith({
    int? id,
    int? eventId,
    int? uploaderId,
    String? type,
    String? url,
    String? thumbnailUrl,
    String? title,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? uploader,
    Map<String, dynamic>? event,
    bool? isFavorited,
  }) {
    return MediaModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      uploaderId: uploaderId ?? this.uploaderId,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uploader: uploader ?? this.uploader,
      event: event ?? this.event,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }
}
