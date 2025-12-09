import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/notification_model.dart';

class NotificationHelper {
  // Get notification icon based on type
  static IconData getIcon(NotificationModel notification) {
    switch (notification.type) {
      case 'emergency':
        return Icons.warning_amber_rounded;
      case 'warning':
        return Icons.warning_rounded;
      case 'success':
        return Icons.check_circle_rounded;
      case 'reminder':
        return Icons.notifications_active_rounded;
      case 'info':
      default:
        return Icons.info_rounded;
    }
  }

  // Get notification color based on urgency
  static Color getColor(NotificationModel notification) {
    switch (notification.urgencyLevel) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow[700]!;
      case 'low':
      default:
        return Colors.green;
    }
  }

  // Get category display name
  static String getCategoryName(String category) {
    switch (category) {
      case 'kesehatan':
        return 'Kesehatan';
      case 'iuran':
        return 'Iuran';
      case 'jadwal':
        return 'Jadwal';
      case 'pengumuman':
        return 'Pengumuman';
      case 'system':
        return 'Sistem';
      default:
        return 'Lainnya';
    }
  }

  // Get urgency display name
  static String getUrgencyName(String urgency) {
    switch (urgency) {
      case 'critical':
        return 'Kritis';
      case 'high':
        return 'Tinggi';
      case 'medium':
        return 'Sedang';
      case 'low':
        return 'Rendah';
      default:
        return 'Normal';
    }
  }

  // Format notification preview text
  static String getPreviewText(NotificationModel notification) {
    final message = notification.message;
    if (message.length <= 100) return message;
    return '${message.substring(0, 100)}...';
  }

  // Check if notification should trigger local notification
  static bool shouldShowLocalNotification(NotificationModel notification) {
    // Only show for unread notifications
    if (notification.isRead) return false;
    
    // Don't show archived notifications
    if (notification.isArchived) return false;
    
    // Don't show expired notifications
    if (notification.isExpired) return false;
    
    // Don't show scheduled notifications that haven't arrived yet
    if (notification.isScheduled) return false;
    
    return true;
  }

  // Parse data from notification
  static Map<String, dynamic> parseNotificationData(
    NotificationModel notification,
  ) {
    final data = notification.data ?? {};
    
    // Add common fields
    data['notification_id'] = notification.id;
    data['type'] = notification.type;
    data['category'] = notification.category;
    data['urgency_level'] = notification.urgencyLevel;
    data['action_url'] = notification.actionUrl;
    
    return data;
  }

  // Generate notification title for local notification
  static String getLocalNotificationTitle(NotificationModel notification) {
    final sender = notification.sender?.name;
    final prefix = sender != null ? '$sender: ' : '';
    
    return '$prefix${notification.title}';
  }

  // Get notification action
  static NotificationAction? getNotificationAction(
    NotificationModel notification,
  ) {
    if (notification.actionUrl == null || notification.actionText == null) {
      return null;
    }
    
    return NotificationAction(
      id: notification.id,
      title: notification.actionText!,
      payload: notification.actionUrl,
    );
  }

  // Get time ago string
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  // Get icon based on category
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'kesehatan':
        return Icons.health_and_safety;
      case 'iuran':
        return Icons.payment;
      case 'jadwal':
        return Icons.schedule;
      case 'pengumuman':
        return Icons.announcement;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  // Get color based on category
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'kesehatan':
        return Colors.green;
      case 'iuran':
        return Colors.blue;
      case 'jadwal':
        return Colors.purple;
      case 'pengumuman':
        return Colors.orange;
      case 'system':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}

// Class untuk local notification action
class NotificationAction {
  final String id;
  final String title;
  final String? payload;

  NotificationAction({
    required this.id,
    required this.title,
    this.payload,
  });
}

// Helper untuk mengelola badge notifikasi
class NotificationBadgeHelper {
  static int calculateTotalBadge(
    int healthNotificationCount,
    int systemUnreadCount,
    bool hasUrgent,
  ) {
    // Prioritaskan notifikasi darurat
    if (hasUrgent) {
      return systemUnreadCount;
    }
    
    // Gabungkan kesehatan dan sistem
    return healthNotificationCount + systemUnreadCount;
  }

  static Color getBadgeColor(bool hasUrgent, int unreadCount) {
    if (hasUrgent) {
      return Colors.red;
    } else if (unreadCount > 0) {
      return Colors.orange;
    }
    return Colors.red; // Default merah
  }

  static String getBadgeText(int count) {
    if (count <= 0) return '';
    if (count > 9) return '9+';
    return count.toString();
  }
}