// lib/services/biodata_service.dart
import 'package:sahabatsenja_app/services/api_service.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';

class BiodataService {
  final ApiService _api = ApiService();

  /// 🧩 Simpan data lansia ke database Laravel
  Future<bool> createDataLansia(Datalansia data) async {
    try {
      final response = await _api.post('datalansia', data.toJson());
      
      if (response['status'] == 'success') {
        print('✅ Data lansia berhasil disimpan ke Laravel');
        return true;
      } else {
        print('❌ Gagal simpan data: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error createDataLansia: $e');
      return false;
    }
  }

  /// 📋 Ambil semua data lansia dari Laravel
  Future<List<Datalansia>> fetchAllDataLansia() async {
    try {
      final response = await _api.get('datalansia');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => Datalansia.fromJson(e)).toList();
      } else {
        throw Exception('Gagal ambil data lansia: ${response['message']}');
      }
    } catch (e) {
      print('⚠️ Error fetchAllDataLansia: $e');
      rethrow;
    }
  }

  /// 🔍 Ambil detail lansia berdasarkan ID
  Future<Datalansia?> getDataLansiaById(int id) async {
    try {
      final response = await _api.get('datalansia/$id');
      
      if (response['status'] == 'success') {
        return Datalansia.fromJson(response['data']);
      } else {
        print('❌ Lansia dengan ID $id tidak ditemukan: ${response['message']}');
        return null;
      }
    } catch (e) {
      print('⚠️ Error getDataLansiaById: $e');
      return null;
    }
  }

  /// 👨‍👩‍👧‍👦 Ambil data lansia berdasarkan email keluarga
  Future<List<Datalansia>> getBiodataByKeluarga(String email) async {
    try {
      final response = await _api.get('datalansia/keluarga/$email');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => Datalansia.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada data untuk keluarga $email: ${response['message']}');
        return [];
      }
    } catch (e) {
      print('⚠️ Error getBiodataByKeluarga: $e');
      return [];
    }
  }

  /// ✏️ Update data lansia
  Future<bool> updateDataLansia(int id, Datalansia data) async {
    try {
      final response = await _api.put('datalansia/$id', data.toJson());
      
      if (response['status'] == 'success') {
        print('✅ Data lansia berhasil diperbarui');
        return true;
      } else {
        print('❌ Gagal update data: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error updateDataLansia: $e');
      return false;
    }
  }

  /// 🗑️ Hapus data lansia
  Future<bool> deleteDataLansia(int id) async {
    try {
      final response = await _api.delete('datalansia/$id');
      
      if (response['status'] == 'success') {
        print('✅ Data lansia berhasil dihapus');
        return true;
      } else {
        print('❌ Gagal hapus data: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error deleteDataLansia: $e');
      return false;
    }
  }

  // 🔹 Method lama untuk kompatibilitas
  void initializeDemoData() {}
  
  Future<List<Datalansia>> getAllBiodata() async {
    return await fetchAllDataLansia();
  }
  
  Future<int?> getIdKeluargaByEmail(String email) async {
    try {
      final data = await getBiodataByKeluarga(email);
      if (data.isNotEmpty) {
        return data.first.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}