import 'package:flutter/material.dart';

class Donasi {
  int? id;
  int? userId;
  int? kampanyeDonasiId;
  int? datalansiaId;
  int jumlah;
  String metodePembayaran;
  String status;
  String? orderId;
  String? transactionId;
  String? paymentType;
  String? bank;
  String? vaNumber;
  String? pdfUrl;
  String? namaDonatur;
  String? emailDonatur;
  String? teleponDonatur;
  String? keterangan;
  bool? anonim;
  String? doaHarapan;
  String? kodeDonasi;
  DateTime createdAt;
  DateTime? updatedAt;
  
  // Fields for WebView
  String? snapToken;
  String? clientKey;
  String? redirectUrl;

  Donasi({
    this.id,
    this.userId,
    this.kampanyeDonasiId,
    this.datalansiaId,
    required this.jumlah,
    required this.metodePembayaran,
    required this.status,
    this.orderId,
    this.transactionId,
    this.paymentType,
    this.bank,
    this.vaNumber,
    this.pdfUrl,
    this.namaDonatur,
    this.emailDonatur,
    this.teleponDonatur,
    this.keterangan,
    this.anonim,
    this.doaHarapan,
    this.kodeDonasi,
    required this.createdAt,
    this.updatedAt,
    this.snapToken,
    this.clientKey,
    this.redirectUrl,
  });

  factory Donasi.fromJson(Map<String, dynamic> json) {
    return Donasi(
      id: json['id'],
      userId: json['user_id'],
      kampanyeDonasiId: json['kampanye_donasi_id'],
      datalansiaId: json['datalansia_id'],
      jumlah: json['jumlah'] is int ? json['jumlah'] : int.tryParse(json['jumlah'].toString()) ?? 0,
      metodePembayaran: json['metode_pembayaran'] ?? 'midtrans',
      status: json['status'] ?? 'pending',
      orderId: json['order_id'] ?? json['kode_donasi'],
      transactionId: json['transaction_id'],
      paymentType: json['payment_type'],
      bank: json['bank'],
      vaNumber: json['va_number'],
      pdfUrl: json['pdf_url'],
      namaDonatur: json['nama_donatur'],
      emailDonatur: json['email_donatur'],
      teleponDonatur: json['telepon_donatur'],
      keterangan: json['keterangan'],
      anonim: json['anonim'],
      doaHarapan: json['doa_harapan'],
      kodeDonasi: json['kode_donasi'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      snapToken: json['snap_token'],
      clientKey: json['client_key'],
      redirectUrl: json['redirect_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (kampanyeDonasiId != null) 'kampanye_donasi_id': kampanyeDonasiId,
      if (datalansiaId != null) 'datalansia_id': datalansiaId,
      'jumlah': jumlah,
      'metode_pembayaran': metodePembayaran,
      'status': status,
      if (orderId != null) 'order_id': orderId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (paymentType != null) 'payment_type': paymentType,
      if (bank != null) 'bank': bank,
      if (vaNumber != null) 'va_number': vaNumber,
      if (pdfUrl != null) 'pdf_url': pdfUrl,
      if (namaDonatur != null) 'nama_donatur': namaDonatur,
      if (emailDonatur != null) 'email_donatur': emailDonatur,
      if (teleponDonatur != null) 'telepon_donatur': teleponDonatur,
      if (keterangan != null) 'keterangan': keterangan,
      if (anonim != null) 'anonim': anonim,
      if (doaHarapan != null) 'doa_harapan': doaHarapan,
      if (kodeDonasi != null) 'kode_donasi': kodeDonasi,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (snapToken != null) 'snap_token': snapToken,
      if (clientKey != null) 'client_key': clientKey,
      if (redirectUrl != null) 'redirect_url': redirectUrl,
    };
  }

  // Helper methods
  String get statusText {
    switch (status.toLowerCase()) {
      case 'settlement':
      case 'success':
      case 'capture':
        return 'Berhasil';
      case 'pending':
        return 'Menunggu';
      case 'deny':
        return 'Ditolak';
      case 'cancel':
        return 'Dibatalkan';
      case 'expire':
        return 'Kadaluarsa';
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      default:
        return 'Menunggu';
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'settlement':
      case 'success':
      case 'capture':
        return Colors.green;
      case 'pending':
      case 'menunggu_verifikasi':
        return Colors.orange;
      case 'deny':
      case 'cancel':
      case 'expire':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get formattedAmount {
    return 'Rp ${jumlah.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  String get donorName {
    if (anonim == true) {
      return 'Anonim';
    }
    return namaDonatur ?? 'Donatur';
  }

  bool get isPaid {
    return status.toLowerCase() == 'settlement' || 
           status.toLowerCase() == 'success' || 
           status.toLowerCase() == 'capture';
  }

  bool get isPending {
    return status.toLowerCase() == 'pending' || 
           status.toLowerCase() == 'menunggu_verifikasi';
  }

  bool get isFailed {
    return status.toLowerCase() == 'deny' || 
           status.toLowerCase() == 'cancel' || 
           status.toLowerCase() == 'expire';
  }
}