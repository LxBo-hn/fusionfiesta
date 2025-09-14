import 'package:json_annotation/json_annotation.dart';

part 'feedback.g.dart';

@JsonSerializable()
class FeedbackModel {
  final int id;
  final int eventId;
  final int userId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? user; // User relationship data
  final Map<String, dynamic>? event; // Event relationship data

  const FeedbackModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.event,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => _$FeedbackModelFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackModelToJson(this);

  // Convenience getters
  String get userName => user?['name'] ?? 'Anonymous';
  String get eventTitle => event?['title'] ?? 'Unknown Event';
  String get formattedDate => createdAt?.toIso8601String().split('T')[0] ?? '';
  
  // Rating display helpers
  String get ratingText {
    switch (rating) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return 'Unknown';
    }
  }

  FeedbackModel copyWith({
    int? id,
    int? eventId,
    int? userId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? user,
    Map<String, dynamic>? event,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      event: event ?? this.event,
    );
  }
}
