import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? noTelepon;
  final String? alamat;
  final String? profilePicture;
  final String? firebaseUid;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.noTelepon,
    this.alamat,
    this.profilePicture,
    this.firebaseUid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      noTelepon: json['no_telepon'],
      alamat: json['alamat'],
      profilePicture: json['profile_picture'] ?? json['profile_photo'],
      firebaseUid: json['firebase_uid'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'profile_picture': profilePicture,
      'firebase_uid': firebaseUid,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? noTelepon,
    String? alamat,
    String? profilePicture,
    String? firebaseUid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      noTelepon: noTelepon ?? this.noTelepon,
      alamat: alamat ?? this.alamat,
      profilePicture: profilePicture ?? this.profilePicture,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method untuk mendapatkan role dalam bahasa Indonesia
  String get roleName {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'perawat':
        return 'Perawat';
      case 'keluarga':
        return 'Keluarga Lansia';
      default:
        return role;
    }
  }

  // Helper method untuk mendapatkan URL foto profil lengkap
  String? get profilePictureUrl {
    if (profilePicture == null || profilePicture!.isEmpty) {
      return null;
    }
    
    // Jika sudah URL lengkap
    if (profilePicture!.startsWith('http')) {
      return profilePicture;
    }
    
    // Jika relative path, tambahkan base URL
    return 'http://10.0.175.106:8000/storage/$profilePicture';
  }

  // Helper untuk mendapatkan inisial nama
  String get initials {
    if (name.isEmpty) return 'U';
    
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    noTelepon,
    alamat,
    profilePicture,
    firebaseUid,
    createdAt,
    updatedAt,
  ];
}