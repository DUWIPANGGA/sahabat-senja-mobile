// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Sesuaikan IP / host sesuai device / emulator
  static const String baseUrl = 'http://192.168.1.55:8000/api';

  // Header untuk request
  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      print('API GET Error: $e');
      throw Exception('Failed to fetch data');
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      print('API POST Error: $e');
      throw Exception('Failed to post data');
    }
  }

  // Handle response dari API
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body; // fallback jika bukan JSON
      }
    } else {
      throw Exception(
          'API Error: ${response.statusCode} | Body: ${response.body}');
    }
  }
}
