class KondisiHarian {
  final String nama;
  final String kamar;
  final String tekananDarah;
  final String nadi;
  final String statusObat;
  final String nafsuMakan;
  final String catatan;
  final DateTime tanggal;
  final String status;

  KondisiHarian({
    required this.nama,
    required this.kamar,
    required this.tekananDarah,
    required this.nadi,
    required this.statusObat,
    required this.nafsuMakan,
    required this.catatan,
    required this.tanggal,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'kamar': kamar,
      'tekananDarah': tekananDarah,
      'nadi': nadi,
      'statusObat': statusObat,
      'nafsuMakan': nafsuMakan,
      'catatan': catatan,
      'tanggal': tanggal.toIso8601String(),
      'status': status,
    };
  }

  factory KondisiHarian.fromMap(Map<String, dynamic> map) {
    return KondisiHarian(
      nama: map['nama'],
      kamar: map['kamar'],
      tekananDarah: map['tekananDarah'],
      nadi: map['nadi'],
      statusObat: map['statusObat'],
      nafsuMakan: map['nafsuMakan'],
      catatan: map['catatan'],
      tanggal: DateTime.parse(map['tanggal']),
      status: map['status'],
    );
  }
}