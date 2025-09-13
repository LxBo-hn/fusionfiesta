import 'package:flutter/foundation.dart';
import '../models/event.dart';

class RegistrationStore {
	RegistrationStore._();
	static final RegistrationStore instance = RegistrationStore._();

	final ValueNotifier<List<EventModel>> registeredEvents = ValueNotifier<List<EventModel>>(<EventModel>[]);

	void register(EventModel event) {
		final List<EventModel> current = List<EventModel>.from(registeredEvents.value);
		final bool exists = current.any((e) => e.id == event.id);
		if (!exists) {
			current.add(event);
			registeredEvents.value = current;
		}
	}

	void unregister(String eventId) {
		final List<EventModel> current = List<EventModel>.from(registeredEvents.value);
		current.removeWhere((e) => e.id == eventId);
		registeredEvents.value = current;
	}

	void clear() {
		registeredEvents.value = <EventModel>[];
	}
} 