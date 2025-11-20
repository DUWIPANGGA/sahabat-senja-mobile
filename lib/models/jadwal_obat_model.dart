class JadwalObat {
  final int id;
  final int datalansiaId;
  final String namaObat;
  final String dosis;
  final String waktu;
  final bool completed;
  final String? lastGiven;

  JadwalObat({
    required this.id,
    required this.datalansiaId,
    required this.namaObat,
    required this.dosis,
    required this.waktu,
    required this.completed,
    this.lastGiven,
  });

  factory JadwalObat.fromJson(Map<String, dynamic> json) {
    return JadwalObat(
      id: json['id'],
      datalansiaId: json['datalansia_id'],
      namaObat: json['nama_obat'],
      dosis: json['dosis'],
      waktu: json['waktu'],
      completed: json['completed'] == 1 || json['completed'] == true,
      lastGiven: json['last_given'],
    );
  }
}
