import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/keluarga/midtrans_iuran_screen.dart';
import 'package:sahabatsenja_app/models/iuran_model.dart';
import 'package:sahabatsenja_app/services/api_service.dart';

class IuranService {
  final ApiService _apiService = ApiService();
  static const String _baseUrl = ApiService.baseUrl;

  // Get all iuran for authenticated user
  Future<List<IuranBulanan>> getIuranList({
    String? status,
    String? periode,
    int? datalansiaId,
    String? search,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = { 
        if (status != null) 'status': status,
        if (periode != null) 'periode': periode,
        if (datalansiaId != null) 'datalansia_id': datalansiaId.toString(),
        if (search != null) 'search': search,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final response = await _apiService.get('iuran', params: queryParams);
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        print(response['message']);
        return data.map((json) => IuranBulanan.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil data iuran');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get iuran statistics
  Future<Map<String, dynamic>> getIuranStatistics() async {
    try {
      final response = await _apiService.get('iuran/statistics');
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'data': response['data'],
          'message': response['message'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal mengambil statistik iuran',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get pending iuran (tagihan)
  Future<List<IuranBulanan>> getPendingIuran({int? datalansiaId}) async {
    try {
      final queryParams = {
        if (datalansiaId != null) 'datalansia_id': datalansiaId.toString(),
      };

      final response = await _apiService.get('iuran/pending', params: queryParams);
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((json) => IuranBulanan.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil tagihan iuran');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get iuran detail
  Future<IuranBulanan> getIuranDetail(int id) async {
    try {
      final response = await _apiService.get('iuran/$id');
      
      if (response['status'] == 'success') {
        return IuranBulanan.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Iuran tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create iuran (admin only)
  Future<Map<String, dynamic>> createIuran({
    required int userId,
    int? datalansiaId,
    required String namaIuran,
    required String deskripsi,
    required double jumlah,
    required String periode,
    required DateTime tanggalJatuhTempo,
    bool isOtomatis = false,
    int? intervalBulan,
    DateTime? berlakuDari,
    DateTime? berlakuSampai,
    String? catatanAdmin,
  }) async {
    try {
      final data = {
        'user_id': userId,
        if (datalansiaId != null) 'datalansia_id': datalansiaId,
        'nama_iuran': namaIuran,
        'deskripsi': deskripsi,
        'jumlah': jumlah,
        'periode': periode,
        'tanggal_jatuh_tempo': tanggalJatuhTempo.toIso8601String().split('T')[0],
        'is_otomatis': isOtomatis,
        if (isOtomatis && intervalBulan != null) 'interval_bulan': intervalBulan,
        if (isOtomatis && berlakuDari != null) 'berlaku_dari': berlakuDari.toIso8601String().split('T')[0],
        if (isOtomatis && berlakuSampai != null) 'berlaku_sampai': berlakuSampai.toIso8601String().split('T')[0],
        if (catatanAdmin != null) 'catatan_admin': catatanAdmin,
      };

      final response = await _apiService.post('iuran', data);
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'data': response['data'],
          'message': response['message'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal membuat iuran',
          'errors': response['errors'] ?? [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Pay iuran with manual upload (transfer)
  Future<Map<String, dynamic>> payIuranManual({
    required int iuranId,
    required String metodePembayaran,
    required String buktiPembayaran, // base64 string
    String? catatan,
  }) async {
    try {
      final data = {
        'metode_pembayaran': metodePembayaran,
        'bukti_pembayaran': buktiPembayaran,
        if (catatan != null) 'catatan': catatan,
      };

      final response = await _apiService.post('iuran/$iuranId/pay', data);
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'data': response['data'],
          'message': response['message'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal mengupload bukti pembayaran',
          'errors': response['errors'] ?? [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Pay iuran with Midtrans WebView
  Future<Map<String, dynamic>> payIuranMidtrans({
    required BuildContext context,
    required int iuranId,
    String? paymentMethod,
  }) async {
    try {
      final queryParams = {
        if (paymentMethod != null) 'payment_method': paymentMethod,
      };

      final response = await _apiService.post(
        'iuran/$iuranId/pay/midtrans',
        queryParams,
      );
      
      if (response['status'] == 'success') {
        final iuranData = response['data']['iuran'];
        final snapToken = response['data']['payment']['snap_token'];
        final clientKey = response['data']['payment']['client_key'];
        final orderId = response['data']['payment']['order_id'];
        final amount = response['data']['payment']['amount'];
        
        // Create Iuran object
        final iuran = IuranBulanan(
          id: iuranData['id'] ?? 0,
          kodeIuran: iuranData['kode_iuran'] ?? '',
          namaIuran: iuranData['nama_iuran'] ?? '',
          deskripsi: iuranData['deskripsi'] ?? '',
          jumlah: iuranData['jumlah'] is num ? iuranData['jumlah'].toDouble() : 0,
          periode: iuranData['periode'] ?? '',
          tanggalJatuhTempo: iuranData['tanggal_jatuh_tempo'] != null 
              ? DateTime.parse(iuranData['tanggal_jatuh_tempo'])
              : DateTime.now(),
          status: iuranData['status'] ?? 'pending',
          metodePembayaran: 'midtrans',
          isOtomatis: iuranData['is_otomatis'] ?? false,
          intervalBulan: iuranData['interval_bulan'],
          berlakuDari: iuranData['berlaku_dari'] != null 
              ? DateTime.parse(iuranData['berlaku_dari'])
              : null,
          berlakuSampai: iuranData['berlaku_sampai'] != null 
              ? DateTime.parse(iuranData['berlaku_sampai'])
              : null,
          catatanAdmin: iuranData['catatan_admin'],
          createdAt: DateTime.now(),
        );

        // Open Midtrans WebView
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MidtransIuranScreen(
              snapToken: snapToken,
              clientKey: clientKey,
              orderId: orderId,
              amount: amount.toDouble(),
              iuran: iuran,
              onPaymentComplete: (success, resultData) {
                if (success) {
                  print('✅ Iuran payment successful for ID: ${iuran.id}');
                  return {
                    'success': true,
                    'message': 'Pembayaran berhasil',
                    'data': resultData,
                  };
                } else {
                  print('❌ Iuran payment failed for ID: ${iuran.id}');
                  return {
                    'success': false,
                    'message': 'Pembayaran gagal',
                    'data': resultData,
                  };
                }
              },
            ),
          ),
        );

        return {
          'success': true,
          'iuran': iuran,
          'payment': {
            'snap_token': snapToken,
            'client_key': clientKey,
            'order_id': orderId,
            'amount': amount,
          },
          'webview_result': result ?? {'success': false, 'message': 'WebView closed'},
          'message': response['message'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal membuat pembayaran',
          'errors': response['errors'] ?? [],
        };
      }
    } catch (e) {
      print('❌ Error in payIuranMidtrans: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get payment history
  Future<List<IuranBulanan>> getPaymentHistory({
    String? periode,
    String? startDate,
    String? endDate,
    int perPage = 10,
  }) async {
    try {
      final queryParams = {
        if (periode != null) 'periode': periode,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        'per_page': perPage.toString(),
      };

      final response = await _apiService.get('iuran/history', params: queryParams);
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((json) => IuranBulanan.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil riwayat pembayaran');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get upcoming iuran
  Future<List<IuranBulanan>> getUpcomingIuran() async {
    try {
      final response = await _apiService.get('iuran/upcoming');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((json) => IuranBulanan.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil iuran mendatang');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final response = await _apiService.get('iuran/payment-methods');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil metode pembayaran');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Verify payment (admin only)
  Future<Map<String, dynamic>> verifyPayment({
    required int iuranId,
    required String status,
    String? catatanAdmin,
  }) async {
    try {
      final data = {
        'status': status,
        if (catatanAdmin != null) 'catatan_admin': catatanAdmin,
      };

      final response = await _apiService.post('iuran/$iuranId/verify', data);
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'data': response['data'],
          'message': response['message'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal memverifikasi pembayaran',
          'errors': response['errors'] ?? [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Helper: Format currency
  static String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(1)} Rb';
    } else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }

  // Helper: Get status color
  static Color getStatusColor(String status) {
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

  // Helper: Get status text
  static String getStatusText(String status) {
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

  // Helper: Calculate days until due date
  static int calculateDaysUntilDue(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    return difference.inDays;
  }

  // Helper: Check if iuran is overdue
  static bool isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  // Helper: Calculate late fee
  static double calculateLateFee(double amount, DateTime dueDate) {
    if (!isOverdue(dueDate)) return 0;
    
    final daysLate = DateTime.now().difference(dueDate).inDays;
    final dailyFee = amount * 0.002; // 0.2% per day
    final totalFee = dailyFee * daysLate;
    final maxFee = amount * 0.1; // Max 10% of amount
    
    return totalFee > maxFee ? maxFee : totalFee;
  }
}