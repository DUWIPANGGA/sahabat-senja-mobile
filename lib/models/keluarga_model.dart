// models/keluarga_model.dart
class KeluargaUser {
  final String id;
  final String nama;
  final String email;
  final String nomorTelepon;
  final List<String> lansiaTerhubung; // List of lansia IDs/nama

  KeluargaUser({
    required this.id,
    required this.nama,
    required this.email,
    required this.nomorTelepon,
    required this.lansiaTerhubung,
  });
}