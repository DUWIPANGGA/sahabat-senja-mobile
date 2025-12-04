// lib/services/datalansia_service.dart
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/services/api_service.dart';

class DatalansiaService {
  final ApiService _api = ApiService();

  // 🔹 Create data
  Future<Datalansia> createDatalansia(Datalansia datalansia) async {
    try {
      print('🔄 Mengirim data lansia ke API...');
      print('Data: ${datalansia.toJson()}');
      
      final response = await _api.post('datalansia', datalansia.toJson());
      
      print('📥 Response: $response');
      
      if (response['status'] == 'success') {
        final data = response['data'];
        print('✅ Data lansia berhasil disimpan ke Laravel');
        return Datalansia.fromJson(data);
      } else {
        throw Exception('Gagal menambahkan data: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error createDatalansia: $e');
      rethrow;
    }
  }

  // 🔹 Get all data
  Future<List<Datalansia>> getDatalansia() async {
    try {
      final response = await _api.get('datalansia');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((json) => Datalansia.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error getDatalansia: $e');
      rethrow;
    }
  }

  // 🔹 Get by ID
  Future<Datalansia> getDatalansiaById(int id) async {
    try {
      final response = await _api.get('datalansia/$id');
      
      if (response['status'] == 'success') {
        return Datalansia.fromJson(response['data']);
      } else {
        throw Exception('Data tidak ditemukan: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error getDatalansiaById: $e');
      rethrow;
    }
  }

  // 🔹 Get by keluarga email
  Future<List<Datalansia>> getDatalansiaByKeluarga(String email) async {
    try {
      final response = await _api.get('datalansia/keluarga/$email');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        print(response['data'].toString());
        return data.map((json) => Datalansia.fromJson(json)).toList();
      } else {
        print('⚠️ Tidak ada data untuk email $email: ${response['message']}');
        return [];
      }
    } catch (e) {
      print('❌ Error getDatalansiaByKeluarga: $e');
      return [];
    }
  }

  // 🔹 Update data
  Future<Datalansia> updateDatalansia(int id, Datalansia datalansia) async {
    try {
      final response = await _api.put('datalansia/$id', datalansia.toJson());
      
      if (response['status'] == 'success') {
        return Datalansia.fromJson(response['data']);
      } else {
        throw Exception('Gagal memperbarui data: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error updateDatalansia: $e');
      rethrow;
    }
  }

  // 🔹 Delete data
  Future<bool> deleteDatalansia(int id) async {
    try {
      final response = await _api.delete('datalansia/$id');
      return response['status'] == 'success';
    } catch (e) {
      print('❌ Error deleteDatalansia: $e');
      return false;
    }
  }
}