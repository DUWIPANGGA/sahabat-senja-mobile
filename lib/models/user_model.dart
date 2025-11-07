// models/user_model.dart
class User {
  final String uid;
  final String email;
  final String nama;
  final String nomorTelepon;
  final String role; // 'keluarga' atau 'perawat'
  final DateTime createdAt;

  User({
    required this.uid,
    required this.email,
    required this.nama,
    required this.nomorTelepon,
    required this.role,
    required this.createdAt,
  });
}