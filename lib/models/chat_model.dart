// models/chat_model.dart
class ChatConversation {
  final Map<String, dynamic> user;
  final Map<String, dynamic>? lastMessage;
  final int unreadCount;
  final DateTime? lastMessageTime;

  ChatConversation({
    required this.user,
    this.lastMessage,
    required this.unreadCount,
    this.lastMessageTime,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      user: Map<String, dynamic>.from(json['user']),
      lastMessage: json['last_message'] != null 
          ? Map<String, dynamic>.from(json['last_message']) 
          : null,
      unreadCount: json['unread_count'] ?? 0,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
    );
  }
}

class ChatMessage {
  final int? id;
  final int senderId;
  final int receiverId;
  final String message;
  final bool isRead;
  final DateTime? readAt;
  final String type;
  final String? filePath;
  final String? fileName;
  final String? fileUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;
  
  // Computed
  final String? timeFormatted;
  final bool? isSender;

  ChatMessage({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.isRead = false,
    this.readAt,
    this.type = 'text',
    this.filePath,
    this.fileName,
    this.fileUrl,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.receiver,
    this.timeFormatted,
    this.isSender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int?,
      senderId: json['sender_id'] as int,
      receiverId: json['receiver_id'] as int,
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      type: json['type'] ?? 'text',
      filePath: json['file_path'],
      fileName: json['file_name'],
      fileUrl: json['file_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      sender: json['sender'] != null 
          ? Map<String, dynamic>.from(json['sender']) 
          : null,
      receiver: json['receiver'] != null 
          ? Map<String, dynamic>.from(json['receiver']) 
          : null,
      timeFormatted: json['time_formatted'],
      isSender: json['is_sender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiver_id': receiverId,
      'message': message,
      'type': type,
      if (filePath != null) 'file_path': filePath,
      if (fileName != null) 'file_name': fileName,
    };
  }

  ChatMessage copyWith({
    int? id,
    int? senderId,
    int? receiverId,
    String? message,
    bool? isRead,
    DateTime? readAt,
    String? type,
    String? filePath,
    String? fileName,
    String? fileUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: this.sender,
      receiver: this.receiver,
      timeFormatted: this.timeFormatted,
      isSender: this.isSender,
    );
  }
}