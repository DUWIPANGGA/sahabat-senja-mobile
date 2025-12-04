// lib/services/kondisi_service.dart
import 'package:sahabatsenja_app/services/api_service.dart';
import 'package:sahabatsenja_app/models/kondisi_model.dart';

class KondisiService {
  final ApiService _api = ApiService();

  /// 🔹 Tambah data kondisi lansia
  Future<bool> addKondisi(KondisiHarian kondisi) async {
    try {
      final response = await _api.post('kondisi', kondisi.toJson());
      
      if (response['status'] == 'success') {
        print('✅ Kondisi berhasil disimpan');
        return true;
      } else {
        print('❌ Gagal simpan kondisi: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error addKondisi: $e');
      return false;
    }
  }

  /// 🔹 Ambil semua riwayat kondisi berdasarkan ID lansia
  Future<List<KondisiHarian>> fetchRiwayatById(int idLansia) async {
    try {
      final response = await _api.get('kondisi/$idLansia');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => KondisiHarian.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada riwayat kondisi: ${response['message']}');
        return [];
      }
    } catch (e) {
      print('⚠️ Error fetchRiwayatById: $e');
      return [];
    }
  }

  /// 🔹 Ambil kondisi hari ini berdasarkan nama lansia
  Future<KondisiHarian?> getTodayData(String namaLansia) async {
    try {
      final today = DateTime.now();
      final tanggal = "${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}";
      
      final response = await _api.get('kondisi/today/$namaLansia/$tanggal');
      
      if (response['status'] == 'success') {
        return KondisiHarian.fromJson(response['data']);
      } else {
        print('⚠️ Tidak ada data hari ini: ${response['message']}');
        return null;
      }
    } catch (e) {
      print('⚠️ Error getTodayData: $e');
      return null;
    }
  }

  /// 🔹 Ambil semua riwayat berdasarkan nama lansia
  Future<List<KondisiHarian>> fetchRiwayatByNama(String namaLansia) async {
    try {
      final response = await _api.get('kondisi/riwayat/$namaLansia');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => KondisiHarian.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada riwayat: ${response['message']}');
        return [];
      }
    } catch (e) {
      print('⚠️ Error fetchRiwayatByNama: $e');
      return [];
    }
  }

  /// 🔹 Ambil semua kondisi dari semua lansia
  Future<List<KondisiHarian>> fetchAllKondisi() async {
    try {
      final response = await _api.get('kondisi');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => KondisiHarian.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada data kondisi: ${response['message']}');
        return [];
      }
    } catch (e) {
      print('⚠️ Error fetchAllKondisi: $e');
      return [];
    }
  }

  /// 🔹 Ambil data kondisi berdasarkan ID keluarga
  Future<List<KondisiHarian>> getKondisiByKeluarga(int idKeluarga) async {
    try {
      final response = await _api.get('kondisi/keluarga/$idKeluarga');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => KondisiHarian.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada kondisi untuk keluarga: ${response['message']}');
        return [];
      }
    } catch (e) {
      print('⚠️ Error getKondisiByKeluarga: $e');
      return [];
    }
  }
}