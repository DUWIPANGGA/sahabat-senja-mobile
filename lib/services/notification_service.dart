import 'package:sahabatsenja_app/models/notification_model.dart';
import 'package:sahabatsenja_app/services/api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  // Get all notifications with pagination and filters
  Future<PaginatedNotifications> getNotifications({
    int page = 1,
    int perPage = 20,
    String? type,
    String? category,
    bool? isRead,
    bool? isArchived,
    String? urgencyLevel,
    String? search,
  }) async {
    final params = {
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (isRead != null) 'is_read': isRead.toString(),
      if (isArchived != null) 'is_archived': isArchived.toString(),
      if (urgencyLevel != null) 'urgency_level': urgencyLevel,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _apiService.get('notifications', params: params);
    
    return PaginatedNotifications.fromJson(response['data']);
  }

  // Get notification by ID
  Future<NotificationModel> getNotificationById(String id) async {
    final response = await _apiService.get('notifications/$id');
    return NotificationModel.fromJson(response['data']);
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    final response = await _apiService.get('notifications/unread-count');
    return response['count'] ?? 0;
  }
  Future<int> getUrgentCount() async {
      try {
        final response = await _apiService.get('notifications/urgent');
        if (response['data'] is List) {
          return (response['data'] as List).length;
        }
        return 0;
      } catch (e) {
        print('❌ Error getting urgent count: $e');
        return 0;
      }
  }
  // Get urgent notifications
  Future<List<NotificationModel>> getUrgentNotifications() async {
    final response = await _apiService.get('notifications/urgent');
    return (response['data'] as List)
        .map((item) => NotificationModel.fromJson(item))
        .toList();
  }

  // Get statistics
  Future<NotificationStatistics> getStatistics() async {
    final response = await _apiService.get('notifications/statistics');
    return NotificationStatistics.fromJson(response['data']);
  }

  // Mark notification as read
  Future<NotificationModel> markAsRead(String id) async {
    final response = await _apiService.post('notifications/$id/read', {});
    return NotificationModel.fromJson(response['data']);
  }

  // Mark all notifications as read
  Future<int> markAllAsRead() async {
    final response = await _apiService.post('notifications/read-all', {});
    return response['count'] ?? 0;
  }

  // Archive notification
  Future<NotificationModel> archive(String id) async {
    final response = await _apiService.post('notifications/$id/archive', {});
    return NotificationModel.fromJson(response['data']);
  }

  // Mark as action taken
  Future<NotificationModel> markAsActionTaken(String id) async {
    final response = await _apiService.post('notifications/$id/action-taken', {});
    return NotificationModel.fromJson(response['data']);
  }

  // Delete notification
  Future<void> delete(String id) async {
    await _apiService.delete('notifications/$id');
  }

  // Clear all read notifications
  Future<int> clearRead() async {
    final response = await _apiService.delete('notifications/clear/read');
    return response['count'] ?? 0;
  }

  // Create notification (admin/perawat only)
  Future<NotificationModel> createNotification(
    CreateNotificationRequest request,
  ) async {
    final response = await _apiService.post(
      'notifications/send',
      request.toJson(),
    );
    return NotificationModel.fromJson(response['data']);
  }

  // Send batch notifications (admin/perawat only)
  Future<List<NotificationModel>> sendBatchNotifications(
    BatchNotificationRequest request,
  ) async {
    final response = await _apiService.post(
      'notifications/send-batch',
      request.toJson(),
    );
    return (response['data'] as List)
        .map((item) => NotificationModel.fromJson(item))
        .toList();
  }
}