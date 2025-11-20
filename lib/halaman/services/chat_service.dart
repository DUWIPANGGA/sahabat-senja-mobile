import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahabatsenja_app/models/chat_model.dart';

class ChatService {
  final String baseUrl = "http://10.0.166.37:8000/api"; // sesuaikan

  /// ============================================================
  /// GET CHAT BY datalansia_id  → untuk ambil isi percakapan
  /// ============================================================
  Future<List<ChatMessage>> getChat(int datalansiaId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/chat/$datalansiaId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data["data"] as List;

      return list.map((e) => ChatMessage.fromJson(e)).toList();
    }
    return [];
  }

  /// ============================================================
  /// SEND CHAT → keluarga / perawat kirim pesan
  /// ============================================================
  Future<bool> sendChat({
    required int datalansiaId,
    required String sender, // "keluarga" / "perawat"
    required String pesan,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat/send"),
      body: {
        'datalansia_id': datalansiaId.toString(),
        'sender': sender,
        'pesan': pesan,
      },
    );

    return response.statusCode == 200;
  }

  /// ============================================================
  /// MARK AS READ → tandai pesan sudah dibaca
  /// ============================================================
  Future<bool> markRead(int datalansiaId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat/read/$datalansiaId"),
    );
    return response.statusCode == 200;
  }

  /// ============================================================
  /// LIST CHAT PERAWAT → menampilkan daftar keluarga yg bisa di-chat
  /// perawat hanya lihat lansia yang dia tangani
  /// ============================================================
  Future<List<dynamic>> getListChatPerawat(int perawatId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/chat/list-perawat/$perawatId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"] as List;
    }
    return [];
  }

  getMessages(int datalansiaId) {}

  sendMessage({required int datalansiaId, required String sender, required String pesan}) {}
}
