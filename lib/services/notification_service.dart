import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import 'api_service.dart';

class NotificationService extends ChangeNotifier {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();
  
  final ApiService _apiService = ApiService.instance;
  
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);
  final ValueNotifier<List<NotificationModel>> _notifications = ValueNotifier<List<NotificationModel>>([]);
  final ValueNotifier<int> _unreadCount = ValueNotifier<int>(0);
  
  List<NotificationModel> get notifications => _notifications.value;
  int get unreadCount => _unreadCount.value;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMorePages = true;
  int get currentPage => _currentPage;
  bool get hasMorePages => _hasMorePages;
  
  // Load notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMorePages = true;
        _notifications.value = [];
      }
      
      if (!_hasMorePages && !refresh) return;
      
      isLoading.value = true;
      error.value = null;
      
      final response = await _apiService.getNotifications(page: _currentPage);
      
      if (response['data'] != null) {
        final List<dynamic> notificationData = response['data'];
        final List<NotificationModel> newNotifications = notificationData
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        
        if (refresh) {
          _notifications.value = newNotifications;
        } else {
          _notifications.value = [..._notifications.value, ...newNotifications];
        }
        
        // Update pagination info
        _currentPage = response['current_page'] ?? _currentPage + 1;
        _hasMorePages = response['next_page_url'] != null;
        
        // Update unread count
        _updateUnreadCount();
      } else {
        error.value = response['message'] ?? 'Failed to load notifications';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (!_hasMorePages || isLoading.value) return;
    
    _currentPage++;
    await loadNotifications();
  }
  
  // Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response = await _apiService.markNotificationRead(notificationId);
      
      if (response['message'] == 'ok') {
        // Update local notification
        final updatedNotifications = _notifications.value.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(readAt: DateTime.now());
          }
          return notification;
        }).toList();
        _notifications.value = updatedNotifications;
        
        // Update unread count
        _updateUnreadCount();
        
        notifyListeners();
        return true;
      } else {
        error.value = response['message'] ?? 'Failed to mark notification as read';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final unreadNotifications = _notifications.value.where((n) => n.isUnread).toList();
    
    for (final notification in unreadNotifications) {
      await markAsRead(notification.id);
    }
  }
  
  // Get notification by ID
  NotificationModel? getNotificationById(int id) {
    try {
      return _notifications.value.firstWhere((notification) => notification.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.value.where((notification) => notification.isUnread).toList();
  }
  
  // Get read notifications
  List<NotificationModel> getReadNotifications() {
    return _notifications.value.where((notification) => notification.isRead).toList();
  }
  
  // Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.value.where((notification) => notification.type == type).toList();
  }
  
  // Get recent notifications (last 7 days)
  List<NotificationModel> getRecentNotifications() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    return _notifications.value.where((notification) {
      if (notification.createdAt == null) return false;
      return notification.createdAt!.isAfter(weekAgo);
    }).toList();
  }
  
  // Update unread count
  void _updateUnreadCount() {
    _unreadCount.value = _notifications.value.where((n) => n.isUnread).length;
  }
  
  // Clear error
  void clearError() {
    error.value = null;
  }
  
  // Clear all data
  void clearAll() {
    _notifications.value = [];
    _unreadCount.value = 0;
    _currentPage = 1;
    _hasMorePages = true;
    error.value = null;
    notifyListeners();
  }
  
  // Refresh notifications
  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }
  
  // Simulate new notification (for testing)
  void addTestNotification() {
    final testNotification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: 1,
      type: 'system',
      title: 'Test Notification',
      message: 'This is a test notification',
      createdAt: DateTime.now(),
    );
    
    _notifications.value = [testNotification, ..._notifications.value];
    _updateUnreadCount();
    notifyListeners();
  }
}
