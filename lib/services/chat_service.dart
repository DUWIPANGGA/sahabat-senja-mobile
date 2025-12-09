// services/chat_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sahabatsenja_app/models/chat_model.dart';
import 'package:sahabatsenja_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  final ApiService _api = ApiService();

  /// 🔹 Get all conversations
  Future<List<ChatConversation>> getConversations() async {
    try {
      final response = await _api.get('chat/conversations');
      
      print('📥 Conversations response: ${response.toString()}');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => ChatConversation.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil percakapan: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error getConversations: $e');
      rethrow;
    }
  }

  /// 🔹 Get messages between users
  Future<Map<String, dynamic>> getMessages(int userId, {int page = 1}) async {
    try {
      final response = await _api.get('chat/messages/$userId?page=$page');
      
      if (response['status'] == 'success') {
        final data = response['data'];
        
        // Format messages
        final messages = (data['messages'] as List)
            .map((e) => ChatMessage.fromJson(e))
            .toList()
            .reversed
            .toList();
        
        return {
          'messages': messages,
          'otherUser': data['other_user'],
          'pagination': data['pagination'],
        };
      } else {
        throw Exception('Gagal mengambil pesan: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error getMessages: $e');
      rethrow;
    }
  }

  /// 🔹 Send text message
  Future<ChatMessage> sendTextMessage({
    required int receiverId,
    required String message,
  }) async {
    try {
      final response = await _api.post('chat/send', {
        'receiver_id': receiverId,
        'message': message,
        'type': 'text',
      });
      
      if (response['status'] == 'success') {
        return ChatMessage.fromJson(response['data']);
      } else {
        throw Exception('Gagal mengirim pesan: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error sendTextMessage: $e');
      rethrow;
    }
  }

  /// 🔹 Send image message
  Future<ChatMessage> sendImageMessage({
    required int receiverId,
    required File imageFile,
    String? caption,
  }) async {
    try {
      print('🖼️ Uploading image: ${imageFile.path}');
      
      final response = await _uploadFile(
        receiverId: receiverId,
        file: imageFile,
        type: 'image',
        message: caption,
      );
      
      if (response['status'] == 'success') {
        return ChatMessage.fromJson(response['data']);
      } else {
        throw Exception('Gagal mengirim gambar: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error sendImageMessage: $e');
      rethrow;
    }
  }

  /// 🔹 Send file message
  Future<ChatMessage> sendFileMessage({
    required int receiverId,
    required File file,
    String? caption,
  }) async {
    try {
      print('📎 Uploading file: ${file.path}');
      
      final response = await _uploadFile(
        receiverId: receiverId,
        file: file,
        type: 'file',
        message: caption,
      );
      
      if (response['status'] == 'success') {
        return ChatMessage.fromJson(response['data']);
      } else {
        throw Exception('Gagal mengirim file: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error sendFileMessage: $e');
      rethrow;
    }
  }

  /// 🔹 Generic file upload method
  Future<Map<String, dynamic>> _uploadFile({
    required int receiverId,
    required File file,
    required String type,
    String? message,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse('${ApiService.baseUrl}/chat/send');
      
      print('🌐 Upload to: $url');
      
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..fields['receiver_id'] = receiverId.toString()
        ..fields['type'] = type
        ..fields['message'] = message ?? '';
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.path.split('/').last,
        ),
      );
      
      final streamedResponse = await request.send();
      final responseData = await streamedResponse.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      
      print('📥 Upload response: $jsonResponse');
      
      if (streamedResponse.statusCode == 201) {
        return jsonResponse;
      } else {
        throw Exception('Failed to upload: ${jsonResponse['message']}');
      }
    } catch (e) {
      print('❌ Error _uploadFile: $e');
      rethrow;
    }
  }

  /// 🔹 Mark messages as read
  Future<int> markAsRead(int senderId) async {
    try {
      final response = await _api.post('chat/mark-read', {
        'sender_id': senderId,
      });
      
      if (response['status'] == 'success') {
        return response['data']['updated_count'] ?? 0;
      } else {
        throw Exception('Gagal menandai pesan: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error markAsRead: $e');
      rethrow;
    }
  }

  /// 🔹 Get unread count
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await _api.get('chat/unread-count');
      
      if (response['status'] == 'success') {
        return response['data'];
      } else {
        throw Exception('Gagal mengambil jumlah pesan: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error getUnreadCount: $e');
      rethrow;
    }
  }

  /// 🔹 Search users for chat
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _api.get('chat/search-users?search=$query');
      
      if (response['status'] == 'success') {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('Gagal mencari pengguna: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error searchUsers: $e');
      rethrow;
    }
  }

  /// 🔹 Delete message
  Future<bool> deleteMessage(int messageId) async {
    try {
      final response = await _api.delete('chat/message/$messageId');
      
      if (response['status'] == 'success') {
        return true;
      } else {
        throw Exception('Gagal menghapus pesan: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error deleteMessage: $e');
      rethrow;
    }
  }

  /// 🔹 Clear conversation with a user
  Future<bool> clearConversation(int userId) async {
    try {
      final response = await _api.delete('chat/clear/$userId');
      
      if (response['status'] == 'success') {
        return true;
      } else {
        throw Exception('Gagal menghapus percakapan: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error clearConversation: $e');
      rethrow;
    }
  }

  /// 🔹 Get chat statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _api.get('chat/statistics');
      
      if (response['status'] == 'success') {
        return response['data'];
      } else {
        throw Exception('Gagal mengambil statistik: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error getStatistics: $e');
      rethrow;
    }
  }

/// services/chat_service.dart
Future<int?> getCurrentUserId() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      final data = json.decode(userData);
      // Handle kemungkinan ID bertipe String atau int
      final dynamic id = data['id'];
      if (id is int) return id;
      if (id is String) return int.tryParse(id);
    }
    return null;
  } catch (e) {
    print('❌ Error getCurrentUserId: $e');
    return null;
  }
}
  /// 🔹 Check if message is from current user
  Future<bool> isMessageFromMe(int senderId) async {
    final currentUserId = await getCurrentUserId();
    return currentUserId == senderId;
  }

  /// 🔹 Format time
  String formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (time.isAfter(today)) {
      return DateFormat('HH:mm').format(time);
    } else if (time.isAfter(yesterday)) {
      return 'Kemarin';
    } else {
      return DateFormat('dd/MM/yyyy').format(time);
    }
  }
}