// services/tracking_obat_service.dart
import 'package:sahabatsenja_app/services/api_service.dart';
import 'package:sahabatsenja_app/models/tracking_obat_model.dart';

class TrackingObatService {
  final ApiService _api = ApiService();

  /// Get all tracking obat
  Future<List<TrackingObat>> fetchAllTracking() async {
    try {
      final response = await _api.get('tracking-obat');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => TrackingObat.fromJson(e)).toList();
      } else {
        throw Exception('Gagal fetch tracking obat: ${response['message']}');
      }
    } catch (e) {
      print('⚠️ Error fetchAllTracking: $e');
      rethrow;
    }
  }

  /// Get tracking by tanggal
  Future<List<TrackingObat>> fetchByTanggal(DateTime tanggal) async {
    try {
      final formattedDate = '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
      final response = await _api.get('tracking-obat/tanggal/$formattedDate');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => TrackingObat.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada tracking untuk tanggal $formattedDate');
        return [];
      }
    } catch (e) {
      print('⚠️ Error fetchByTanggal: $e');
      return [];
    }
  }

  /// Get tracking hari ini
  Future<List<TrackingObat>> fetchHariIni() async {
    try {
      final today = DateTime.now();
      return await fetchByTanggal(today);
    } catch (e) {
      print('⚠️ Error fetchHariIni: $e');
      return [];
    }
  }

  /// Get tracking by lansia
  Future<List<TrackingObat>> fetchByLansia(int datalansiaId) async {
    try {
      final response = await _api.get('tracking-obat/lansia/$datalansiaId');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => TrackingObat.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada tracking untuk lansia $datalansiaId');
        return [];
      }
    } catch (e) {
      print('⚠️ Error fetchByLansia: $e');
      return [];
    }
  }

  /// Create new tracking
  Future<bool> createTracking(TrackingObat tracking) async {
    try {
      final response = await _api.post('tracking-obat', tracking.toJson());
      
      if (response['status'] == 'success') {
        print('✅ Tracking obat berhasil dibuat');
        return true;
      } else {
        print('❌ Gagal buat tracking: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error createTracking: $e');
      return false;
    }
  }

  /// Update status pemberian obat
  Future<bool> updateStatus(int id, bool sudahDiberikan, {String? jamPemberian, String? catatan}) async {
    try {
      final data = {
        'sudah_diberikan': sudahDiberikan,
        if (jamPemberian != null) 'jam_pemberian': jamPemberian,
        if (catatan != null) 'catatan': catatan,
      };
      
      final response = await _api.put('tracking-obat/$id/status', data);
      
      if (response['status'] == 'success') {
        print('✅ Status tracking berhasil diupdate');
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

  /// Update catatan
  Future<bool> updateCatatan(int id, String catatan) async {
    try {
      final response = await _api.put('tracking-obat/$id/catatan', {
        'catatan': catatan,
      });
      
      if (response['status'] == 'success') {
        print('✅ Catatan tracking berhasil diupdate');
        return true;
      } else {
        print('❌ Gagal update catatan: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error updateCatatan: $e');
      return false;
    }
  }

  /// Generate tracking dari jadwal obat aktif
  Future<bool> generateTrackingHariIni() async {
    try {
      final response = await _api.post('tracking-obat/generate/hari-ini', {});
      
      if (response['status'] == 'success') {
        print('✅ Tracking hari ini berhasil digenerate');
        return true;
      } else {
        print('❌ Gagal generate tracking: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error generateTrackingHariIni: $e');
      return false;
    }
  }
}