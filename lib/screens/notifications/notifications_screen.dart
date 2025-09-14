import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../../models/notification.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load notifications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().loadNotifications(refresh: true);
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<NotificationService>().loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        actions: [
          Consumer<NotificationService>(
            builder: (context, notificationService, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'mark_all_read':
                      notificationService.markAllAsRead();
                      break;
                    case 'refresh':
                      notificationService.refresh();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, size: 20),
                        SizedBox(width: 8),
                        Text('Mark all as read'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(Icons.more_vert, color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationService>(
        builder: (context, notificationService, child) {
          return _buildNotificationsList(notificationService);
        },
      ),
    );
  }
  
  Widget _buildNotificationsList(NotificationService notificationService) {
    if (notificationService.isLoading.value && notificationService.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        ),
      );
    }
    
    if (notificationService.error.value != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notificationService.error.value!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notificationService.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (notificationService.notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => notificationService.refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: notificationService.notifications.length + 
                   (notificationService.hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= notificationService.notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                ),
              ),
            );
          }
          
          final notification = notificationService.notifications[index];
          return _buildNotificationCard(notification, notificationService);
        },
      ),
    );
  }
  
  Widget _buildNotificationCard(NotificationModel notification, NotificationService notificationService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isUnread ? 3 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification, notificationService),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isUnread 
                ? const Color(0xFF6C63FF).withOpacity(0.05)
                : Colors.white,
            border: notification.isUnread 
                ? Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2))
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification),
                  color: _getNotificationColor(notification),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isUnread 
                                  ? FontWeight.bold 
                                  : FontWeight.w500,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          notification.formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Message
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Type badge
                    if (notification.type != 'system')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getNotificationColor(notification).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getNotificationTypeName(notification.type),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getNotificationColor(notification),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Unread indicator
              if (notification.isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getNotificationIcon(NotificationModel notification) {
    switch (notification.type) {
      case 'event': return Icons.event;
      case 'registration': return Icons.person_add;
      case 'attendance': return Icons.check_circle;
      case 'certificate': return Icons.workspace_premium;
      case 'system': return Icons.info;
      default: return Icons.notifications;
    }
  }
  
  Color _getNotificationColor(NotificationModel notification) {
    switch (notification.type) {
      case 'event': return const Color(0xFF6C63FF);
      case 'registration': return const Color(0xFF4CAF50);
      case 'attendance': return const Color(0xFF2196F3);
      case 'certificate': return const Color(0xFFFF9800);
      case 'system': return const Color(0xFF9E9E9E);
      default: return const Color(0xFF6C63FF);
    }
  }
  
  String _getNotificationTypeName(String type) {
    switch (type) {
      case 'event': return 'Event';
      case 'registration': return 'Registration';
      case 'attendance': return 'Attendance';
      case 'certificate': return 'Certificate';
      case 'system': return 'System';
      default: return 'Notification';
    }
  }
  
  void _handleNotificationTap(NotificationModel notification, NotificationService notificationService) {
    // Mark as read if unread
    if (notification.isUnread) {
      notificationService.markAsRead(notification.id);
    }
    
    // Handle navigation based on notification type and data
    if (notification.data != null) {
      final data = notification.data!;
      
      switch (notification.type) {
        case 'event':
          if (data['event_id'] != null) {
            // Navigate to event detail
            // Navigator.pushNamed(context, EventDetailScreen.routeName, arguments: data['event_id']);
          }
          break;
        case 'registration':
          if (data['event_id'] != null) {
            // Navigate to event detail or registration
            // Navigator.pushNamed(context, EventDetailScreen.routeName, arguments: data['event_id']);
          }
          break;
        case 'attendance':
          if (data['event_id'] != null) {
            // Navigate to attendance screen
            // Navigator.pushNamed(context, AttendanceScreen.routeName, arguments: data['event_id']);
          }
          break;
        case 'certificate':
          if (data['certificate_id'] != null) {
            // Navigate to certificate detail
            // Navigator.pushNamed(context, CertificateDetailScreen.routeName, arguments: data['certificate_id']);
          }
          break;
      }
    }
  }
}
