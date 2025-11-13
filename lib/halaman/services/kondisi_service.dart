import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahabatsenja_app/models/kondisi_model.dart';

class KondisiService {
  final String baseUrl = 'http://10.0.161.194:8000/api'; // Sesuaikan IP

  // 🔹 Tambah data kondisi lansia
  Future<bool> addKondisi(KondisiHarian kondisi) async {
    try {
      final url = Uri.parse('$baseUrl/kondisi');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(kondisi.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Kondisi berhasil disimpan');
        return true;
      } else {
        print('❌ Gagal simpan kondisi (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error addKondisi: $e');
      return false;
    }
  }

  // 🔹 Ambil semua riwayat kondisi berdasarkan id_lansia
  Future<List<KondisiHarian>> fetchRiwayatById(int idLansia) async {
    try {
      final url = Uri.parse('$baseUrl/kondisi/$idLansia');
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => KondisiHarian.fromJson(e)).toList();
        }
      } else {
        print('❌ Gagal fetch riwayat (${response.statusCode}): ${response.body}');
      }
      return [];
    } catch (e) {
      print('⚠️ Error fetchRiwayatById: $e');
      return [];
    }
  }

  // 🔹 Ambil kondisi hari ini berdasarkan nama lansia
  Future<KondisiHarian?> getTodayData(String namaLansia) async {
    try {
      final today = DateTime.now();
      final tanggal =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final url = Uri.parse('$baseUrl/kondisi/today/$namaLansia/$tanggal');
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body != null && body is Map<String, dynamic>) {
          return KondisiHarian.fromJson(body);
        }
      } else {
        print('❌ Tidak ada data hari ini (${response.statusCode})');
      }
      return null;
    } catch (e) {
      print('⚠️ Error getTodayData: $e');
      return null;
    }
  }

  // 🔹 Ambil semua riwayat berdasarkan nama lansia
  Future<List<KondisiHarian>> fetchRiwayatByNama(String namaLansia) async {
    try {
      final url = Uri.parse('$baseUrl/kondisi/riwayat/$namaLansia');
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => KondisiHarian.fromJson(e)).toList();
        }
      } else {
        print('❌ Gagal fetch riwayat nama (${response.statusCode}): ${response.body}');
      }
      return [];
    } catch (e) {
      print('⚠️ Error fetchRiwayatByNama: $e');
      return [];
    }
  }

  // 🔹 Ambil semua kondisi dari semua lansia (BARU)
  Future<List<KondisiHarian>> fetchAllKondisi() async {
    try {
      final url = Uri.parse('$baseUrl/kondisi'); // pastikan endpoint index() ada di Laravel
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => KondisiHarian.fromJson(e)).toList();
        }
      } else {
        print('❌ Gagal fetch semua kondisi (${response.statusCode}): ${response.body}');
      }
      return [];
    } catch (e) {
      print('⚠️ Error fetchAllKondisi: $e');
      return [];
    }
  }
}
