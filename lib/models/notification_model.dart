import 'dart:convert';

import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String? senderId;
  final String? datalansiaId;
  final String type;
  final String category;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final String? actionText;
  final String urgencyLevel;
  final bool isRead;
  final bool isArchived;
  final bool isActionTaken;
  final DateTime? readAt;
  final DateTime? actionTakenAt;
  final DateTime? scheduledAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Sender? sender;
  final Datalansia? datalansia;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.senderId,
    this.datalansiaId,
    required this.type,
    required this.category,
    required this.title,
    required this.message,
    this.data,
    this.actionUrl,
    this.actionText,
    required this.urgencyLevel,
    required this.isRead,
    required this.isArchived,
    required this.isActionTaken,
    this.readAt,
    this.actionTakenAt,
    this.scheduledAt,
    this.expiresAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.sender,
    this.datalansia,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString(),
      datalansiaId: json['datalansia_id']?.toString(),
      type: json['type'] ?? 'info',
      category: json['category'] ?? 'system',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
      actionUrl: json['action_url'],
      actionText: json['action_text'],
      urgencyLevel: json['urgency_level'] ?? 'medium',
      isRead: json['is_read'] ?? false,
      isArchived: json['is_archived'] ?? false,
      isActionTaken: json['is_action_taken'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      actionTakenAt: json['action_taken_at'] != null 
          ? DateTime.parse(json['action_taken_at']) 
          : null,
      scheduledAt: json['scheduled_at'] != null 
          ? DateTime.parse(json['scheduled_at']) 
          : null,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      metadata: json['metadata'] is Map 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at']) 
          : null,
      sender: json['sender'] != null 
          ? Sender.fromJson(json['sender']) 
          : null,
      datalansia: json['datalansia'] != null 
          ? Datalansia.fromJson(json['datalansia']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'sender_id': senderId,
      'datalansia_id': datalansiaId,
      'type': type,
      'category': category,
      'title': title,
      'message': message,
      'data': data,
      'action_url': actionUrl,
      'action_text': actionText,
      'urgency_level': urgencyLevel,
      'is_read': isRead,
      'is_archived': isArchived,
      'is_action_taken': isActionTaken,
      'read_at': readAt?.toIso8601String(),
      'action_taken_at': actionTakenAt?.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'sender': sender?.toJson(),
      'datalansia': datalansia?.toJson(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? senderId,
    String? datalansiaId,
    String? type,
    String? category,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? actionText,
    String? urgencyLevel,
    bool? isRead,
    bool? isArchived,
    bool? isActionTaken,
    DateTime? readAt,
    DateTime? actionTakenAt,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    Sender? sender,
    Datalansia? datalansia,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      senderId: senderId ?? this.senderId,
      datalansiaId: datalansiaId ?? this.datalansiaId,
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      actionText: actionText ?? this.actionText,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
      isActionTaken: isActionTaken ?? this.isActionTaken,
      readAt: readAt ?? this.readAt,
      actionTakenAt: actionTakenAt ?? this.actionTakenAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      sender: sender ?? this.sender,
      datalansia: datalansia ?? this.datalansia,
    );
  }

  // Helper methods
  bool get isUrgent => urgencyLevel == 'high' || urgencyLevel == 'critical';
  bool get isEmergency => type == 'emergency';
  bool get isReminder => type == 'reminder';
  bool get isInfo => type == 'info';
  bool get isSuccess => type == 'success';
  bool get isWarning => type == 'warning';
  
  bool get isExpired {
    if (expiresAt == null) return false;
    return expiresAt!.isBefore(DateTime.now());
  }
  
  bool get isScheduled {
    if (scheduledAt == null) return false;
    return scheduledAt!.isAfter(DateTime.now());
  }

  // Get icon based on type
  String get typeIcon {
    switch (type) {
      case 'emergency':
        return '🚨';
      case 'warning':
        return '⚠️';
      case 'success':
        return '✅';
      case 'reminder':
        return '⏰';
      case 'info':
      default:
        return 'ℹ️';
    }
  }

  // Get color based on urgency
  int get urgencyColor {
    switch (urgencyLevel) {
      case 'critical':
        return 0xFFFF5252; // Red
      case 'high':
        return 0xFFFF9800; // Orange
      case 'medium':
        return 0xFFFFEB3B; // Yellow
      case 'low':
      default:
        return 0xFF4CAF50; // Green
    }
  }

  // Format time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
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

  @override
  List<Object?> get props => [
    id,
    userId,
    senderId,
    datalansiaId,
    type,
    category,
    title,
    message,
    data,
    actionUrl,
    actionText,
    urgencyLevel,
    isRead,
    isArchived,
    isActionTaken,
    readAt,
    actionTakenAt,
    scheduledAt,
    expiresAt,
    metadata,
    createdAt,
    updatedAt,
    deletedAt,
    sender,
    datalansia,
  ];

  @override
  bool get stringify => true;
}

