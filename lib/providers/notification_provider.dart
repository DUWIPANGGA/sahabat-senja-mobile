import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/notification_model.dart';
import 'package:sahabatsenja_app/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _totalUnread = 0;
  int _totalUrgent = 0;
  Map<String, dynamic> _statistics = {};

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _totalUnread;
  int get readCount => _notifications.where((n) => n.isRead).length;
  int get urgentCount => _totalUrgent;
  Map<String, dynamic> get statistics => _statistics;

  Future<void> loadNotifications({
    int page = 1,
    String? filter,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _notificationService.getNotifications(
        page: page,
        perPage: 20,
        type: filter == 'urgent' ? 'emergency' : null,
        category: ['kesehatan', 'iuran', 'jadwal', 'pengumuman', 'system']
            .contains(filter) ? filter : null,
        isRead: filter == 'read' ? true : filter == 'unread' ? false : null,
      );
      
      _notifications = response.data;
      _totalUnread = await _notificationService.getUnreadCount();
      _totalUrgent = await _notificationService.getUrgentCount();
      
      // Load statistics
      final stats = await _notificationService.getStatistics();
      _statistics = {
        'total': stats.total,
        'unread': stats.unread,
        'urgent': stats.urgent,
        'byType': stats.byType,
        'byCategory': stats.byCategory,
      };
      
    } catch (e) {
      print('❌ Error loading notifications in provider: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<NotificationModel>> loadMoreNotifications({
    int page = 1,
    String? filter,
  }) async {
    try {
      final response = await _notificationService.getNotifications(
        page: page,
        perPage: 20,
        type: filter == 'urgent' ? 'emergency' : null,
        category: ['kesehatan', 'iuran', 'jadwal', 'pengumuman', 'system']
            .contains(filter) ? filter : null,
        isRead: filter == 'read' ? true : filter == 'unread' ? false : null,
      );
      
      if (response.data.isNotEmpty) {
        _notifications.addAll(response.data);
        notifyListeners();
      }
      
      return response.data;
    } catch (e) {
      print('❌ Error loading more notifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _totalUnread = _totalUnread > 0 ? _totalUnread - 1 : 0;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<int> markAllAsRead() async {
    try {
      final count = await _notificationService.markAllAsRead();
      
      // Update local state
      for (var i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      
      _totalUnread = 0;
      notifyListeners();
      
      return count;
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      rethrow;
    }
  }

  Future<void> clearReadNotifications() async {
    try {
      await _notificationService.clearRead();
      
      // Update local state
      _notifications.removeWhere((n) => n.isRead);
      notifyListeners();
    } catch (e) {
      print('❌ Error clearing read notifications: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _notificationService.delete(id);
      
      // Update local state
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting notification: $e');
      rethrow;
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _totalUnread++;
    }
    if (notification.isUrgent) {
      _totalUrgent++;
    }
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    _totalUnread = 0;
    _totalUrgent = 0;
    notifyListeners();
  }
}