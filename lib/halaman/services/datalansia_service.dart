// lib/services/datalansia_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahabatsenja_app/models/datalansia_model.dart';

class DatalansiaService {
  static const String baseUrl = 'http://10.0.166.37:8000/api'; // Ganti IP sesuai Laravel kamu

  // 🔹 Get all data
  static Future<List<Datalansia>> getDatalansia() async {
    final response = await http.get(Uri.parse('$baseUrl/datalansia'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Datalansia.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data (${response.statusCode})');
    }
  }

  // 🔹 Get by ID
  static Future<Datalansia> getDatalansiaById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/datalansia/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Datalansia.fromJson(data);
    } else {
      throw Exception('Data tidak ditemukan (${response.statusCode})');
    }
  }

  // 🔹 Create data
  static Future<Datalansia> createDatalansia(Datalansia datalansia) async {
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
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Datalansia.fromJson(jsonResponse['data']); // ✅ ambil hanya bagian "data"
    } else {
      throw Exception(
          'Gagal menambahkan data: ${response.statusCode} - ${response.body}');
    }
  }

  // 🔹 Update data
  static Future<Datalansia> updateDatalansia(
      int id, Datalansia datalansia) async {
    final response = await http.put(
      Uri.parse('$baseUrl/datalansia/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(datalansia.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Datalansia.fromJson(jsonResponse['data']); // ✅ ambil hanya bagian "data"
    } else {
      throw Exception(
          'Gagal memperbarui data: ${response.statusCode} - ${response.body}');
    }
  }

  // 🔹 Delete data
  static Future<bool> deleteDatalansia(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/datalansia/$id'),
      headers: {'Accept': 'application/json'},
    );

    return response.statusCode == 200;
  }
}
