import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

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
	final DateTime? startAt;
	final DateTime? endAt;

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
		this.startAt,
		this.endAt,
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
		DateTime? startAt,
		DateTime? endAt,
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
			startAt: startAt ?? this.startAt,
			endAt: endAt ?? this.endAt,
		);
	}

	// Event status based on time
	EventStatus get eventStatus {
		if (startAt == null || endAt == null) return EventStatus.unknown;
		
		final now = DateTime.now();
		if (now.isBefore(startAt!)) {
			return EventStatus.upcoming;
		} else if (now.isAfter(endAt!)) {
			return EventStatus.completed;
		} else {
			return EventStatus.ongoing;
		}
	}

	// Get status display text
	String get statusDisplayText {
		switch (eventStatus) {
			case EventStatus.upcoming:
				return 'Sắp diễn ra';
			case EventStatus.ongoing:
				return 'Đang diễn ra';
			case EventStatus.completed:
				return 'Đã diễn ra';
			case EventStatus.unknown:
				return 'Không xác định';
		}
	}

	// Get status color
	Color get statusColor {
		switch (eventStatus) {
			case EventStatus.upcoming:
				return Colors.blue;
			case EventStatus.ongoing:
				return Colors.green;
			case EventStatus.completed:
				return Colors.grey;
			case EventStatus.unknown:
				return Colors.orange;
		}
	}
}

enum EventStatus {
	upcoming,
	ongoing,
	completed,
	unknown,
}


