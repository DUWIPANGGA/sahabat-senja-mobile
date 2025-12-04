// services/jadwal_obat_service.dart
import 'package:sahabatsenja_app/services/api_service.dart';
import 'package:sahabatsenja_app/models/jadwal_obat_model.dart';

class JadwalObatService {
  final ApiService _api = ApiService();

  /// Get all jadwal obat
  Future<List<JadwalObat>> fetchJadwalObat() async {
    try {
      final response = await _api.get('jadwal-obat');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => JadwalObat.fromJson(e)).toList();
      } else {
        throw Exception('Gagal fetch jadwal obat: ${response['message']}');
      }
    } catch (e) {
      print('⚠️ Error fetchJadwalObat: $e');
      rethrow;
    }
  }

  /// Get jadwal obat by lansia ID
  Future<List<JadwalObat>> getByLansia(int datalansiaId) async {
    try {
      final response = await _api.get('jadwal-obat/lansia/$datalansiaId');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => JadwalObat.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada jadwal obat untuk lansia $datalansiaId');
        return [];
      }
    } catch (e) {
      print('⚠️ Error getByLansia: $e');
      return [];
    }
  }

  /// Create new jadwal obat
  Future<bool> createJadwalObat(JadwalObat jadwalObat) async {
    try {
      final response = await _api.post('jadwal-obat', jadwalObat.toJson());
      
      if (response['status'] == 'success') {
        print('✅ Jadwal obat berhasil ditambahkan');
        return true;
      } else {
        print('❌ Gagal tambah jadwal obat: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error createJadwalObat: $e');
      return false;
    }
  }

  /// Update jadwal obat
  Future<bool> updateJadwalObat(JadwalObat jadwalObat) async {
    try {
      final response = await _api.put('jadwal-obat/${jadwalObat.id}', jadwalObat.toJson());
      
      if (response['status'] == 'success') {
        print('✅ Jadwal obat berhasil diupdate');
        return true;
      } else {
        print('❌ Gagal update jadwal obat: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error updateJadwalObat: $e');
      return false;
    }
  }

  /// Update status selesai
  Future<bool> updateStatus(int id, bool selesai) async {
    try {
      final response = await _api.put('jadwal-obat/$id/selesai', {'selesai': selesai});
      
      if (response['status'] == 'success') {
        print('✅ Status jadwal obat berhasil diupdate');
        return true;
      } else {
        print('❌ Gagal update status: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error updateStatus: $e');
      return false;
    }
  }

  /// Update jam minum
  Future<bool> updateJamMinum(int id, String jam) async {
    try {
      final response = await _api.put('jadwal-obat/$id/jam-minum', {'jam_minum': jam});
      
      if (response['status'] == 'success') {
        print('✅ Jam minum berhasil diupdate');
        return true;
      } else {
        print('❌ Gagal update jam minum: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error updateJamMinum: $e');
      return false;
    }
  }

  /// Delete jadwal obat
  Future<bool> deleteJadwalObat(int id) async {
    try {
      final response = await _api.delete('jadwal-obat/$id');
      
      if (response['status'] == 'success') {
        print('✅ Jadwal obat berhasil dihapus');
        return true;
      } else {
        print('❌ Gagal hapus jadwal obat: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error deleteJadwalObat: $e');
      return false;
    }
  }

  /// Get jadwal obat aktif hari ini
  Future<List<JadwalObat>> getAktifHariIni() async {
    try {
      final response = await _api.get('jadwal-obat/aktif/hari-ini');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => JadwalObat.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada jadwal obat aktif hari ini');
        return [];
      }
    } catch (e) {
      print('⚠️ Error getAktifHariIni: $e');
      return [];
    }
  }
}