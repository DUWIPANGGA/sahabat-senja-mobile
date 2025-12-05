// services/jadwal_aktivitas_service.dart - PERBAIKAN
import 'package:sahabatsenja_app/models/jadwal_aktivitas_model.dart';
import 'package:sahabatsenja_app/services/api_service.dart';

class JadwalAktivitasService {
  final ApiService _api = ApiService();

  /// 🔹 Get all jadwal aktivitas
  Future<List<JadwalAktivitas>> getAllJadwal({
    int? datalansiaId,
    String? hari,
    String? status,
    bool? completed,
  }) async {
    try {
      String endpoint = 'jadwal'; // PERBAIKAN: dari 'jadwal-aktivitas' ke 'jadwal'
      Map<String, String> params = {};
      
      if (datalansiaId != null) params['datalansia_id'] = datalansiaId.toString();
      if (hari != null) params['hari'] = hari;
      if (status != null) params['status'] = status;
      if (completed != null) params['completed'] = completed.toString();
      
      if (params.isNotEmpty) {
        endpoint += '?${Uri(queryParameters: params).query}';
      }
      
      print('🌐 GET Jadwal: $endpoint');
      
      final response = await _api.get(endpoint);
      
      print('📥 Response: ${response['status']}');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        print('✅ Data jadwal ditemukan: ${data.length} item');
        return data.map((e) => JadwalAktivitas.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil jadwal: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error getAllJadwal: $e');
      rethrow;
    }
  }

  /// 🔹 Get jadwal hari ini
  Future<List<JadwalAktivitas>> getJadwalHariIni() async {
    try {
      print('🌐 GET Jadwal Hari Ini');
      final response = await _api.get('jadwal/today'); // PERBAIKAN: dari 'jadwal-aktivitas/hari-ini' ke 'jadwal/today'
      
      print('📥 Response: ${response.toString()}');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        print('✅ Jadwal hari ini ditemukan: ${data.length} item');
        return data.map((e) => JadwalAktivitas.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada jadwal hari ini: ${response['message']}');
        return [];
      }
    } catch (e) {
      print('❌ Error getJadwalHariIni: $e');
      return [];
    }
  }

  /// 🔹 Get jadwal by lansia ID
  Future<List<JadwalAktivitas>> getJadwalByLansia(int datalansiaId) async {
    try {
      final response = await _api.get('jadwal/lansia/$datalansiaId'); // PERBAIKAN: dari 'jadwal-aktivitas/lansia/$datalansiaId' ke 'jadwal/lansia/$datalansiaId'
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((e) => JadwalAktivitas.fromJson(e)).toList();
      } else {
        print('⚠️ Tidak ada jadwal untuk lansia: ${response['message']}');
        return [];
      }
    } catch (e) {
      print('❌ Error getJadwalByLansia: $e');
      return [];
    }
  }

  /// 🔹 Create new jadwal aktivitas
  Future<JadwalAktivitas> createJadwal(JadwalAktivitas jadwal) async {
    try {
      print('🌐 POST Jadwal: ${jadwal.toJson()}');
      final response = await _api.post('jadwal', jadwal.toJson()); // PERBAIKAN: dari 'jadwal-aktivitas' ke 'jadwal'
      
      if (response['status'] == 'success') {
        print('✅ Jadwal aktivitas berhasil ditambahkan');
        return JadwalAktivitas.fromJson(response['data']);
      } else {
        throw Exception('Gagal menambah jadwal: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error createJadwal: $e');
      rethrow;
    }
  }

  /// 🔹 Update jadwal aktivitas
  Future<JadwalAktivitas> updateJadwal(int id, JadwalAktivitas jadwal) async {
    try {
      final response = await _api.put('jadwal/$id', jadwal.toJson()); // PERBAIKAN: dari 'jadwal-aktivitas/$id' ke 'jadwal/$id'
      
      if (response['status'] == 'success') {
        print('✅ Jadwal aktivitas berhasil diperbarui');
        return JadwalAktivitas.fromJson(response['data']);
      } else {
        throw Exception('Gagal memperbarui jadwal: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error updateJadwal: $e');
      rethrow;
    }
  }

  /// 🔹 Update status completed
  Future<JadwalAktivitas> updateCompleted(int id, bool completed) async {
    try {
      final response = await _api.put('jadwal/$id/completed', { // PERBAIKAN: dari 'jadwal-aktivitas/$id/complete' ke 'jadwal/$id/completed'
        'completed': completed,
      });
      
      if (response['status'] == 'success') {
        print('✅ Status jadwal berhasil diperbarui');
        return JadwalAktivitas.fromJson(response['data']);
      } else {
        throw Exception('Gagal memperbarui status: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error updateCompleted: $e');
      rethrow;
    }
  }

  /// 🔹 Delete jadwal aktivitas
  Future<bool> deleteJadwal(int id) async {
    try {
      final response = await _api.delete('jadwal/$id'); // PERBAIKAN: dari 'jadwal-aktivitas/$id' ke 'jadwal/$id'
      
      if (response['status'] == 'success') {
        print('✅ Jadwal aktivitas berhasil dihapus');
        return true;
      } else {
        throw Exception('Gagal menghapus jadwal: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error deleteJadwal: $e');
      rethrow;
    }
  }

  /// 🔹 Get jadwal statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _api.get('jadwal/today'); // PERBAIKAN: dari 'jadwal-aktivitas/hari-ini' ke 'jadwal/today'
      
      if (response['status'] == 'success') {
        final meta = response['meta'] ?? {};
        final data = response['data'] as List;
        
        final total = data.length;
        final completed = data.where((item) => item['completed'] == true).length;
        final pending = total - completed;
        
        return {
          'total': total,
          'completed': completed,
          'pending': pending,
          'hari': meta['hari'] ?? '',
          'persentase': total > 0 ? (completed / total * 100).round() : 0,
        };
      } else {
        return {
          'total': 0,
          'completed': 0,
          'pending': 0,
          'hari': '',
          'persentase': 0,
        };
      }
    } catch (e) {
      print('❌ Error getStatistics: $e');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'hari': '',
        'persentase': 0,
      };
    }
  }

  /// 🔹 Get hari Indonesia
  String getHariIndonesia() {
    final now = DateTime.now();
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];
    return days[now.weekday % 7];
  }

  /// 🔹 Debug endpoints
  Future<void> debugEndpoints() async {
    try {
      print('🔍 Debugging jadwal endpoints...');
      
      // Test endpoint today
      final todayResponse = await _api.get('jadwal/today');
      print('📊 Today endpoint: ${todayResponse['status']}');
      print('📊 Today data: ${todayResponse['data']}');
      
      // Test base endpoint
      final baseResponse = await _api.get('jadwal');
      print('📊 Base endpoint: ${baseResponse['status']}');
      print('📊 Base data count: ${(baseResponse['data'] as List).length}');
      
      // Test endpoint dengan params
      final hariIni = getHariIndonesia();
      final filteredResponse = await _api.get('jadwal?hari=$hariIni');
      print('📊 Filtered endpoint: ${filteredResponse['status']}');
      print('📊 Filtered data count: ${(filteredResponse['data'] as List).length}');
      
    } catch (e) {
      print('❌ Debug error: $e');
    }
  }
}