class Sender extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;

  const Sender({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  @override
  List<Object?> get props => [id, name, email, role];
}

class Datalansia extends Equatable {
  final String id;
  final String namaLansia;
  final int? umurLansia;

  const Datalansia({
    required this.id,
    required this.namaLansia,
    this.umurLansia,
  });

  factory Datalansia.fromJson(Map<String, dynamic> json) {
    return Datalansia(
      id: json['id']?.toString() ?? '',
      namaLansia: json['nama_lansia'] ?? '',
      umurLansia: json['umur_lansia'] != null 
          ? int.tryParse(json['umur_lansia'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lansia': namaLansia,
      'umur_lansia': umurLansia,
    };
  }

  @override
  List<Object?> get props => [id, namaLansia, umurLansia];
}

// Model untuk response paginated
class NotificationResponse {
  final String status;
  final List<NotificationModel> data;
  final Map<String, dynamic> counts;
  final String message;

  NotificationResponse({
    required this.status,
    required this.data,
    required this.counts,
    required this.message,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: json['status'] ?? 'error',
      data: json['data'] != null && json['data']['data'] is List
          ? (json['data']['data'] as List)
              .map((item) => NotificationModel.fromJson(item))
              .toList()
          : [],
      counts: json['counts'] is Map 
          ? Map<String, dynamic>.from(json['counts']) 
          : {},
      message: json['message'] ?? '',
    );
  }
}

// Model untuk paginated data
class PaginatedNotifications {
  final List<NotificationModel> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginatedNotifications({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) {
    return PaginatedNotifications(
      data: json['data'] is List
          ? (json['data'] as List)
              .map((item) => NotificationModel.fromJson(item))
              .toList()
          : [],
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
    );
  }

  bool get hasMore => currentPage < lastPage;
}

// Model untuk unread count response
class UnreadCountResponse {
  final String status;
  final int count;
  final String message;

  UnreadCountResponse({
    required this.status,
    required this.count,
    required this.message,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      status: json['status'] ?? 'error',
      count: json['count'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

// Model untuk urgent notifications response
class UrgentNotificationsResponse {
  final String status;
  final List<NotificationModel> data;
  final String message;

  UrgentNotificationsResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory UrgentNotificationsResponse.fromJson(Map<String, dynamic> json) {
    return UrgentNotificationsResponse(
      status: json['status'] ?? 'error',
      data: json['data'] is List
          ? (json['data'] as List)
              .map((item) => NotificationModel.fromJson(item))
              .toList()
          : [],
      message: json['message'] ?? '',
    );
  }
}

// Model untuk statistics response
class NotificationStatistics {
  final int total;
  final int unread;
  final int archived;
  final int urgent;
  final Map<String, int> byType;
  final Map<String, int> byCategory;

  NotificationStatistics({
    required this.total,
    required this.unread,
    required this.archived,
    required this.urgent,
    required this.byType,
    required this.byCategory,
  });

  factory NotificationStatistics.fromJson(Map<String, dynamic> json) {
    return NotificationStatistics(
      total: json['total'] ?? 0,
      unread: json['unread'] ?? 0,
      archived: json['archived'] ?? 0,
      urgent: json['urgent'] ?? 0,
      byType: json['by_type'] is Map
          ? Map<String, int>.from(
              json['by_type'].map((key, value) => 
                MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0)))
          : {},
      byCategory: json['by_category'] is Map
          ? Map<String, int>.from(
              json['by_category'].map((key, value) => 
                MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0)))
          : {},
    );
  }
}

// Model untuk create notification request
class CreateNotificationRequest {
  final String userId;
  final String type;
  final String category;
  final String title;
  final String message;
  final String? urgencyLevel;
  final String? datalansiaId;
  final String? actionUrl;
  final String? actionText;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? metadata;
  final DateTime? scheduledAt;
  final DateTime? expiresAt;

  CreateNotificationRequest({
    required this.userId,
    required this.type,
    required this.category,
    required this.title,
    required this.message,
    this.urgencyLevel,
    this.datalansiaId,
    this.actionUrl,
    this.actionText,
    this.data,
    this.metadata,
    this.scheduledAt,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'type': type,
      'category': category,
      'title': title,
      'message': message,
      if (urgencyLevel != null) 'urgency_level': urgencyLevel,
      if (datalansiaId != null) 'datalansia_id': datalansiaId,
      if (actionUrl != null) 'action_url': actionUrl,
      if (actionText != null) 'action_text': actionText,
      if (data != null) 'data': data,
      if (metadata != null) 'metadata': metadata,
      if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }
}

// Model for batch notification request
class BatchNotificationRequest {
  final List<String> userIds;
  final String type;
  final String category;
  final String title;
  final String message;
  final String? urgencyLevel;
  final String? datalansiaId;
  final String? actionUrl;
  final String? actionText;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? metadata;

  BatchNotificationRequest({
    required this.userIds,
    required this.type,
    required this.category,
    required this.title,
    required this.message,
    this.urgencyLevel,
    this.datalansiaId,
    this.actionUrl,
    this.actionText,
    this.data,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_ids': userIds,
      'type': type,
      'category': category,
      'title': title,
      'message': message,
      if (urgencyLevel != null) 'urgency_level': urgencyLevel,
      if (datalansiaId != null) 'datalansia_id': datalansiaId,
      if (actionUrl != null) 'action_url': actionUrl,
      if (actionText != null) 'action_text': actionText,
      if (data != null) 'data': data,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

// Helper enums
enum NotificationType {
  info('info'),
  warning('warning'),
  emergency('emergency'),
  reminder('reminder'),
  success('success');

  final String value;
  const NotificationType(this.value);
  
  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.info,
    );
  }
}

enum NotificationCategory {
  kesehatan('kesehatan'),
  iuran('iuran'),
  jadwal('jadwal'),
  pengumuman('pengumuman'),
  system('system');

  final String value;
  const NotificationCategory(this.value);
  
  static NotificationCategory fromString(String value) {
    return NotificationCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationCategory.system,
    );
  }
}

enum UrgencyLevel {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  final String value;
  const UrgencyLevel(this.value);
  
  static UrgencyLevel fromString(String value) {
    return UrgencyLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UrgencyLevel.medium,
    );
  }
}