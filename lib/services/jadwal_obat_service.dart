// services/jadwal_obat_service.dart
import 'package:sahabatsenja_app/services/api_service.dart';
import 'package:sahabatsenja_app/models/jadwal_obat_model.dart';
import 'package:intl/intl.dart';

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

  /// Get jadwal obat aktif hari ini
  Future<List<JadwalObat>> getAktifHariIni([String? tanggal]) async {
    try {
      final today = tanggal ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await _api.get('jadwal-obat/aktif/hari-ini?tanggal=$today');
      
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

  /// Get jadwal obat by tanggal
  Future<List<JadwalObat>> getByTanggal(String tanggal) async {
    try {
      final response = await _api.get('jadwal-obat/tanggal/$tanggal');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => JadwalObat.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada jadwal obat pada tanggal $tanggal');
        return [];
      }
    } catch (e) {
      print('⚠️ Error getByTanggal: $e');
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

  /// Update status selesai (alias untuk updateSelesai)
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

  /// Update status selesai (mirip dengan updateStatus)
  Future<bool> updateSelesai(int id, bool selesai) async {
    return updateStatus(id, selesai);
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

  /// Get summary jadwal obat
  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await _api.get('jadwal-obat/summary');
      
      if (response['status'] == 'success') {
        return response['data'] ?? {};
      } else {
        print('⚠️ Gagal get summary: ${response['message']}');
        return {};
      }
    } catch (e) {
      print('⚠️ Error getSummary: $e');
      return {};
    }
  }

  /// Get jadwal obat yang belum selesai hari ini
  Future<List<JadwalObat>> getTodayPending() async {
    try {
      final response = await _api.get('jadwal-obat/today/pending');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => JadwalObat.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada jadwal obat pending hari ini');
        return [];
      }
    } catch (e) {
      print('⚠️ Error getTodayPending: $e');
      return [];
    }
  }

  /// Mark multiple obat as done
  Future<bool> markMultipleAsDone(List<int> ids) async {
    try {
      final response = await _api.post('jadwal-obat/mark-multiple', {'ids': ids});
      
      if (response['status'] == 'success') {
        print('✅ ${ids.length} obat berhasil ditandai selesai');
        return true;
      } else {
        print('❌ Gagal mark multiple: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error markMultipleAsDone: $e');
      return false;
    }
  }

Future<List<JadwalObat>> getTodayForLansia(int datalansiaId, String tanggal) async {
  try {
    // Coba endpoint spesifik
    final response = await _api.get('jadwal-obat/lansia/$datalansiaId/today/$tanggal');
    
    if (response['status'] == 'success') {
      final List<dynamic> data = response['data'];
      return data.map((e) => JadwalObat.fromJson(e)).toList();
    } else {
      // Fallback: ambil semua dan filter
      print('⚠️ Tidak ada endpoint spesifik, menggunakan fallback');
      final allObat = await getByLansia(datalansiaId);
      return allObat.where((obat) {
        final isHariIni = DateFormat('yyyy-MM-dd').format(obat.tanggalMulai) == tanggal;
        final isAktif = !obat.selesai && 
            (obat.tanggalSelesai == null || 
             DateFormat('yyyy-MM-dd').format(obat.tanggalSelesai!).compareTo(tanggal) >= 0);
        return isHariIni || isAktif;
      }).toList();
    }
  } catch (e) {
    print('⚠️ Error getTodayForLansia: $e');
    return [];
  }
}

/// Get obat berdasarkan tanggal
Future<List<JadwalObat>> getByDate(int? datalansiaId, String tanggal) async {
  try {
    String endpoint;
    if (datalansiaId != null) {
      endpoint = 'jadwal-obat/lansia/$datalansiaId/date/$tanggal';
    } else {
      endpoint = 'jadwal-obat/date/$tanggal';
    }
    
    final response = await _api.get(endpoint);
    
    if (response['status'] == 'success') {
      final List<dynamic> data = response['data'];
      return data.map((e) => JadwalObat.fromJson(e)).toList();
    } else {
      print('⚠️ Tidak ada data obat pada tanggal $tanggal');
      return [];
    }
  } catch (e) {
    print('⚠️ Error getByDate: $e');
    return [];
  }
}
  /// Get upcoming obat (7 hari ke depan)
  Future<List<JadwalObat>> getUpcomingObat(int datalansiaId) async {
    try {
      final response = await _api.get('jadwal-obat/lansia/$datalansiaId/upcoming');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => JadwalObat.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada jadwal obat upcoming untuk lansia $datalansiaId');
        return [];
      }
    } catch (e) {
      print('⚠️ Error getUpcomingObat: $e');
      return [];
    }
  }
}