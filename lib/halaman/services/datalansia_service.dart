// lib/services/datalansia_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahabatsenja_app/models/datalansia_model.dart'; // Import model

class DatalansiaService {
  static const String baseUrl =
      'http://192.168.1.55:8000/api'; // Ganti dengan IP Laravel Anda

  // Get all data lansia
  static Future<List<Datalansia>> getDatalansia() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/datalansia'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Datalansia.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get data lansia by ID
  static Future<Datalansia> getDatalansiaById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/datalansia/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Datalansia.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Data tidak ditemukan');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create new data lansia
  static Future<Datalansia> createDatalansia(Datalansia datalansia) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/datalansia'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(datalansia.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Datalansia.fromJson(data);
      } else {
        throw Exception(
            'Failed to create data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update data lansia
  static Future<Datalansia> updateDatalansia(
      int id, Datalansia datalansia) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/datalansia/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(datalansia.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Datalansia.fromJson(data);
      } else {
        throw Exception('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete data lansia
  static Future<bool> deleteDatalansia(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/datalansia/$id'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
