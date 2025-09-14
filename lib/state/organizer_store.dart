import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../models/api_event.dart';
import '../models/registration.dart';
import '../services/api_service.dart';

class OrganizerStore extends ChangeNotifier {
	OrganizerStore._();
	static final OrganizerStore instance = OrganizerStore._();

	final ValueNotifier<List<EventModel>> events = ValueNotifier<List<EventModel>>([]);
	final ValueNotifier<List<String>> attendance = ValueNotifier<List<String>>([]);
	final ValueNotifier<List<String>> mediaAssets = ValueNotifier<List<String>>([]);
	final ValueNotifier<Map<int, List<RegistrationModel>>> eventRegistrants = ValueNotifier<Map<int, List<RegistrationModel>>>({});
	final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
	final ValueNotifier<String?> error = ValueNotifier<String?>(null);

	final ApiService _apiService = ApiService.instance;

	// Load events from API
	Future<void> loadEvents() async {
		try {
			isLoading.value = true;
			error.value = null;
			
			print('🔄 Loading events from API...');
			final response = await _apiService.getEvents();
			print('📥 API Response: $response');
			
			if (response['data'] != null) {
				final List<dynamic> eventsData = response['data'] ?? [];
				print('📊 Events data: $eventsData');
				
				final List<EventModel> eventList = [];
				for (final json in eventsData) {
					try {
						final apiEvent = ApiEventModel.fromJson(json);
						final eventModel = EventModel.fromJson(apiEvent.toEventModelJson());
						eventList.add(eventModel);
					} catch (e) {
						print('⚠️ Error parsing event: $e');
						print('⚠️ Event data: $json');
						// Skip this event and continue with others
						continue;
					}
				}
				
				events.value = eventList;
				print('✅ Loaded ${events.value.length} events from API');
			} else {
				error.value = response['message'] ?? 'Failed to load events';
				print('❌ API Error: ${error.value}');
			}
		} catch (e) {
			error.value = e.toString();
			print('💥 Exception: $e');
		} finally {
			isLoading.value = false;
		}
	}
	

	// Create event via API
	Future<bool> createEvent(EventModel event) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.createEvent(event.toJson());
			if (response['success']) {
				// Reload events to get updated list
				await loadEvents();
				return true;
			} else {
				error.value = response['message'] ?? 'Failed to create event';
				return false;
			}
		} catch (e) {
			error.value = e.toString();
			return false;
		} finally {
			isLoading.value = false;
		}
	}

	// Update event via API
	Future<bool> updateEvent(EventModel event) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.updateEvent(event.id, event.toJson());
			if (response['success']) {
				// Update local list
				final list = List<EventModel>.from(events.value);
				final idx = list.indexWhere((e) => e.id == event.id);
				if (idx != -1) {
					list[idx] = event;
					events.value = list;
				}
				return true;
			} else {
				error.value = response['message'] ?? 'Failed to update event';
				return false;
			}
		} catch (e) {
			error.value = e.toString();
			return false;
		} finally {
			isLoading.value = false;
		}
	}

	// Delete event via API
	Future<bool> deleteEvent(String eventId) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.deleteEvent(eventId);
			if (response['success']) {
				// Remove from local list
				final list = List<EventModel>.from(events.value)..removeWhere((e) => e.id == eventId);
				events.value = list;
				return true;
			} else {
				error.value = response['message'] ?? 'Failed to delete event';
				return false;
			}
		} catch (e) {
			error.value = e.toString();
			return false;
		} finally {
			isLoading.value = false;
		}
	}

	// Load attendance for an event
	Future<void> loadAttendance(String eventId) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.getAttendance(eventId);
			if (response['success']) {
				final List<dynamic> attendanceData = response['data'] ?? [];
				attendance.value = attendanceData
					.map((item) => item['qrCode']?.toString() ?? '')
					.where((code) => code.isNotEmpty)
					.toList();
			} else {
				error.value = response['message'] ?? 'Failed to load attendance';
			}
		} catch (e) {
			error.value = e.toString();
		} finally {
			isLoading.value = false;
		}
	}

	// Check in attendance via API
	Future<bool> checkInAttendance(String eventId, String checkinCode) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.checkIn(eventId, checkinCode);
			if (response['checked_in_at'] != null) {
				// Add to local list
				final list = List<String>.from(attendance.value)..add(checkinCode);
				attendance.value = list;
				return true;
			} else {
				error.value = response['message'] ?? 'Failed to check in';
				return false;
			}
		} catch (e) {
			error.value = e.toString();
			return false;
		} finally {
			isLoading.value = false;
		}
	}

	// Load media for an event
	Future<void> loadMedia(String eventId) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.getMedia(eventId);
			if (response['success']) {
				final List<dynamic> mediaData = response['data'] ?? [];
				mediaAssets.value = mediaData
					.map((item) => item['filePath']?.toString() ?? '')
					.where((path) => path.isNotEmpty)
					.toList();
			} else {
				error.value = response['message'] ?? 'Failed to load media';
			}
		} catch (e) {
			error.value = e.toString();
		} finally {
			isLoading.value = false;
		}
	}

	// Upload media via API
	Future<bool> uploadMedia(String eventId, String filePath) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.uploadMedia(eventId, filePath);
			if (response['success']) {
				// Add to local list
				final list = List<String>.from(mediaAssets.value)..add(filePath);
				mediaAssets.value = list;
				return true;
			} else {
				error.value = response['message'] ?? 'Failed to upload media';
				return false;
			}
		} catch (e) {
			error.value = e.toString();
			return false;
		} finally {
			isLoading.value = false;
		}
	}

	// Load registrants for an event
	Future<void> loadEventRegistrants(int eventId) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.getEventRegistrants(eventId);
			if (response['data'] != null) {
				final List<dynamic> registrantsData = response['data'];
				final List<RegistrationModel> registrants = registrantsData
					.map((json) => RegistrationModel.fromJson(json))
					.toList();
				
				// Update local map
				final currentRegistrants = Map<int, List<RegistrationModel>>.from(eventRegistrants.value);
				currentRegistrants[eventId] = registrants;
				eventRegistrants.value = currentRegistrants;
			} else {
				error.value = response['message'] ?? 'Failed to load registrants';
			}
		} catch (e) {
			error.value = e.toString();
		} finally {
			isLoading.value = false;
		}
	}
	
	// Get registrants for a specific event
	List<RegistrationModel> getRegistrantsForEvent(int eventId) {
		return eventRegistrants.value[eventId] ?? [];
	}
	
	// Get registrant count for an event
	int getRegistrantCountForEvent(int eventId) {
		return getRegistrantsForEvent(eventId).length;
	}
	
	// Get approved registrants for an event
	List<RegistrationModel> getApprovedRegistrantsForEvent(int eventId) {
		return getRegistrantsForEvent(eventId).where((r) => r.isApproved).toList();
	}
	
	// Get pending registrants for an event
	List<RegistrationModel> getPendingRegistrantsForEvent(int eventId) {
		return getRegistrantsForEvent(eventId).where((r) => r.isPending).toList();
	}

	// Clear error
	void clearError() {
		error.value = null;
	}
}
