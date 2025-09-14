import 'package:flutter/foundation.dart';
import '../models/registration.dart';
import 'api_service.dart';

class RegistrationService extends ChangeNotifier {
  static RegistrationService? _instance;
  static RegistrationService get instance => _instance ??= RegistrationService._();
  
  RegistrationService._();
  
  final ApiService _apiService = ApiService.instance;
  
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);
  final ValueNotifier<List<RegistrationModel>> _myRegistrations = ValueNotifier<List<RegistrationModel>>([]);
  
  List<RegistrationModel> get myRegistrations => _myRegistrations.value;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMorePages = true;
  int get currentPage => _currentPage;
  bool get hasMorePages => _hasMorePages;
  
  // Load my registrations
  Future<void> loadMyRegistrations({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMorePages = true;
        _myRegistrations.value = [];
      }
      
      if (!_hasMorePages && !refresh) return;
      
      isLoading.value = true;
      error.value = null;
      
      final response = await _apiService.getMyRegistrations(page: _currentPage);
      
      if (response['data'] != null) {
        final List<dynamic> registrationsData = response['data'];
        
        final List<RegistrationModel> newRegistrations = registrationsData
            .map((json) => RegistrationModel.fromJson(json))
            .toList();
        
        if (refresh) {
          _myRegistrations.value = newRegistrations;
        } else {
          _myRegistrations.value = [..._myRegistrations.value, ...newRegistrations];
        }
        
        // Update pagination info
        _currentPage = response['current_page'] ?? _currentPage + 1;
        _hasMorePages = response['next_page_url'] != null;
      } else {
        error.value = response['message'] ?? 'Failed to load registrations';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load more registrations (pagination)
  Future<void> loadMoreRegistrations() async {
    if (!_hasMorePages || isLoading.value) return;
    
    _currentPage++;
    await loadMyRegistrations();
  }
  
  // Register for an event
  Future<Map<String, dynamic>> registerForEvent(int eventId) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response = await _apiService.registerForEvent(eventId);
      
      if (response['id'] != null) {
        // Registration successful
        final registration = RegistrationModel.fromJson(response);
        
        // Add to local list
        final currentRegistrations = List<RegistrationModel>.from(_myRegistrations.value);
        currentRegistrations.insert(0, registration);
        _myRegistrations.value = currentRegistrations;
        
        notifyListeners();
        
        return {
          'success': true,
          'registration': registration,
          'message': registration.onWaitlist 
              ? 'You have been added to the waitlist'
              : 'Registration successful!',
        };
      } else {
        final message = response['message'] ?? 'Failed to register for event';
        error.value = message;
        
        return {
          'success': false,
          'message': message,
          'error_type': _getErrorType(message),
        };
      }
    } catch (e) {
      error.value = e.toString();
      return {
        'success': false,
        'message': e.toString(),
        'error_type': 'unknown',
      };
    } finally {
      isLoading.value = false;
    }
  }
  
  // Unregister from an event
  Future<bool> unregisterFromEvent(int eventId) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response = await _apiService.unregisterFromEvent(eventId);
      
      if (response['message'] == 'unregistered') {
        // Remove from local list
        final currentRegistrations = List<RegistrationModel>.from(_myRegistrations.value);
        currentRegistrations.removeWhere((reg) => reg.eventId == eventId);
        _myRegistrations.value = currentRegistrations;
        
        notifyListeners();
        return true;
      } else {
        error.value = response['message'] ?? 'Failed to unregister from event';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Check if user is registered for an event
  bool isRegisteredForEvent(int eventId) {
    return _myRegistrations.value.any((reg) => reg.eventId == eventId);
  }
  
  // Get registration for an event
  RegistrationModel? getRegistrationForEvent(int eventId) {
    try {
      return _myRegistrations.value.firstWhere((reg) => reg.eventId == eventId);
    } catch (e) {
      return null;
    }
  }
  
  // Get confirmed registrations
  List<RegistrationModel> getConfirmedRegistrations() {
    return _myRegistrations.value.where((reg) => reg.isConfirmed).toList();
  }
  
  // Get pending registrations
  List<RegistrationModel> getPendingRegistrations() {
    return _myRegistrations.value.where((reg) => reg.isPending).toList();
  }
  
  // Get waitlist registrations
  List<RegistrationModel> getWaitlistRegistrations() {
    return _myRegistrations.value.where((reg) => reg.onWaitlist).toList();
  }
  
  // Get upcoming registrations (future events)
  List<RegistrationModel> getUpcomingRegistrations() {
    final now = DateTime.now();
    return _myRegistrations.value.where((reg) {
      if (reg.event?['date'] == null) return false;
      final eventDate = DateTime.tryParse(reg.event!['date']);
      return eventDate != null && eventDate.isAfter(now);
    }).toList();
  }
  
  // Get past registrations (past events)
  List<RegistrationModel> getPastRegistrations() {
    final now = DateTime.now();
    return _myRegistrations.value.where((reg) {
      if (reg.event?['date'] == null) return false;
      final eventDate = DateTime.tryParse(reg.event!['date']);
      return eventDate != null && eventDate.isBefore(now);
    }).toList();
  }
  
  // Get error type for handling different error cases
  String _getErrorType(String message) {
    if (message.contains('email_unverified')) return 'email_unverified';
    if (message.contains('profile_incomplete')) return 'profile_incomplete';
    if (message.contains('event_full')) return 'event_full';
    if (message.contains('already_registered')) return 'already_registered';
    return 'unknown';
  }
  
  // Clear error
  void clearError() {
    error.value = null;
  }
  
  // Clear all data
  void clearAll() {
    _myRegistrations.value = [];
    _currentPage = 1;
    _hasMorePages = true;
    error.value = null;
    notifyListeners();
  }
  
  // Refresh registrations
  Future<void> refresh() async {
    await loadMyRegistrations(refresh: true);
  }
}
