import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable()
class EventModel {
	final String id;
	final String title;
	final String dateText;
	final String description;
	final String imageAsset;
	final String? status; // pending, approved, rejected
	final String? organizerId;
	final DateTime? createdAt;
	final DateTime? updatedAt;
	final int? maxAttendees;
	final int? currentAttendees;
	final String? location;
	final String? category;

	const EventModel({
		required this.id,
		required this.title,
		required this.dateText,
		required this.description,
		required this.imageAsset,
		this.status,
		this.organizerId,
		this.createdAt,
		this.updatedAt,
		this.maxAttendees,
		this.currentAttendees,
		this.location,
		this.category,
	});

	factory EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);
	Map<String, dynamic> toJson() => _$EventModelToJson(this);

	EventModel copyWith({
		String? id,
		String? title,
		String? dateText,
		String? description,
		String? imageAsset,
		String? status,
		String? organizerId,
		DateTime? createdAt,
		DateTime? updatedAt,
		int? maxAttendees,
		int? currentAttendees,
		String? location,
		String? category,
	}) {
		return EventModel(
			id: id ?? this.id,
			title: title ?? this.title,
			dateText: dateText ?? this.dateText,
			description: description ?? this.description,
			imageAsset: imageAsset ?? this.imageAsset,
			status: status ?? this.status,
			organizerId: organizerId ?? this.organizerId,
			createdAt: createdAt ?? this.createdAt,
			updatedAt: updatedAt ?? this.updatedAt,
			maxAttendees: maxAttendees ?? this.maxAttendees,
			currentAttendees: currentAttendees ?? this.currentAttendees,
			location: location ?? this.location,
			category: category ?? this.category,
		);
	}
}


