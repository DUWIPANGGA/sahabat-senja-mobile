// models/tracking_obat_model.dart
class TrackingObat {
  final int? id;
  final int jadwalObatId;
  final int datalansiaId;
  final String namaObat;
  final String dosis;
  final String waktu;
  final DateTime tanggal;
  final String? jamPemberian;
  final bool sudahDiberikan;
  final String? catatan;
  final int? perawatId;
  final String? namaPerawat;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TrackingObat({
    this.id,
    required this.jadwalObatId,
    required this.datalansiaId,
    required this.namaObat,
    required this.dosis,
    required this.waktu,
    required this.tanggal,
    this.jamPemberian,
    this.sudahDiberikan = false,
    this.catatan,
    this.perawatId,
    this.namaPerawat,
    this.createdAt,
    this.updatedAt,
  });

  factory TrackingObat.fromJson(Map<String, dynamic> json) {
    return TrackingObat(
      id: json['id'] as int?,
      jadwalObatId: json['jadwal_obat_id'] as int,
      datalansiaId: json['datalansia_id'] as int,
      namaObat: json['nama_obat'] ?? '',
      dosis: json['dosis'] ?? '',
      waktu: json['waktu'] ?? 'Pagi',
      tanggal: DateTime.parse(json['tanggal']),
      jamPemberian: json['jam_pemberian'],
      sudahDiberikan: json['sudah_diberikan'] ?? false,
      catatan: json['catatan'],
      perawatId: json['perawat_id'] as int?,
      namaPerawat: json['nama_perawat'],
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
      'jadwal_obat_id': jadwalObatId,
      'datalansia_id': datalansiaId,
      'nama_obat': namaObat,
      'dosis': dosis,
      'waktu': waktu,
      'tanggal': tanggal.toIso8601String().split('T')[0],
      if (jamPemberian != null) 'jam_pemberian': jamPemberian,
      'sudah_diberikan': sudahDiberikan,
      if (catatan != null) 'catatan': catatan,
      if (perawatId != null) 'perawat_id': perawatId,
    };
  }

  TrackingObat copyWith({
    int? id,
    int? jadwalObatId,
    int? datalansiaId,
    String? namaObat,
    String? dosis,
    String? waktu,
    DateTime? tanggal,
    String? jamPemberian,
    bool? sudahDiberikan,
    String? catatan,
    int? perawatId,
    String? namaPerawat,
  }) {
    return TrackingObat(
      id: id ?? this.id,
      jadwalObatId: jadwalObatId ?? this.jadwalObatId,
      datalansiaId: datalansiaId ?? this.datalansiaId,
      namaObat: namaObat ?? this.namaObat,
      dosis: dosis ?? this.dosis,
      waktu: waktu ?? this.waktu,
      tanggal: tanggal ?? this.tanggal,
      jamPemberian: jamPemberian ?? this.jamPemberian,
      sudahDiberikan: sudahDiberikan ?? this.sudahDiberikan,
      catatan: catatan ?? this.catatan,
      perawatId: perawatId ?? this.perawatId,
      namaPerawat: namaPerawat ?? this.namaPerawat,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    );
  }
}