// models/kondisi_model.dart
class KondisiHarian {
  final int? id;
  final String namaLansia; // Wajib ada
  final DateTime tanggal;
  final String? tekananDarah;
  final String? nadi;
  final String? nafsuMakan;
  final String? statusObat;
  final String? catatan;
  final String? status;
  final int? datalansiaId; // ID dari tabel datalansia (opsional)

  KondisiHarian({
    this.id,
    required this.namaLansia, // Wajib
    required this.tanggal,
    this.tekananDarah,
    this.nadi,
    this.nafsuMakan,
    this.statusObat,
    this.catatan,
    this.status,
    this.datalansiaId,
  });

  factory KondisiHarian.fromJson(Map<String, dynamic> json) {
    return KondisiHarian(
      id: json['id'] as int?,
      namaLansia: json['nama_lansia'] ?? json['nama'] ?? '',
      tanggal: DateTime.parse(json['tanggal'] ?? DateTime.now().toString()),
      tekananDarah: json['tekanan_darah'],
      nadi: json['nadi']?.toString(),
      nafsuMakan: json['nafsu_makan'],
      statusObat: json['status_obat'],
      catatan: json['catatan'],
      status: json['status'],
      datalansiaId: json['datalansia_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_lansia': namaLansia, // Pastikan ini tidak null
      'tanggal': tanggal.toIso8601String(),
      'tekanan_darah': tekananDarah,
      'nadi': nadi,
      'nafsu_makan': nafsuMakan,
      'status_obat': statusObat,
      'catatan': catatan,
      'status': status,
      if (datalansiaId != null) 'datalansia_id': datalansiaId,
    };
  }

  @override
  String toString() {
    return 'KondisiHarian(id: $id, namaLansia: $namaLansia, tanggal: $tanggal)';
  }
}