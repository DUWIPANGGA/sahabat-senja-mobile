// lib/models/donasi_model.dart (update)
import 'package:flutter/material.dart';

class Donasi {
  int? id;
  int userId;
  int datalansiaId;
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
  DateTime createdAt;
  DateTime? updatedAt;

  Donasi({
    this.id,
    required this.userId,
    required this.datalansiaId,
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
    required this.createdAt,
    this.updatedAt,
  });

  factory Donasi.fromJson(Map<String, dynamic> json) {
    return Donasi(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      datalansiaId: json['datalansia_id'] ?? 0,
      jumlah: json['jumlah'] is int ? json['jumlah'] : int.tryParse(json['jumlah'].toString()) ?? 0,
      metodePembayaran: json['metode_pembayaran'] ?? 'midtrans',
      status: json['status'] ?? 'pending',
      orderId: json['order_id'],
      transactionId: json['transaction_id'],
      paymentType: json['payment_type'],
      bank: json['bank'],
      vaNumber: json['va_number'],
      pdfUrl: json['pdf_url'],
      namaDonatur: json['nama_donatur'],
      emailDonatur: json['email_donatur'],
      teleponDonatur: json['telepon_donatur'],
      keterangan: json['keterangan'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'datalansia_id': datalansiaId,
      'jumlah': jumlah,
      'metode_pembayaran': metodePembayaran,
      'status': status,
      'order_id': orderId,
      'nama_donatur': namaDonatur,
      'email_donatur': emailDonatur,
      'telepon_donatur': teleponDonatur,
      'keterangan': keterangan,
    };
  }

  // Helper methods
  String get statusText {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'settlement':
        return 'Berhasil';
      case 'capture':
        return 'Terkonfirmasi';
      case 'deny':
        return 'Ditolak';
      case 'cancel':
        return 'Dibatalkan';
      case 'expire':
        return 'Kadaluarsa';
      default:
        return 'Menunggu';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'settlement':
      case 'capture':
        return Colors.green;
      case 'pending':
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
}