// lib/services/midtrans_service.dart
import 'package:flutter/foundation.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MidtransService {
  final String baseUrl = 'http://192.168.0.100:8000/api';
  
  // Initialize Midtrans SDK
  Future<void> initializeMidtrans() async {
    try {
      await MidtransSdk.flutterInit(
        config: MidtransConfig(
          clientKey: 'SB-Mid-client-your-client-key', // Ganti dengan Sandbox key untuk testing
          merchantBaseUrl: 'https://your-merchant-url.com', // URL backend Anda
          colorTheme: ColorTheme(
            colorPrimary: const Color(0xFF8B4513), // Warna brown untuk tema
            colorPrimaryDark: const Color(0xFF5D4037),
            colorSecondary: const Color(0xFFD7CCC8),
          ),
        ),
      );
      
      // Custom settings
      MidtransSdk.setUIKitCustomSetting(
        skipCustomerDetailsPages: true,
        showPaymentStatus: true,
      );
      
      if (kDebugMode) {
        print('✅ Midtrans SDK initialized for Donation');
      }
    } catch (e) {
      if (kDebugMode) {
        print('💥 Midtrans initialization error: $e');
      }
    }
  }

  // Create donation transaction
  Future<Map<String, dynamic>> createDonationTransaction({
    required int amount,
    required String donorName,
    required String email,
    required String phone,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/donasi/create-transaction'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
          'donor_name': donorName,
          'email': email,
          'phone': phone,
          'description': description ?? 'Donasi untuk lansia',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'],
            'snap_token': data['data']['snap_token'],
            'order_id': data['data']['order_id'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Gagal membuat transaksi',
          };
        }
      }
      return {
        'success': false,
        'message': 'Failed to connect to server',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error createDonationTransaction: $e');
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Start payment with Midtrans
  Future<Map<String, dynamic>> startPayment({
    required String snapToken,
    required String orderId,
  }) async {
    try {
      final result = await MidtransSdk.startPaymentUiFlow(
        config: UITransactionConfig(
          snapToken: snapToken,
        ),
      );

      // Handle payment result
      if (result != null) {
        switch (result.status) {
          case MidtransPaymentStatus.success:
            return {
              'success': true,
              'status': 'success',
              'order_id': orderId,
              'message': 'Pembayaran berhasil',
            };
          case MidtransPaymentStatus.pending:
            return {
              'success': true,
              'status': 'pending',
              'order_id': orderId,
              'message': 'Pembayaran menunggu',
            };
          case MidtransPaymentStatus.failed:
            return {
              'success': false,
              'status': 'failed',
              'order_id': orderId,
              'message': 'Pembayaran gagal',
            };
          case MidtransPaymentStatus.cancelled:
            return {
              'success': false,
              'status': 'cancelled',
              'order_id': orderId,
              'message': 'Pembayaran dibatalkan',
            };
          default:
            return {
              'success': false,
              'status': 'unknown',
              'order_id': orderId,
              'message': 'Status tidak diketahui',
            };
        }
      } else {
        return {
          'success': false,
          'message': 'Pembayaran dibatalkan',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error startPayment: $e');
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donasi/status/$orderId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'status': data['status'] ?? 'pending',
          'data': data,
        };
      }
      return {
        'success': false,
        'message': 'Gagal memeriksa status',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}