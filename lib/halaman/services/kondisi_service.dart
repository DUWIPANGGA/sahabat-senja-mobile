import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahabatsenja_app/models/kondisi_model.dart';

class KondisiService {
  final String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator

  Future<bool> addKondisi(KondisiHarian kondisi) async {
    try {
      final url = Uri.parse('$baseUrl/kondisi');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(kondisi.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Kondisi berhasil disimpan');
        return true;
      } else {
        print('❌ Gagal simpan kondisi: ${response.statusCode} => ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error addKondisi: $e');
      return false;
    }
  }

  Future<List<KondisiHarian>> fetchRiwayatById(int idLansia) async {
    try {
      final url = Uri.parse('$baseUrl/kondisi/$idLansia');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body.map((e) => KondisiHarian.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('⚠️ Error fetchRiwayatById: $e');
      return [];
    }
  }

  Future<KondisiHarian?> getTodayData(String namaLansia) async {
    try {
      final today = DateTime.now();
      final tanggal =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final url = Uri.parse('$baseUrl/kondisi/today/$namaLansia/$tanggal');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) return KondisiHarian.fromJson(data);
      }
      return null;
    } catch (e) {
      print('⚠️ Error getTodayData: $e');
      return null;
    }
  }

  Future<List<KondisiHarian>> fetchRiwayatByNama(String namaLansia) async {
    try {
      final url = Uri.parse('$baseUrl/kondisi/riwayat/$namaLansia');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body.map((e) => KondisiHarian.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('⚠️ Error fetchRiwayatByNama: $e');
      return [];
    }
  }
}
