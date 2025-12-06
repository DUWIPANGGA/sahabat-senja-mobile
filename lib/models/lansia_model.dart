// models/datalansia_model.dart
import 'dart:convert';

class Datalansia {
  int? id;
  String namaLansia;
  int umurLansia;
  String? tempatLahirLansia;
  DateTime? tanggalLahirLansia;
  String? jenisKelaminLansia;
  String? golDarahLansia;
  String? riwayatPenyakitLansia;
  String? alergiLansia;
  String? obatRutinLansia;
  String? catatanKhusus;
  String namaAnak;
  String alamatLengkap;
  String noHpAnak;
  String emailAnak;
  String? kontakDaruratNama;
  String? kontakDaruratHp;
  String? kontakDaruratHubungan;
  int? kamarId;
  int? userId;
  int? perawatId;
  String? tanggalMasuk;
  String? tanggalKeluar;
  String? statusLansia;
  List<dynamic>? jadwalObatRutin; // Perhatikan nama field ini
  List<dynamic>? jadwalKegiatanRutin; // Perhatikan nama field ini
  
  // Add these fields for database compatibility
  String? obatRutinJson;
  String? jadwalKegiatanJson;
  
  Datalansia({
    this.id,
    required this.namaLansia,
    required this.umurLansia,
    this.tempatLahirLansia,
    this.tanggalLahirLansia,
    this.jenisKelaminLansia,
    this.golDarahLansia,
    this.riwayatPenyakitLansia,
    this.alergiLansia,
    this.obatRutinLansia,
    this.catatanKhusus,
    required this.namaAnak,
    required this.alamatLengkap,
    required this.noHpAnak,
    required this.emailAnak,
    this.kontakDaruratNama,
    this.kontakDaruratHp,
    this.kontakDaruratHubungan,
    this.kamarId,
    this.userId,
    this.perawatId,
    this.tanggalMasuk,
    this.tanggalKeluar,
    this.statusLansia,
    this.jadwalObatRutin,
    this.jadwalKegiatanRutin,
    this.obatRutinJson,
    this.jadwalKegiatanJson,
  });

  factory Datalansia.fromJson(Map<String, dynamic> json) {
    // Handle both response formats
    final jadwalObatRutin = json['jadwal_obat_rutin'] ?? 
                           (json['obat_rutin_json'] != null 
                            ? jsonDecode(json['obat_rutin_json']) 
                            : []);
    
    final jadwalKegiatanRutin = json['jadwal_kegiatan_rutin'] ?? 
                               (json['jadwal_kegiatan_json'] != null 
                                ? jsonDecode(json['jadwal_kegiatan_json']) 
                                : []);
    
    return Datalansia(
      id: json['id'],
      namaLansia: json['nama_lansia'],
      umurLansia: json['umur_lansia'],
      tempatLahirLansia: json['tempat_lahir_lansia'],
      tanggalLahirLansia: json['tanggal_lahir_lansia'] != null 
          ? DateTime.parse(json['tanggal_lahir_lansia']) 
          : null,
      jenisKelaminLansia: json['jenis_kelamin_lansia'],
      golDarahLansia: json['gol_darah_lansia'],
      riwayatPenyakitLansia: json['riwayat_penyakit_lansia'],
      alergiLansia: json['alergi_lansia'],
      obatRutinLansia: json['obat_rutin_lansia'],
      catatanKhusus: json['catatan_khusus'],
      namaAnak: json['nama_anak'],
      alamatLengkap: json['alamat_lengkap'],
      noHpAnak: json['no_hp_anak'],
      emailAnak: json['email_anak'],
      kontakDaruratNama: json['kontak_darurat_nama'],
      kontakDaruratHp: json['kontak_darurat_hp'],
      kontakDaruratHubungan: json['kontak_darurat_hubungan'],
      kamarId: json['kamar_id'],
      userId: json['user_id'],
      perawatId: json['perawat_id'],
      tanggalMasuk: json['tanggal_masuk'],
      tanggalKeluar: json['tanggal_keluar'],
      statusLansia: json['status_lansia'],
      jadwalObatRutin: jadwalObatRutin is List ? jadwalObatRutin : [],
      jadwalKegiatanRutin: jadwalKegiatanRutin is List ? jadwalKegiatanRutin : [],
      obatRutinJson: json['obat_rutin_json'],
      jadwalKegiatanJson: json['jadwal_kegiatan_json'],
    );
  }

  Map<String, dynamic> toJson() {
    // Convert untuk request ke Laravel
    final Map<String, dynamic> data = {
      'nama_lansia': namaLansia,
      'umur_lansia': umurLansia,
      'tempat_lahir_lansia': tempatLahirLansia,
      'tanggal_lahir_lansia': tanggalLahirLansia?.toIso8601String(),
      'jenis_kelamin_lansia': jenisKelaminLansia,
      'gol_darah_lansia': golDarahLansia,
      'riwayat_penyakit_lansia': riwayatPenyakitLansia,
      'alergi_lansia': alergiLansia,
      'obat_rutin_lansia': obatRutinLansia,
      'catatan_khusus': catatanKhusus,
      'nama_anak': namaAnak,
      'alamat_lengkap': alamatLengkap,
      'no_hp_anak': noHpAnak,
      'email_anak': emailAnak,
      'kontak_darurat_nama': kontakDaruratNama,
      'kontak_darurat_hp': kontakDaruratHp,
      'kontak_darurat_hubungan': kontakDaruratHubungan,
      'kamar_id': kamarId,
      'user_id': userId,
      'perawat_id': perawatId,
    };
    
    // Handle jadwal JSON untuk request
    if (jadwalObatRutin != null && jadwalObatRutin!.isNotEmpty) {
      data['jadwal_obat_rutin'] = jadwalObatRutin;
    }
    
    if (jadwalKegiatanRutin != null && jadwalKegiatanRutin!.isNotEmpty) {
      data['jadwal_kegiatan_rutin'] = jadwalKegiatanRutin;
    }
    
    return data;
  }
}