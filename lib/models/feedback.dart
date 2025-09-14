import 'package:json_annotation/json_annotation.dart';

part 'feedback.g.dart';

@JsonSerializable()
class FeedbackModel {
  final int id;
  final int eventId;
  final int userId;
  final int rating; // Overall rating 1-5
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? user; // User relationship data
  final Map<String, dynamic>? event; // Event relationship data
  
  // Detailed ratings for different criteria
  final int? organizationRating; // 1-5
  final int? relevanceRating; // 1-5
  final int? coordinationRating; // 1-5
  final int? overallExperienceRating; // 1-5

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
    this.organizationRating,
    this.relevanceRating,
    this.coordinationRating,
    this.overallExperienceRating,
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
      case 1: return 'Rất tệ';
      case 2: return 'Tệ';
      case 3: return 'Bình thường';
      case 4: return 'Tốt';
      case 5: return 'Xuất sắc';
      default: return 'Chưa đánh giá';
    }
  }

  // Get average of detailed ratings
  double get averageDetailedRating {
    final ratings = [
      organizationRating,
      relevanceRating,
      coordinationRating,
      overallExperienceRating,
    ].where((r) => r != null).cast<int>();
    
    if (ratings.isEmpty) return 0.0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  // Check if detailed ratings are provided
  bool get hasDetailedRatings {
    return organizationRating != null && 
           relevanceRating != null && 
           coordinationRating != null && 
           overallExperienceRating != null;
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
    int? organizationRating,
    int? relevanceRating,
    int? coordinationRating,
    int? overallExperienceRating,
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
      organizationRating: organizationRating ?? this.organizationRating,
      relevanceRating: relevanceRating ?? this.relevanceRating,
      coordinationRating: coordinationRating ?? this.coordinationRating,
      overallExperienceRating: overallExperienceRating ?? this.overallExperienceRating,
    );
  }
}
