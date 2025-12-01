// models/jadwal_obat_model.dart
class JadwalObat {
  final int? id;
  final int datalansiaId;
  final String namaObat;
  final String? deskripsi;
  final String dosis;
  final String waktu; // Pagi, Siang, Sore, Malam
  final String? jamMinum;
  final String frekuensi;
  final DateTime tanggalMulai;
  final DateTime? tanggalSelesai;
  final bool selesai;
  final String? catatan;
  final int? userId;
  final int? perawatId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JadwalObat({
    this.id,
    required this.datalansiaId,
    required this.namaObat,
    this.deskripsi,
    required this.dosis,
    required this.waktu,
    this.jamMinum,
    required this.frekuensi,
    required this.tanggalMulai,
    this.tanggalSelesai,
    this.selesai = false,
    this.catatan,
    this.userId,
    this.perawatId,
    this.createdAt,
    this.updatedAt,
  });

  factory JadwalObat.fromJson(Map<String, dynamic> json) {
    return JadwalObat(
      id: json['id'] as int?,
      datalansiaId: json['datalansia_id'] as int,
      namaObat: json['nama_obat'] ?? '',
      deskripsi: json['deskripsi'],
      dosis: json['dosis'] ?? '',
      waktu: json['waktu'] ?? 'Pagi',
      jamMinum: json['jam_minum'],
      frekuensi: json['frekuensi'] ?? 'Setiap Hari',
      tanggalMulai: DateTime.parse(json['tanggal_mulai']),
      tanggalSelesai: json['tanggal_selesai'] != null 
          ? DateTime.parse(json['tanggal_selesai']) 
          : null,
      selesai: json['selesai'] ?? false,
      catatan: json['catatan'],
      userId: json['user_id'] as int?,
      perawatId: json['perawat_id'] as int?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'datalansia_id': datalansiaId,
      'nama_obat': namaObat,
      if (deskripsi != null) 'deskripsi': deskripsi,
      'dosis': dosis,
      'waktu': waktu,
      if (jamMinum != null) 'jam_minum': jamMinum,
      'frekuensi': frekuensi,
      'tanggal_mulai': tanggalMulai.toIso8601String().split('T')[0],
      if (tanggalSelesai != null) 
        'tanggal_selesai': tanggalSelesai!.toIso8601String().split('T')[0],
      'selesai': selesai,
      if (catatan != null) 'catatan': catatan,
      if (perawatId != null) 'perawat_id': perawatId,
    };
  }

  JadwalObat copyWith({
    int? id,
    int? datalansiaId,
    String? namaObat,
    String? deskripsi,
    String? dosis,
    String? waktu,
    String? jamMinum,
    String? frekuensi,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    bool? selesai,
    String? catatan,
    int? userId,
    int? perawatId,
  }) {
    return JadwalObat(
      id: id ?? this.id,
      datalansiaId: datalansiaId ?? this.datalansiaId,
      namaObat: namaObat ?? this.namaObat,
      deskripsi: deskripsi ?? this.deskripsi,
      dosis: dosis ?? this.dosis,
      waktu: waktu ?? this.waktu,
      jamMinum: jamMinum ?? this.jamMinum,
      frekuensi: frekuensi ?? this.frekuensi,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      selesai: selesai ?? this.selesai,
      catatan: catatan ?? this.catatan,
      userId: userId ?? this.userId,
      perawatId: perawatId ?? this.perawatId,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    );
  }
}