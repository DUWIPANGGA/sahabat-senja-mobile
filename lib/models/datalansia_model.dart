// lib/models/datalansia_model.dart
class Datalansia {
  final int? id;
  final String? noKamarLansia;
  final String namaLansia;
  final int? umurLansia;
  final String? tempatLahirLansia;
  final String tanggalLahirLansia;
  final String? jenisKelaminLansia;
  final String? golDarahLansia;
  final String? riwayatPenyakitLansia;
  final String? alergiLansia;
  final String? obatRutinLansia;
  final String? statusLansia;
  final String? namaAnak;
  final String? alamatLengkap;
  final String? noHpAnak;
  final String? emailAnak;
  final String? createdAt;
  final String? updatedAt;

  Datalansia({
    this.id,
    this.noKamarLansia,
    required this.namaLansia,
    this.umurLansia,
    this.tempatLahirLansia,
    required this.tanggalLahirLansia,
    this.jenisKelaminLansia,
    this.golDarahLansia,
    this.riwayatPenyakitLansia,
    this.alergiLansia,
    this.obatRutinLansia,
    this.statusLansia,
    this.namaAnak,
    this.alamatLengkap,
    this.noHpAnak,
    this.emailAnak,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'no_kamar_lansia': noKamarLansia,
      'nama_lansia': namaLansia,
      'umur_lansia': umurLansia,
      'tempat_lahir_lansia': tempatLahirLansia,
      'tanggal_lahir_lansia': tanggalLahirLansia,
      'jenis_kelamin_lansia': jenisKelaminLansia,
      'gol_darah_lansia': golDarahLansia,
      'riwayat_penyakit_lansia': riwayatPenyakitLansia,
      'alergi_lansia': alergiLansia,
      'obat_rutin_lansia': obatRutinLansia,
      'status_lansia': statusLansia,
      'nama_anak': namaAnak,
      'alamat_lengkap': alamatLengkap,
      'no_hp_anak': noHpAnak,
      'email_anak': emailAnak,
    };
  }

  factory Datalansia.fromJson(Map<String, dynamic> json) {
    return Datalansia(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      noKamarLansia: json['no_kamar_lansia']?.toString(),
      namaLansia: json['nama_lansia']?.toString() ?? '',
      umurLansia: json['umur_lansia'] != null ? int.tryParse(json['umur_lansia'].toString()) : null,
      tempatLahirLansia: json['tempat_lahir_lansia']?.toString(),
      tanggalLahirLansia: json['tanggal_lahir_lansia']?.toString() ?? '',
      jenisKelaminLansia: json['jenis_kelamin_lansia']?.toString(),
      golDarahLansia: json['gol_darah_lansia']?.toString(),
      riwayatPenyakitLansia: json['riwayat_penyakit_lansia']?.toString(),
      alergiLansia: json['alergi_lansia']?.toString(),
      obatRutinLansia: json['obat_rutin_lansia']?.toString(),
      statusLansia: json['status_lansia']?.toString(),
      namaAnak: json['nama_anak']?.toString(),
      alamatLengkap: json['alamat_lengkap']?.toString(),
      noHpAnak: json['no_hp_anak']?.toString(),
      emailAnak: json['email_anak']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  get nama => null;

  Datalansia copyWith({
    int? id,
    String? noKamarLansia,
    String? namaLansia,
    int? umurLansia,
    String? tempatLahirLansia,
    String? tanggalLahirLansia,
    String? jenisKelaminLansia,
    String? golDarahLansia,
    String? riwayatPenyakitLansia,
    String? alergiLansia,
    String? obatRutinLansia,
    String? statusLansia,
    String? namaAnak,
    String? alamatLengkap,
    String? noHpAnak,
    String? emailAnak,
  }) {
    return Datalansia(
      id: id ?? this.id,
      noKamarLansia: noKamarLansia ?? this.noKamarLansia,
      namaLansia: namaLansia ?? this.namaLansia,
      umurLansia: umurLansia ?? this.umurLansia,
      tempatLahirLansia: tempatLahirLansia ?? this.tempatLahirLansia,
      tanggalLahirLansia: tanggalLahirLansia ?? this.tanggalLahirLansia,
      jenisKelaminLansia: jenisKelaminLansia ?? this.jenisKelaminLansia,
      golDarahLansia: golDarahLansia ?? this.golDarahLansia,
      riwayatPenyakitLansia: riwayatPenyakitLansia ?? this.riwayatPenyakitLansia,
      alergiLansia: alergiLansia ?? this.alergiLansia,
      obatRutinLansia: obatRutinLansia ?? this.obatRutinLansia,
      statusLansia: statusLansia ?? this.statusLansia,
      namaAnak: namaAnak ?? this.namaAnak,
      alamatLengkap: alamatLengkap ?? this.alamatLengkap,
      noHpAnak: noHpAnak ?? this.noHpAnak,
      emailAnak: emailAnak ?? this.emailAnak,
    );
  }
}