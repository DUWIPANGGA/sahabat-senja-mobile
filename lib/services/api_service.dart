// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.2.140:8000/api';

  // 🔹 Header request DENGAN token (jika ada)
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // 🔹 GET request
  Future<dynamic> get(String endpoint, {bool includeAuth = true}) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      print('🌐 GET Request: $url');
      
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('❌ GET Error: $e');
      rethrow;
    }
  }

  // 🔹 POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data, 
                       {bool includeAuth = true}) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      print('🌐 POST Request: $url');
      print('Body: $data');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ POST Error: $e');
      rethrow;
    }
  }

  // 🔹 PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getHeaders();
      
      print('🌐 PUT Request: $url');
      
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ PUT Error: $e');
      rethrow;
    }
  }

  // 🔹 DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getHeaders();
      
      print('🌐 DELETE Request: $url');
      
      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('❌ DELETE Error: $e');
      rethrow;
    }
  }

  // 🔹 Handle response - SESUAI FORMAT LARAVEL
  dynamic _handleResponse(http.Response response) {
    print('📥 Response Status: ${response.statusCode}');
    
    try {
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Jika success, kembalikan data dari Laravel
        return data;
      } else {
        // Jika error, kembalikan dalam format standar
        return {
          'status': 'error',
          'message': data['message'] ?? 'API Error ${response.statusCode}',
          'errors': data['errors'] ?? [],
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Invalid response format: $e',
      };
    }
  }

  // 🔹 Clear token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }
}