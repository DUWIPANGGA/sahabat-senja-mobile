// lib/services/donasi_service_midtrans.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahabatsenja_app/models/donasi_model.dart';
import 'package:sahabatsenja_app/services/midtrans_service.dart';

class DonasiServiceMidtrans {
  final String baseUrl = 'http://192.168.0.100:8000/api';
  final MidtransService _midtransService = MidtransService();
  
  // Initialize service
  Future<void> initialize() async {
    await _midtransService.initializeMidtrans();
  }

  // Create donation with Midtrans
  Future<Map<String, dynamic>> createDonation({
    required int amount,
    required String donorName,
    required String email,
    required String phone,
    String? description,
    int? userId,
    int? datalansiaId,
  }) async {
    try {
      // Step 1: Create transaction
      final transactionResult = await _midtransService.createDonationTransaction(
        amount: amount,
        donorName: donorName,
        email: email,
        phone: phone,
        description: description,
      );

      if (!transactionResult['success']) {
        return transactionResult;
      }

      final snapToken = transactionResult['snap_token'];
      final orderId = transactionResult['order_id'];

      // Step 2: Save to database
      final donasi = Donasi(
        userId: userId ?? 0,
        datalansiaId: datalansiaId ?? 0,
        jumlah: amount,
        metodePembayaran: 'midtrans',
        status: 'pending',
        orderId: orderId,
        namaDonatur: donorName,
        emailDonatur: email,
        teleponDonatur: phone,
        keterangan: description ?? 'Donasi untuk lansia',
        createdAt: DateTime.now(),
      );

      final saveResponse = await http.post(
        Uri.parse('$baseUrl/donasi'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(donasi.toJson()),
      );

      if (saveResponse.statusCode != 201) {
        return {
          'success': false,
          'message': 'Gagal menyimpan data donasi',
        };
      }

      // Step 3: Start payment
      final paymentResult = await _midtransService.startPayment(
        snapToken: snapToken,
        orderId: orderId,
      );

      if (paymentResult['success']) {
        // Update status in database
        await updateDonationStatus(orderId, paymentResult['status']);
      }

      return {
        'success': paymentResult['success'],
        'status': paymentResult['status'],
        'order_id': orderId,
        'message': paymentResult['message'],
        'data': transactionResult['data'],
      };

    } catch (e) {
      print('Error createDonation: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Update donation status
  Future<void> updateDonationStatus(String orderId, String status) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/donasi/$orderId/status'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );
    } catch (e) {
      print('Error updateDonationStatus: $e');
    }
  }

  // Get donation history
  Future<List<Donasi>> getDonationHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donasi/user/$userId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> donasiList = data['data'];
          return donasiList.map((json) => Donasi.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getDonationHistory: $e');
      return [];
    }
  }

  // Get all donations
  Future<List<Donasi>> getAllDonations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donasi'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> donasiList = data['data'];
          return donasiList.map((json) => Donasi.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getAllDonations: $e');
      return [];
    }
  }
}