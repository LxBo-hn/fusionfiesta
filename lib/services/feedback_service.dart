import 'package:flutter/foundation.dart';
import '../models/feedback.dart';
import 'api_service.dart';

class FeedbackService extends ChangeNotifier {
  static FeedbackService? _instance;
  static FeedbackService get instance => _instance ??= FeedbackService._();
  
  FeedbackService._();
  
  final ApiService _apiService = ApiService.instance;
  
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);
  final ValueNotifier<Map<int, FeedbackModel>> _eventFeedbacks = ValueNotifier<Map<int, FeedbackModel>>({});
  
  Map<int, FeedbackModel> get eventFeedbacks => _eventFeedbacks.value;
  
  // Get feedback for a specific event
  FeedbackModel? getFeedbackForEvent(int eventId) {
    return _eventFeedbacks.value[eventId];
  }
  
  // Submit feedback for an event
  Future<bool> submitFeedback({
    required int eventId,
    required int rating,
    String? comment,
    int? organizationRating,
    int? relevanceRating,
    int? coordinationRating,
    int? overallExperienceRating,
  }) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response = await _apiService.submitFeedback(
        eventId, 
        rating, 
        comment: comment,
        organizationRating: organizationRating,
        relevanceRating: relevanceRating,
        coordinationRating: coordinationRating,
        overallExperienceRating: overallExperienceRating,
      );
      
      if (response['id'] != null) {
        // Update local feedback
        final feedback = FeedbackModel.fromJson(response);
        final currentFeedbacks = Map<int, FeedbackModel>.from(_eventFeedbacks.value);
        currentFeedbacks[eventId] = feedback;
        _eventFeedbacks.value = currentFeedbacks;
        
        notifyListeners();
        return true;
      } else {
        error.value = response['message'] ?? 'Failed to submit feedback';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load feedback for an event
  Future<void> loadEventFeedback(int eventId) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response = await _apiService.getEventFeedback(eventId);
      
      if (response['id'] != null) {
        // Update local feedback
        final feedback = FeedbackModel.fromJson(response);
        final currentFeedbacks = Map<int, FeedbackModel>.from(_eventFeedbacks.value);
        currentFeedbacks[eventId] = feedback;
        _eventFeedbacks.value = currentFeedbacks;
      } else {
        // No feedback exists for this event
        final currentFeedbacks = Map<int, FeedbackModel>.from(_eventFeedbacks.value);
        currentFeedbacks.remove(eventId);
        _eventFeedbacks.value = currentFeedbacks;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Check if user has already given feedback for an event
  bool hasFeedbackForEvent(int eventId) {
    return _eventFeedbacks.value.containsKey(eventId);
  }
  
  // Get rating for an event
  int? getRatingForEvent(int eventId) {
    return _eventFeedbacks.value[eventId]?.rating;
  }
  
  // Get comment for an event
  String? getCommentForEvent(int eventId) {
    return _eventFeedbacks.value[eventId]?.comment;
  }
  
  // Clear error
  void clearError() {
    error.value = null;
  }
  
  // Clear all feedback data
  void clearAll() {
    _eventFeedbacks.value = {};
    error.value = null;
    notifyListeners();
  }
}
