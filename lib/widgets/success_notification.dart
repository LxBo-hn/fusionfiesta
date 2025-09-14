import 'package:flutter/material.dart';

enum NotificationType {
  success,
  warning,
  error,
}

class SuccessNotification extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  final Duration duration;
  final NotificationType type;
  final VoidCallback? onAction;

  const SuccessNotification({
    super.key,
    required this.title,
    required this.message,
    this.onDismiss,
    this.duration = const Duration(seconds: 3),
    this.type = NotificationType.success,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with animation based on type
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getIconColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(),
              color: _getIconColor(),
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Đóng'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAction ?? onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getIconColor(),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_getButtonText()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getIcon() {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
    }
  }

  String _getButtonText() {
    switch (type) {
      case NotificationType.success:
        return 'Xem QR Code';
      case NotificationType.warning:
        return 'Đăng ký ngay';
      case NotificationType.error:
        return 'Thử lại';
    }
  }

  // Show success notification as overlay
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 3),
    NotificationType type = NotificationType.success,
    VoidCallback? onAction, // Thêm callback cho action button
  }) {
    // Show overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessNotification(
        title: title,
        message: message,
        onDismiss: () {
          Navigator.of(context).pop();
          onDismiss?.call();
        },
        onAction: onAction,
        duration: duration,
        type: type,
      ),
    );

    // Auto dismiss after duration
    Future.delayed(duration, () {
      if (context.mounted) {
        Navigator.of(context).pop();
        onDismiss?.call();
      }
    });
  }
}

// Success snackbar for quick notifications
class SuccessSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
