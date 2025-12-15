// lib/services/jadwal_service.dart
import 'package:sahabatsenja_app/models/jadwal_aktivitas_model.dart';
import 'package:sahabatsenja_app/services/api_service.dart';

class JadwalService {
  final ApiService _api = ApiService();

/// 📋 Ambil semua jadwal aktivitas
Future<List<JadwalAktivitas>> fetchJadwal() async {
  try {
    final response = await _api.get('jadwal');
    
    // Debug: Cetak respons untuk melihat struktur data
    print('📥 Response data: $response');
    
    if (response['status'] == 'success') {
      final List<dynamic> data = response['data'];
      
      // Debug: Cetak setiap item untuk melihat struktur JSON
      for (var i = 0; i < data.length; i++) {
        print('📋 Item $i: ${data[i]}');
        print('📋 Type of id: ${data[i]['id']?.runtimeType}');
        print('📋 Type of completed: ${data[i]['completed']?.runtimeType}');
      }
      
      try {
        final jadwalList = data.map((e) => JadwalAktivitas.fromJson(e)).toList();
        print('✅ Successfully parsed ${jadwalList.length} items');
        return jadwalList;
      } catch (e, stackTrace) {
        print('❌ Parsing error: $e');
        print('❌ Stack trace: $stackTrace');
        throw Exception('Gagal parsing data: $e');
      }
    } else {
      throw Exception('Gagal fetch jadwal: ${response['message']}');
    }
  } catch (e) {
    print('⚠️ Error fetchJadwal: $e');
    rethrow;
  }
}

  /// ➕ Tambah jadwal aktivitas
  Future<bool> tambahJadwal(JadwalAktivitas jadwal) async {
    try {
      final response = await _api.post('jadwal', jadwal.toJson());
      
      if (response['status'] == 'success') {
        print('✅ Jadwal berhasil ditambahkan');
        return true;
      } else {
        print('❌ Gagal tambah jadwal: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error tambahJadwal: $e');
      return false;
    }
  }

  /// ✅ Update status completed
  Future<bool> updateCompleted(int id, bool completed) async {
    try {
      final response = await _api.put('jadwal/$id/completed', {
        'completed': completed,
      });
      
      if (response['status'] == 'success') {
        print('✅ Status jadwal berhasil diupdate');
        return true;
      } else {
        print('❌ Gagal update status: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error updateCompleted: $e');
      return false;
    }
  }

  /// 🗑️ Hapus jadwal aktivitas
  Future<bool> hapusJadwal(int id) async {
    try {
      final response = await _api.delete('jadwal/$id');
      
      if (response['status'] == 'success') {
        print('✅ Jadwal berhasil dihapus');
        return true;
      } else {
        print('❌ Gagal hapus jadwal: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error hapusJadwal: $e');
      return false;
    }
  }

  /// ✏️ Update jadwal aktivitas
  Future<bool> updateJadwal(JadwalAktivitas jadwal) async {
    try {
      final response = await _api.put('jadwal/${jadwal.id}', jadwal.toJson());
      
      if (response['status'] == 'success') {
        print('✅ Jadwal berhasil diupdate');
        return true;
      } else {
        print('❌ Gagal update jadwal: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error updateJadwal: $e');
      return false;
    }
  }
}