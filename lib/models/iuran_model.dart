import 'package:flutter/material.dart';

class IuranBulanan {
  int? id;
  int? userId;
  int? datalansiaId;
  String kodeIuran;
  String namaIuran;
  String deskripsi;
  double jumlah;
  String periode;
  DateTime tanggalJatuhTempo;
  DateTime? tanggalBayar;
  String status;
  String? metodePembayaran;
  String? buktiPembayaran;
  String? catatanAdmin;
  bool isOtomatis;
  int? intervalBulan;
  DateTime? berlakuDari;
  DateTime? berlakuSampai;
  Map<String, dynamic>? metadata;
  DateTime createdAt;
  DateTime? updatedAt;

  IuranBulanan({
    this.id,
    this.userId,
    this.datalansiaId,
    required this.kodeIuran,
    required this.namaIuran,
    required this.deskripsi,
    required this.jumlah,
    required this.periode,
    required this.tanggalJatuhTempo,
    this.tanggalBayar,
    required this.status,
    this.metodePembayaran,
    this.buktiPembayaran,
    this.catatanAdmin,
    required this.isOtomatis,
    this.intervalBulan,
    this.berlakuDari,
    this.berlakuSampai,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  factory IuranBulanan.fromJson(Map<String, dynamic> json) {
    return IuranBulanan(
      id: json['id'],
      userId: json['user_id'],
      datalansiaId: json['datalansia_id'],
      kodeIuran: json['kode_iuran'] ?? '',
      namaIuran: json['nama_iuran'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      jumlah: json['jumlah'] is num ? json['jumlah'].toDouble() : 0,
      periode: json['periode'] ?? '',
      tanggalJatuhTempo: json['tanggal_jatuh_tempo'] != null
          ? DateTime.parse(json['tanggal_jatuh_tempo'])
          : DateTime.now(),
      tanggalBayar: json['tanggal_bayar'] != null
          ? DateTime.parse(json['tanggal_bayar'])
          : null,
      status: json['status'] ?? 'pending',
      metodePembayaran: json['metode_pembayaran'],
      buktiPembayaran: json['bukti_pembayaran'],
      catatanAdmin: json['catatan_admin'],
      isOtomatis: json['is_otomatis'] ?? false,
      intervalBulan: json['interval_bulan'],
      berlakuDari: json['berlaku_dari'] != null
          ? DateTime.parse(json['berlaku_dari'])
          : null,
      berlakuSampai: json['berlaku_sampai'] != null
          ? DateTime.parse(json['berlaku_sampai'])
          : null,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (datalansiaId != null) 'datalansia_id': datalansiaId,
      'kode_iuran': kodeIuran,
      'nama_iuran': namaIuran,
      'deskripsi': deskripsi,
      'jumlah': jumlah,
      'periode': periode,
      'tanggal_jatuh_tempo': tanggalJatuhTempo.toIso8601String().split('T')[0],
      if (tanggalBayar != null) 'tanggal_bayar': tanggalBayar!.toIso8601String().split('T')[0],
      'status': status,
      if (metodePembayaran != null) 'metode_pembayaran': metodePembayaran,
      if (buktiPembayaran != null) 'bukti_pembayaran': buktiPembayaran,
      if (catatanAdmin != null) 'catatan_admin': catatanAdmin,
      'is_otomatis': isOtomatis,
      if (intervalBulan != null) 'interval_bulan': intervalBulan,
      if (berlakuDari != null) 'berlaku_dari': berlakuDari!.toIso8601String().split('T')[0],
      if (berlakuSampai != null) 'berlaku_sampai': berlakuSampai!.toIso8601String().split('T')[0],
      if (metadata != null) 'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Helper methods
  String get statusText {
    switch (status.toLowerCase()) {
      case 'lunas':
        return 'Lunas';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      case 'ditolak':
        return 'Ditolak';
      case 'terlambat':
        return 'Terlambat';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'lunas':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'menunggu_verifikasi':
        return Colors.blue;
      case 'ditolak':
        return Colors.red;
      case 'terlambat':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  String get formattedJumlah {
    return _formatCurrency(jumlah);
  }

  String get formattedTotalBayar {
    final total = jumlah + denda;
    return _formatCurrency(total);
  }

  double get denda {
    if (status.toLowerCase() == 'terlambat') {
      final daysLate = DateTime.now().difference(tanggalJatuhTempo).inDays;
      final dailyFee = jumlah * 0.002; // 0.2% per day
      final totalFee = dailyFee * daysLate;
      final maxFee = jumlah * 0.1; // Max 10% of amount
      return totalFee > maxFee ? maxFee : totalFee;
    }
    return 0;
  }

  String get formattedDenda {
    return _formatCurrency(denda);
  }

  int get hariTersisa {
    final now = DateTime.now();
    final difference = tanggalJatuhTempo.difference(now);
    return difference.inDays;
  }

  bool get isTerlambat {
    return hariTersisa < 0 && status.toLowerCase() == 'pending';
  }

  bool get isPayable {
    return status.toLowerCase() == 'pending' || 
           status.toLowerCase() == 'terlambat';
  }

  bool get isVerified {
    return status.toLowerCase() == 'lunas';
  }

  bool get isWaitingVerification {
    return status.toLowerCase() == 'menunggu_verifikasi';
  }

  bool get isRecurring {
    return isOtomatis;
  }

  String get bulanTahun {
    try {
      final parts = periode.split('-');
      if (parts.length == 2) {
        final year = int.tryParse(parts[0]) ?? DateTime.now().year;
        final month = int.tryParse(parts[1]) ?? DateTime.now().month;
        
        final monthNames = [
          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        
        return '${monthNames[month - 1]} $year';
      }
    } catch (e) {
      print('Error parsing periode: $e');
    }
    return periode;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(1)} Rb';
    } else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }
}