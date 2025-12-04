// services/chat_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sahabatsenja_app/models/chat_model.dart';
import 'package:sahabatsenja_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String baseUrl = ApiService.baseUrl;
  final ApiService _apiService = ApiService();

  /// Get all conversations
  Future<List<ChatConversation>> getConversations() async {
    try {
      final response = await _apiService.get('chat/conversations');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => ChatConversation.fromJson(e)).toList();
      } else {
        throw Exception('Failed to get conversations: ${response['message']}');
      }
    } catch (e) {
      print('⚠️ Error getConversations: $e');
      rethrow;
    }
  }

  /// Get messages with a user
  Future<Map<String, dynamic>> getMessages(int userId, {int page = 1}) async {
    try {
      final response = await _apiService.get('chat/messages/$userId?page=$page');
      
      if (response['status'] == 'success') {
        final data = response['data'];
        final messages = (data['messages'] as List)
            .map((e) => ChatMessage.fromJson(e))
            .toList();
        
        return {
          'messages': messages,
          'otherUser': data['other_user'],
          'pagination': data['pagination'],
        };
      } else {
        throw Exception('Failed to get messages: ${response['message']}');
      }
    } catch (e) {
      print('⚠️ Error getMessages: $e');
      rethrow;
    }
  }

  /// Send text message
  Future<ChatMessage> sendTextMessage({
    required int receiverId,
    required String message,
  }) async {
    try {
      final response = await _apiService.post('chat/send', {
        'receiver_id': receiverId,
        'message': message,
        'type': 'text',
      });
      
      if (response['status'] == 'success') {
        return ChatMessage.fromJson(response['data']);
      } else {
        throw Exception('Failed to send message: ${response['message']}');
      }
    } catch (e) {
      print('⚠️ Error sendTextMessage: $e');
      rethrow;
    }
  }

  /// Send image message
  Future<ChatMessage> sendImageMessage({
    required int receiverId,
    required File imageFile,
    String? caption,
  }) async {
    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse('$baseUrl/chat/send');
      
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..fields['receiver_id'] = receiverId.toString()
        ..fields['type'] = 'image'
        ..fields['message'] = caption ?? '';
      
      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      );
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      
      if (response.statusCode == 201 && jsonResponse['status'] == 'success') {
        return ChatMessage.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to send image: ${jsonResponse['message']}');
      }
    } catch (e) {
      print('⚠️ Error sendImageMessage: $e');
      rethrow;
    }
  }

  /// Send file message
  Future<ChatMessage> sendFileMessage({
    required int receiverId,
    required File file,
    String? caption,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse('$baseUrl/chat/send');
      
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..fields['receiver_id'] = receiverId.toString()
        ..fields['type'] = 'file'
        ..fields['message'] = caption ?? '';
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.path.split('/').last,
        ),
      );
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      
      if (response.statusCode == 201 && jsonResponse['status'] == 'success') {
        return ChatMessage.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to send file: ${jsonResponse['message']}');
      }
    } catch (e) {
      print('⚠️ Error sendFileMessage: $e');
      rethrow;
    }
  }

  /// Mark messages as read
  Future<int> markAsRead(int senderId) async {
    try {
      final response = await _apiService.post('chat/mark-read', {
        'sender_id': senderId,
      });
      
      if (response['status'] == 'success') {
        return response['data']['updated_count'] ?? 0;
      } else {
        throw Exception('Failed to mark as read: ${response['message']}');
      }
    } catch (e) {
      print('⚠️ Error markAsRead: $e');
      rethrow;
    }
  }

  /// Get unread count
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await _apiService.get('chat/unread-count');
      
      if (response['status'] == 'success') {
        return response['data'];
      } else {
        throw Exception('Failed to get unread count: ${response['message']}');
      }
    } catch (e) {
      print('⚠️ Error getUnreadCount: $e');
      rethrow;
    }
  }

  /// Search users for chat
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _apiService.get('chat/search-users?search=$query');
      
      if (response['status'] == 'success') {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('Failed to search users: ${response['message']}');
      }
    } catch (e) {
      print('⚠️ Error searchUsers: $e');
      rethrow;
    }
  }

  /// Delete message
  Future<bool> deleteMessage(int messageId) async {
    try {
      final response = await _apiService.delete('chat/message/$messageId');
      
      if (response['status'] == 'success') {
        return true;
      } else {
        throw Exception('Failed to delete message: ${response['message']}');
      }
    } catch (e) {
      print('⚠️ Error deleteMessage: $e');
      rethrow;
    }
  }

  /// Clear conversation with a user
  Future<bool> clearConversation(int userId) async {
    try {
      final response = await _apiService.delete('chat/clear/$userId');
      
      if (response['status'] == 'success') {
        return true;
      } else {
        throw Exception('Failed to clear conversation: ${response['message']}');
      }
    } catch (e) {
      print('⚠️ Error clearConversation: $e');
      rethrow;
    }
  }

  /// Get chat statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _apiService.get('chat/statistics');
      
      if (response['status'] == 'success') {
        return response['data'];
      } else {
        throw Exception('Failed to get statistics: ${response['message']}');
      }
    } catch (e) {
      print('⚠️ Error getStatistics: $e');
      rethrow;
    }
  }
}