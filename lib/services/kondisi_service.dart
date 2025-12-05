// lib/services/kondisi_service.dart - PERBAIKAN HANYA getTodayData()
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

  /// 🔹 PERBAIKAN: Ambil kondisi hari ini berdasarkan nama lansia
  Future<KondisiHarian?> getTodayData(String namaLansia) async {
    try {
      final today = DateTime.now();
      final tanggal = "${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}";
      
      print('🌐 Fetching kondisi hari ini untuk $namaLansia pada $tanggal');
      
      final response = await _api.get('kondisi/today/$namaLansia/$tanggal');
      
      print('📥 Response status: ${response['status']}');
      print('📥 Response data type: ${response['data']?.runtimeType}');
      
      if (response['status'] == 'success') {
        final data = response['data'];
        
        // Jika data null atau kosong
        if (data == null) {
          print('⚠️ Data kosong untuk $namaLansia hari ini');
          return null;
        }
        
        // Jika data berupa List
        if (data is List) {
          if (data.isEmpty) {
            print('📭 List data kosong');
            return null;
          }
          print('✅ Data ditemukan (List dengan ${data.length} item)');
          return KondisiHarian.fromJson(data[0]);
        }
        
        // Jika data berupa Map
        if (data is Map<String, dynamic>) {
          print('✅ Data ditemukan (Map)');
          return KondisiHarian.fromJson(data);
        }
        
        print('❌ Format data tidak dikenali: ${data.runtimeType}');
        return null;
      } else {
        print('⚠️ API error: ${response['message']}');
        return null;
      }
    } catch (e) {
      print('❌ Error getTodayData: $e');
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

  /// 🔹 Tambahkan method ini pada kondisi_service.dart
  Future<List<KondisiHarian>> getRiwayatByNamaLansia(String namaLansia) async {
    try {
      final response = await _api.get('kondisi/lansia/$namaLansia');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((json) => KondisiHarian.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat riwayat: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error getRiwayatByNamaLansia: $e');
      rethrow;
    }
  }

  /// 🔹 METHOD BARU: Get today data dengan fallback (tanpa mengubah yang lama)
  Future<KondisiHarian?> getTodayDataWithFallback(String namaLansia) async {
    try {
      // Coba method original
      final data = await getTodayData(namaLansia);
      if (data != null) return data;
      
      // Jika gagal, coba alternatif endpoint
      return await _getTodayDataAlternative(namaLansia);
    } catch (e) {
      print('⚠️ Error getTodayDataWithFallback: $e');
      return null;
    }
  }

  /// 🔹 METHOD PRIVATE: Alternatif untuk get today data
  Future<KondisiHarian?> _getTodayDataAlternative(String namaLansia) async {
    try {
      final today = DateTime.now();
      final tanggal = "${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}";
      
      // Coba endpoint yang berbeda
      final response = await _api.get('kondisi?tanggal=$tanggal&nama_lansia=$namaLansia');
      
      if (response['status'] == 'success') {
        final data = response['data'];
        
        if (data is List && data.isNotEmpty) {
          return KondisiHarian.fromJson(data[0]);
        }
        
        if (data is Map<String, dynamic>) {
          return KondisiHarian.fromJson(data);
        }
      }
      
      return null;
    } catch (e) {
      print('⚠️ Error _getTodayDataAlternative: $e');
      return null;
    }
  }

  /// 🔹 METHOD BARU: Debug API response
  Future<void> debugEndpoint(String endpoint) async {
    try {
      print('🔍 Debug endpoint: $endpoint');
      final response = await _api.get(endpoint);
      print('🔍 Response:');
      print('  Status: ${response['status']}');
      print('  Message: ${response['message']}');
      print('  Data type: ${response['data']?.runtimeType}');
      print('  Data: ${response['data']}');
    } catch (e) {
      print('❌ Debug error: $e');
    }
  }
}