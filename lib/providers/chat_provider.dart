// providers/chat_provider.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sahabatsenja_app/models/chat_model.dart';
import 'package:sahabatsenja_app/services/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<ChatConversation> _conversations = [];
  Map<int, List<ChatMessage>> _messages = {};
  Map<int, Map<String, dynamic>> _pagination = {};
  Map<String, dynamic> _unreadCounts = {
    'total_unread': 0,
    'conversations': {},
  };
  bool _isLoading = false;
  String? _error;

  List<ChatConversation> get conversations => _conversations;
  Map<int, List<ChatMessage>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get messages for specific user
  List<ChatMessage> getMessagesForUser(int userId) {
    return _messages[userId] ?? [];
  }

  // Load conversations
  Future<void> loadConversations() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _chatService.getConversations();
      _conversations = data;
      
      // Update unread counts
      await loadUnreadCounts();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Load messages for a user
  Future<void> loadMessages(int userId, {bool loadMore = false}) async {
    try {
      if (!loadMore) {
        _messages[userId] = [];
        _isLoading = true;
      }
      _error = null;
      notifyListeners();

      final currentPage = loadMore 
          ? (_pagination[userId]?['current_page'] ?? 0) + 1 
          : 1;
      
      final data = await _chatService.getMessages(userId, page: currentPage);
      
      final List<ChatMessage> loadedMessages = data['messages'];
      
      if (loadMore) {
        _messages[userId] = [..._messages[userId]!, ...loadedMessages];
      } else {
        _messages[userId] = loadedMessages;
      }
      
      _pagination[userId] = {
        'current_page': data['pagination']['current_page'],
        'has_more': data['pagination']['has_more'],
        'total_pages': data['pagination']['total_pages'],
      };
      
      // Mark messages as read
      if (!loadMore) {
        await _chatService.markAsRead(userId);
        await loadUnreadCounts();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Send text message
  Future<ChatMessage> sendTextMessage({
    required int receiverId,
    required String message,
  }) async {
    try {
      final newMessage = await _chatService.sendTextMessage(
        receiverId: receiverId,
        message: message,
      );
      
      // Add to local messages
      _addMessageToLocalStore(receiverId, newMessage);
      
      // Update conversation list
      _updateConversationList(receiverId, newMessage);
      
      notifyListeners();
      return newMessage;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Send image message
  Future<ChatMessage> sendImageMessage({
    required int receiverId,
    required File imageFile,
    String? caption,
  }) async {
    try {
      final newMessage = await _chatService.sendImageMessage(
        receiverId: receiverId,
        imageFile: imageFile,
        caption: caption,
      );
      
      // Add to local messages
      _addMessageToLocalStore(receiverId, newMessage);
      
      // Update conversation list
      _updateConversationList(receiverId, newMessage);
      
      notifyListeners();
      return newMessage;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Send file message
  Future<ChatMessage> sendFileMessage({
    required int receiverId,
    required File file,
    String? caption,
  }) async {
    try {
      final newMessage = await _chatService.sendFileMessage(
        receiverId: receiverId,
        file: file,
        caption: caption,
      );
      
      // Add to local messages
      _addMessageToLocalStore(receiverId, newMessage);
      
      // Update conversation list
      _updateConversationList(receiverId, newMessage);
      
      notifyListeners();
      return newMessage;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Helper: Add message to local store
  void _addMessageToLocalStore(int userId, ChatMessage message) {
    if (_messages[userId] != null) {
      _messages[userId]!.insert(0, message);
    } else {
      _messages[userId] = [message];
    }
  }

  // Helper: Update conversation list
// Helper: Update conversation list
void _updateConversationList(int userId, ChatMessage message) {
  // Determine the other user's ID
  final currentUserId = message.senderId == userId ? message.receiverId : message.senderId;
  final otherUserId = currentUserId == message.senderId ? message.receiverId : message.senderId;
  
  // Get user info safely
  final otherUserInfo = message.senderId == otherUserId 
      ? message.sender 
      : message.receiver;
  
  // Safely extract user data with null checks
  final Map<String, dynamic> userData = {
    'id': otherUserId,
    'name': otherUserInfo?['name']?.toString() ?? 'Unknown',
    'role': otherUserInfo?['role']?.toString() ?? '',
  };
  
  // Check if conversation already exists
  final index = _conversations.indexWhere((conv) => conv.user['id'] == otherUserId);
  
  final conversation = ChatConversation(
    user: userData,
    lastMessage: {
      'message': message.message,
      'time': message.timeFormatted ?? '',
      'date': message.createdAt.toString(),
    },
    unreadCount: message.senderId == otherUserId 
        ? getUnreadCountForUser(otherUserId) + 1 
        : 0,
    lastMessageTime: message.createdAt,
  );
  
  if (index != -1) {
    _conversations.removeAt(index);
  }
  
  // Add to beginning of list
  _conversations.insert(0, conversation);
  
  // Update unread count if message is from other user
  if (message.senderId == otherUserId) {
    final currentConvCount = _unreadCounts['conversations']?[otherUserId.toString()] ?? 0;
    if (_unreadCounts['conversations'] == null) {
      _unreadCounts['conversations'] = {};
    }
    _unreadCounts['conversations']![otherUserId.toString()] = currentConvCount + 1;
    _unreadCounts['total_unread'] = (_unreadCounts['total_unread'] ?? 0) + 1;
  }
}
Future<void> loadUnreadCounts() async {
  try {
    final data = await _chatService.getUnreadCount();
    
    // Pastikan data berformat benar
    if (data != null && data is Map<String, dynamic>) {
      _unreadCounts = {
        'total_unread': int.tryParse(data['total_unread']?.toString() ?? '0') ?? 0,
        'conversations': Map<String, int>.from(
          (data['conversations'] as Map<String, dynamic>? ?? {}).map(
            (key, value) => MapEntry(
              key.toString(),
              int.tryParse(value?.toString() ?? '0') ?? 0,
            ),
          ),
        ),
      };
      
      // Update unread counts in conversations
      for (int i = 0; i < _conversations.length; i++) {
        final conv = _conversations[i];
        final userId = conv.user['id']?.toString();
        
        if (userId != null && _unreadCounts['conversations']?[userId] != null) {
          final unreadCount = _unreadCounts['conversations']![userId] ?? 0;
          _conversations[i] = ChatConversation(
            user: conv.user,
            lastMessage: conv.lastMessage,
            unreadCount: unreadCount,
            lastMessageTime: conv.lastMessageTime,
          );
        }
      }
      
      notifyListeners();
    }
  } catch (e) {
    print('❌ Error loading unread counts: $e');
    // Set default values on error
    _unreadCounts = {
      'total_unread': 0,
      'conversations': {},
    };
    notifyListeners();
  }
}


int _safeParseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}

  // Get total unread count
  int get totalUnreadCount {
    return _unreadCounts['total_unread'] ?? 0;
  }

  // Get unread count for specific user
  int getUnreadCountForUser(int userId) {
    return _unreadCounts['conversations']?[userId.toString()] ?? 0;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if has more messages for user
  bool hasMoreMessages(int userId) {
    return _pagination[userId]?['has_more'] ?? false;
  }

  // Add received message via WebSocket
// Add received message via WebSocket
void addReceivedMessage(ChatMessage message) async{
  final currentUserId = await _getCurrentUserId(); // You need to implement this
  final isFromMe = message.senderId == currentUserId;
  final otherUserId = isFromMe ? message.receiverId : message.senderId;
  
  // Add to messages
  _addMessageToLocalStore(otherUserId, message);
  
  // Update conversation list
  _updateConversationList(otherUserId, message);
  
  // Only increment unread count if message is NOT from me
  if (!isFromMe) {
    final currentTotal = _unreadCounts['total_unread'] ?? 0;
    _unreadCounts['total_unread'] = currentTotal + 1;
    
    final currentConvCount = _unreadCounts['conversations']?[otherUserId.toString()] ?? 0;
    if (_unreadCounts['conversations'] == null) {
      _unreadCounts['conversations'] = {};
    }
    _unreadCounts['conversations']![otherUserId.toString()] = currentConvCount + 1;
  }
  
  notifyListeners();
}

// Add this helper method to ChatProvider
Future<int?> _getCurrentUserId() async {
  try {
    // You need to store current user ID when logging in
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      final data = json.decode(userData);
      return data['id'] as int?;
    }
    return null;
  } catch (e) {
    return null;
  }
}
  Future<void> markMessagesAsRead(int userId) async {
    try {
      await _chatService.markAsRead(userId);
      await loadUnreadCounts();
      notifyListeners();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int messageId, int userId) async {
    try {
      await _chatService.deleteMessage(messageId);
      
      // Remove from local store
      if (_messages[userId] != null) {
        _messages[userId]!.removeWhere((msg) => msg.id == messageId);
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear conversation with a user
  Future<void> clearConversation(int userId) async {
    try {
      await _chatService.clearConversation(userId);
      
      // Clear local messages
      _messages.remove(userId);
      
      // Remove from conversations list
      _conversations.removeWhere((conv) => conv.user['id'] == userId);
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Search users
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      return await _chatService.searchUsers(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}