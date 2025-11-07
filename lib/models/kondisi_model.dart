class KondisiHarian {
  final int? id;
  final int idLansia;
  final String tekananDarah;
  final int nadi;
  final String nafsuMakan;
  final String statusObat;
  final String? catatan; // nullable
  final String status;
  final DateTime tanggal;

  KondisiHarian({
    this.id,
    required this.idLansia,
    required this.tekananDarah,
    required this.nadi,
    required this.nafsuMakan,
    required this.statusObat,
    this.catatan,
    required this.status,
    required this.tanggal,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_lansia': idLansia,
      'tekanan_darah': tekananDarah,
      'nadi': nadi,
      'nafsu_makan': nafsuMakan,
      'status_obat': statusObat,
      'catatan': catatan ?? '',
      'status': status,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  factory KondisiHarian.fromJson(Map<String, dynamic> json) {
    return KondisiHarian(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      idLansia: json['id_lansia'] is int
          ? json['id_lansia']
          : int.tryParse(json['id_lansia'].toString()) ?? 0,
      tekananDarah: json['tekanan_darah']?.toString() ?? '',
      nadi: json['nadi'] is int ? json['nadi'] : int.tryParse(json['nadi'].toString()) ?? 0,
      nafsuMakan: json['nafsu_makan']?.toString() ?? '',
      statusObat: json['status_obat']?.toString() ?? '',
      catatan: json['catatan']?.toString(),
      status: json['status']?.toString() ?? '',
      tanggal: DateTime.tryParse(json['tanggal'].toString()) ?? DateTime.now(),
    );
  }
}
