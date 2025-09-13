import 'package:flutter/foundation.dart';
import '../models/event.dart';

class OrganizerStore {
	OrganizerStore._();
	static final OrganizerStore instance = OrganizerStore._();

	final ValueNotifier<List<EventModel>> events = ValueNotifier<List<EventModel>>(<EventModel>[
		const EventModel(id: 'e1', title: 'Hackathon 2025', dateText: '20-10-2025', description: '24h coding marathon', imageAsset: 'assets/splash/onboarding_1.png'),
		const EventModel(id: 'e2', title: 'Seminar AI', dateText: '05-11-2025', description: 'Talk about AI trends', imageAsset: 'assets/splash/onboarding_2.png'),
	]);

	final ValueNotifier<List<String>> attendance = ValueNotifier<List<String>>(<String>[]);

	final ValueNotifier<List<String>> mediaAssets = ValueNotifier<List<String>>(<String>[
		'assets/splash/onboarding_1.png',
		'assets/splash/onboarding_2.png',
		'assets/splash/onboarding_3.png',
	]);

	void addEvent(EventModel event) {
		final list = List<EventModel>.from(events.value)..add(event);
		events.value = list;
	}

	void updateEvent(EventModel updated) {
		final list = List<EventModel>.from(events.value);
		final idx = list.indexWhere((e) => e.id == updated.id);
		if (idx != -1) {
			list[idx] = updated;
			events.value = list;
		}
	}

	void deleteEvent(String id) {
		final list = List<EventModel>.from(events.value)..removeWhere((e) => e.id == id);
		events.value = list;
	}

	void addAttendance(String code) {
		final list = List<String>.from(attendance.value)..add(code);
		attendance.value = list;
	}

	void addMedia(String assetPath) {
		final list = List<String>.from(mediaAssets.value)..add(assetPath);
		mediaAssets.value = list;
	}
}
