class MonitoringData {
  final String id;
  final String lansiaNama;
  final DateTime tanggal;
  final String tekananDarah;
  final String nadi;
  final String nafsuMakan;
  final String statusObat;
  final String catatan;
  final String status;
  final String? kamar;

  MonitoringData({
    required this.id,
    required this.lansiaNama,
    required this.tanggal,
    required this.tekananDarah,
    required this.nadi,
    required this.nafsuMakan,
    required this.statusObat,
    required this.catatan,
    required this.status,
    this.kamar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lansiaNama': lansiaNama,
      'tanggal': tanggal.toIso8601String(),
      'tekananDarah': tekananDarah,
      'nadi': nadi,
      'nafsuMakan': nafsuMakan,
      'statusObat': statusObat,
      'catatan': catatan,
      'status': status,
      'kamar': kamar,
    };
  }

  factory MonitoringData.fromMap(Map<String, dynamic> map) {
    return MonitoringData(
      id: map['id'],
      lansiaNama: map['lansiaNama'],
      tanggal: DateTime.parse(map['tanggal']),
      tekananDarah: map['tekananDarah'],
      nadi: map['nadi'],
      nafsuMakan: map['nafsuMakan'],
      statusObat: map['statusObat'],
      catatan: map['catatan'],
      status: map['status'],
      kamar: map['kamar'],
    );
  }

  // Get tekanan darah sistolik dan diastolik
  int get sistolik {
    try {
      return int.parse(tekananDarah.split('/')[0]);
    } catch (e) {
      return 0;
    }
  }

  int get diastolik {
    try {
      return int.parse(tekananDarah.split('/')[1]);
    } catch (e) {
      return 0;
    }
  }

  int get nadiValue {
    try {
      return int.parse(nadi);
    } catch (e) {
      return 0;
    }
  }
}