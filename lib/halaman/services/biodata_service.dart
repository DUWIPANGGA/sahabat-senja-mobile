import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahabatsenja_app/models/datalansia_model.dart';

class BiodataService {
  // 🔗 Ganti baseUrl sesuai IP / domain server Laravel kamu
  final String baseUrl = 'http://10.0.166.37:8000/api';

  /// 🧩 Simpan data lansia ke database Laravel
  Future<bool> createDataLansia(Datalansia data) async {
    try {
      final url = Uri.parse('$baseUrl/datalansia');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Data lansia berhasil disimpan ke Laravel');
        return true;
      } else {
        print('❌ Gagal simpan data: ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error createDataLansia: $e');
      return false;
    }
  }

  /// 📋 Ambil semua data lansia dari Laravel (buat admin / perawat)
  Future<List<Datalansia>> fetchAllDataLansia() async {
    try {
      final url = Uri.parse('$baseUrl/datalansia');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((e) => Datalansia.fromJson(e)).toList();
      } else {
        throw Exception('Gagal ambil data lansia: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error fetchAllDataLansia: $e');
      rethrow;
    }
  }

  /// 🔍 Ambil detail lansia berdasarkan ID
  Future<Datalansia?> getDataLansiaById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/datalansia/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Datalansia.fromJson(data);
      } else {
        print('❌ Lansia dengan ID $id tidak ditemukan');
        return null;
      }
    } catch (e) {
      print('⚠️ Error getDataLansiaById: $e');
      return null;
    }
  }

  Future<List<Datalansia>> getBiodataByKeluarga(String namaKeluarga) async {
  try {
    final url = Uri.parse('$baseUrl/datalansia/keluarga/$namaKeluarga');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body.map((e) => Datalansia.fromJson(e)).toList();
      } else {
        print('⚠️ Format data tidak sesuai');
        return [];
      }
    } else {
      print('❌ Gagal ambil data biodata keluarga: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('⚠️ Error getBiodataByKeluarga: $e');
    return [];
  }
}

  void initializeDemoData() {}

  getAllBiodata() {}

  getIdKeluargaByEmail(String email) {}
}
