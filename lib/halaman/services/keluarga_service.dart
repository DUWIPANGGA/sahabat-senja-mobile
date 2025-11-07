import 'package:sahabatsenja_app/models/keluarga_model.dart';
import 'package:sahabatsenja_app/halaman/services/biodata_service.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';

class KeluargaService {
  final List<KeluargaUser> _keluargaUsers = [];
  final BiodataService _biodataService = BiodataService();

  String? _currentUserId;
  String? _currentUserNama;
  String? _currentUserNomor;

  KeluargaService() {
    _initialize();
  }

  void _initialize() {
    _biodataService.initializeDemoData();
    _autoDetectCurrentUser();
  }

  void _autoDetectCurrentUser() async {
    final allBiodata = await _biodataService.getAllBiodata();
    if (allBiodata.isNotEmpty) {
      final first = allBiodata.first;
      setCurrentUser('user_${first.dataKeluarga.toLowerCase()}',
          first.dataKeluarga, first.nomorKeluarga);
    }
  }

  void _autoConnectLansiaByRelationship() async {
    final currentUser = getCurrentUser();
    if (currentUser == null) return;
    final allBiodata = await _biodataService.getAllBiodata();
    for (var b in allBiodata) {
      if ((b.dataKeluarga
                  .toLowerCase()
                  .contains(_currentUserNama?.toLowerCase() ?? '') ||
              b.nomorKeluarga == _currentUserNomor) &&
          !currentUser.lansiaTerhubung.contains(b.namaLengkap)) {
        currentUser.lansiaTerhubung.add(b.namaLengkap);
      }
    }
  }

  KeluargaUser? getCurrentUser() {
    if (_currentUserId == null) return null;
    try {
      return _keluargaUsers.firstWhere((u) => u.id == _currentUserId);
    } catch (_) {
      return null;
    }
  }

  Future<List<Datalansia>> getLansiaTerhubung() async {
    final user = getCurrentUser();
    if (user == null) return [];
    final all = await _biodataService.getAllBiodata();
    return all
        .where((l) => user.lansiaTerhubung.contains(l.namaLengkap))
        .toList();
  }

  void setCurrentUser(String userId, String nama, String nomor) {
    _currentUserId = userId;
    _currentUserNama = nama;
    _currentUserNomor = nomor;

    try {
      _keluargaUsers.firstWhere((u) => u.id == userId);
    } catch (_) {
      _keluargaUsers.add(KeluargaUser(
        id: userId,
        nama: nama,
        email: '$nama@email.com',
        nomorTelepon: nomor,
        lansiaTerhubung: [],
      ));
    }

    _autoConnectLansiaByRelationship();
  }
}
