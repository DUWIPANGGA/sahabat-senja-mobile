import 'dart:convert';
import 'package:http/http.dart' as http;

class KesehatanService {
  final String baseUrl = 'http://192.168.0.101:8000/api';

  /// Ambil data kondisi berdasarkan ID keluarga
  Future<List<dynamic>> getKondisiByKeluarga(int idKeluarga) async {
    final url = Uri.parse('$baseUrl/kondisi/keluarga/$idKeluarga');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Cek apakah response berbentuk list langsung atau ada key 'data'
        if (decoded is List) {
          return decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          return decoded['data'];
        } else {
          throw Exception('Format data tidak sesuai');
        }
      } else {
        throw Exception(
          'Gagal mengambil data kesehatan keluarga (${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }
}
