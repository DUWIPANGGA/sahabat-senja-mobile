import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/models/keluarga_model.dart';
import 'package:sahabatsenja_app/services/datalansia_service.dart';
import 'package:sahabatsenja_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeluargaService {
  final DatalansiaService _datalansiaService = DatalansiaService();
  final ApiService _api = ApiService();
  
  KeluargaUser? _currentUser;
  List<Datalansia> _lansiaTerhubung = [];

  // 🔹 Ambil user dari SharedPreferences
  Future<KeluargaUser?> getCurrentUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      final role = prefs.getString('user_role');
      
      if (name != null && email != null && role == 'keluarga') {
        _currentUser = KeluargaUser(
          id: email, // Gunakan email sebagai ID
          nama: name,
          email: email,
          nomorTelepon: '', // Ambil dari user data jika ada
          lansiaTerhubung: [],
        );
        
        // Load lansia terhubung berdasarkan email user
        await _loadLansiaTerhubung();
        
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('❌ Error getCurrentUserFromStorage: $e');
      return null;
    }
  }

  // 🔹 Load lansia terhubung berdasarkan email user
  Future<void> _loadLansiaTerhubung() async {
    try {
      if (_currentUser == null) return;
      
      // Ambil data lansia yang email_anaknya sama dengan email user
      final data = await _datalansiaService.getDatalansiaByKeluarga(_currentUser!.email);
      
      setState(() {
        _lansiaTerhubung = data;
        // Update lansia terhubung di user
        if (_currentUser != null) {
          _currentUser = KeluargaUser(
            id: _currentUser!.id,
            nama: _currentUser!.nama,
            email: _currentUser!.email,
            nomorTelepon: _currentUser!.nomorTelepon,
            lansiaTerhubung: data.map((l) => l.namaLansia ?? '').toList(),
          );
        }
      });
    } catch (e) {
      print('❌ Error _loadLansiaTerhubung: $e');
      _lansiaTerhubung = [];
    }
  }

  // 🔹 Get current user
  KeluargaUser? getCurrentUser() {
    return _currentUser;
  }

  // 🔹 Get lansia terhubung (sudah di-load dari API)
  Future<List<Datalansia>> getLansiaTerhubung() async {
    return _lansiaTerhubung;
  }

  // 🔹 Set current user (untuk login)
  Future<void> setCurrentUser(String userId, String nama, String email) async {
    _currentUser = KeluargaUser(
      id: userId,
      nama: nama,
      email: email,
      nomorTelepon: '', // Isi jika ada data tambahan
      lansiaTerhubung: [],
    );
    
    // Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', nama);
    await prefs.setString('user_email', email);
    await prefs.setString('user_role', 'keluarga');
    
    // Load data lansia yang terkait
    await _loadLansiaTerhubung();
  }

  // 🔹 Tambah lansia terhubung (jika ada fitur connect)
  Future<bool> addLansiaTerhubung(Datalansia lansia) async {
    try {
      // Cek apakah lansia sudah ada
      if (_lansiaTerhubung.any((l) => l.id == lansia.id)) {
        return false;
      }
      
      setState(() {
        _lansiaTerhubung.add(lansia);
        if (_currentUser != null) {
          _currentUser!.lansiaTerhubung.add(lansia.namaLansia ?? '');
        }
      });
      return true;
    } catch (e) {
      print('❌ Error addLansiaTerhubung: $e');
      return false;
    }
  }

  // 🔹 Hapus lansia terhubung
  Future<bool> removeLansiaTerhubung(int lansiaId) async {
    try {
      final index = _lansiaTerhubung.indexWhere((l) => l.id == lansiaId);
      if (index != -1) {
        final removedLansia = _lansiaTerhubung[index];
        
        setState(() {
          _lansiaTerhubung.removeAt(index);
          if (_currentUser != null) {
            _currentUser!.lansiaTerhubung.remove(removedLansia.namaLansia ?? '');
          }
        });
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error removeLansiaTerhubung: $e');
      return false;
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    
    setState(() {
      _currentUser = null;
      _lansiaTerhubung = [];
    });
  }

  // 🔹 Refresh data
  Future<void> refreshData() async {
    await _loadLansiaTerhubung();
  }

  // 🔹 Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    final email = prefs.getString('user_email');
    return role == 'keluarga' && email != null;
  }

  // 🔹 Get user profile dari API (jika ada endpoint khusus)
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _api.get('auth/user');
      if (response['status'] == 'success') {
        return response['data']['user'];
      }
      return null;
    } catch (e) {
      print('❌ Error getUserProfile: $e');
      return null;
    }
  }

  // 🔹 Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _api.put('auth/profile', data);
      if (response['status'] == 'success') {
        // Update current user
        final userData = response['data']['user'];
        if (_currentUser != null) {
          _currentUser = KeluargaUser(
            id: _currentUser!.id,
            nama: userData['name'] ?? _currentUser!.nama,
            email: userData['email'] ?? _currentUser!.email,
            nomorTelepon: userData['no_telepon'] ?? _currentUser!.nomorTelepon,
            lansiaTerhubung: _currentUser!.lansiaTerhubung,
          );
          
          // Update SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', _currentUser!.nama);
          await prefs.setString('user_email', _currentUser!.email);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updateProfile: $e');
      return false;
    }
  }

  // 🔹 Helper untuk update UI (gunakan jika pakai provider/state management)
  void setState(void Function() callback) {
    callback();
    // Jika pakai provider, panggil notifyListeners() di sini
    // notifyListeners();
  }
}