// models/jadwal_aktivitas_model.dart
class JadwalAktivitas {
  final int? id;
  final String namaAktivitas;
  final String jam;
  final String? keterangan;
  final String? hari;
  final String status;
  final bool completed; // Tetap final karena immutable
  final int? datalansiaId;
  final int? userId;
  final int? perawatId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JadwalAktivitas({
    this.id,
    required this.namaAktivitas,
    required this.jam,
    this.keterangan,
    this.hari,
    this.status = 'pending',
    this.completed = false,
    this.datalansiaId,
    this.userId,
    this.perawatId,
    this.createdAt,
    this.updatedAt,
  });

  // 🔹 Copy with method untuk update immutable object
  JadwalAktivitas copyWith({
    int? id,
    String? namaAktivitas,
    String? jam,
    String? keterangan,
    String? hari,
    String? status,
    bool? completed,
    int? datalansiaId,
    int? userId,
    int? perawatId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JadwalAktivitas(
      id: id ?? this.id,
      namaAktivitas: namaAktivitas ?? this.namaAktivitas,
      jam: jam ?? this.jam,
      keterangan: keterangan ?? this.keterangan,
      hari: hari ?? this.hari,
      status: status ?? this.status,
      completed: completed ?? this.completed,
      datalansiaId: datalansiaId ?? this.datalansiaId,
      userId: userId ?? this.userId,
      perawatId: perawatId ?? this.perawatId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

factory JadwalAktivitas.fromJson(Map<String, dynamic> json) {
  int? safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.tryParse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String? safeString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  return JadwalAktivitas(
    id: safeInt(json['id']),
    namaAktivitas: json['nama_aktivitas']?.toString() ?? '',
    jam: json['jam']?.toString() ?? '',
    keterangan: safeString(json['keterangan']),
    hari: safeString(json['hari']),
    status: json['status']?.toString() ?? 'pending',
    completed: json['completed'] == true || 
                json['completed'] == 1 || 
                (json['completed'] is String && json['completed'] == '1'),
    datalansiaId: safeInt(json['datalansia_id']),
    userId: safeInt(json['user_id']),
    perawatId: safeInt(json['perawat_id']),
    createdAt: json['created_at'] != null 
        ? DateTime.tryParse(json['created_at'].toString()) 
        : null,
    updatedAt: json['updated_at'] != null 
        ? DateTime.tryParse(json['updated_at'].toString()) 
        : null,
  );
}
  Map<String, dynamic> toJson() {
    return {
      'nama_aktivitas': namaAktivitas,
      'jam': jam,
      if (keterangan != null) 'keterangan': keterangan,
      if (hari != null) 'hari': hari,
      'status': status,
      'completed': completed,
      if (datalansiaId != null) 'datalansia_id': datalansiaId,
      if (perawatId != null) 'perawat_id': perawatId,
    };
  }

  @override
  String toString() {
    return 'JadwalAktivitas(id: $id, namaAktivitas: $namaAktivitas, jam: $jam, completed: $completed)';
  }
}