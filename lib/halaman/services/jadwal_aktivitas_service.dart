import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahabatsenja_app/models/jadwal_aktivitas_model.dart';


class JadwalService {
  final String baseUrl = 'http://10.0.166.37:8000/api'; // sesuaikan IP / domain

  // 🔹 Fetch semua jadwal
  Future<List<JadwalAktivitas>> fetchJadwal() async {
    final response = await http.get(Uri.parse('$baseUrl/jadwal'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => JadwalAktivitas.fromJson(e)).toList();
    } else {
      throw Exception('Gagal fetch jadwal');
    }
  }

  // 🔹 Tambah jadwal baru
  Future<bool> tambahJadwal(JadwalAktivitas jadwal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/jadwal'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(jadwal.toJson()),
    );

    return response.statusCode == 201;
  }

  // 🔹 Update completed
  Future<bool> updateCompleted(int id, bool completed) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/jadwal/$id/completed'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'completed': completed ? 1 : 0}),
    );

    return response.statusCode == 200;
  }
}
