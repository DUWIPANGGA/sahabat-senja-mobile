import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahabatsenja_app/models/jadwal_obat_model.dart';

class JadwalObatService {
  final String baseUrl = "http://10.0.166.37:8000/api"; // sesuaikan IP backend

  /// 🔹 Ambil semua jadwal obat untuk 1 lansia
  Future<List<JadwalObat>> fetchJadwalObat(int datalansiaId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/jadwal-obat/$datalansiaId"),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => JadwalObat.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetchJadwalObat: $e");
      return [];
    }
  }

  /// 🔹 Tambah jadwal obat
  Future<bool> tambahJadwalObat({
    required int datalansiaId,
    required String namaObat,
    required String dosis,
    required String waktu,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/jadwal-obat"),
        body: {
          "datalansia_id": datalansiaId.toString(),
          "nama_obat": namaObat,
          "dosis": dosis,
          "waktu": waktu,
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error tambahJadwalObat: $e");
      return false;
    }
  }

  /// 🔹 Update status obat (sudah diminum)
  Future<bool> updateStatus(int id, bool completed) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/jadwal-obat/$id"),
        body: {
          "completed": completed ? "1" : "0",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updateStatus: $e");
      return false;
    }
  }

  /// 🔹 Hapus jadwal obat
  Future<bool> deleteJadwalObat(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/jadwal-obat/$id"),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error deleteJadwalObat: $e");
      return false;
    }
  }
}
