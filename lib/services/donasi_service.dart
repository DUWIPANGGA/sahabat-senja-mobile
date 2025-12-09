import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/midtrans_payment_screen.dart';
import 'package:sahabatsenja_app/models/kampanye_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/donasi_model.dart';
import '../services/api_service.dart';

class DonasiService {
  final ApiService _apiService = ApiService();
  static const String _baseUrl = ApiService.baseUrl;

  // Get all campaigns
  Future<List<KampanyeDonasi>> getKampanyeDonasi({
    String? status,
    String? kategori,
    bool? isFeatured,
    String? search,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = {
        if (status != null) 'status': status,
        if (kategori != null) 'kategori': kategori,
        if (isFeatured != null) 'is_featured': isFeatured.toString(),
        if (search != null) 'search': search,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final response = await _apiService.get('kampanye', params: queryParams);
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((json) => KampanyeDonasi.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil data kampanye');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get featured campaigns
  Future<List<KampanyeDonasi>> getFeaturedKampanye() async {
    try {
      final response = await _apiService.get('kampanye/featured');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((json) => KampanyeDonasi.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil kampanye featured');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get active campaigns
  Future<List<KampanyeDonasi>> getActiveKampanye({
    String? kategori,
    int perPage = 10,
  }) async {
    try {
      final queryParams = {
        if (kategori != null) 'kategori': kategori,
        'per_page': perPage.toString(),
      };

      final response = await _apiService.get('kampanye/active', params: queryParams);
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((json) => KampanyeDonasi.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil kampanye aktif');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get campaign detail
  Future<KampanyeDonasi> getKampanyeDetail(String slug) async {
    try {
      final response = await _apiService.get('kampanye/$slug');
      
      if (response['status'] == 'success') {
        return KampanyeDonasi.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Kampanye tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create donation
  Future<Map<String, dynamic>> createDonasi({
    required int kampanyeDonasiId,
    required int jumlah,
    required String metodePembayaran,
    required String namaDonatur,
    required String email,
    required String telepon,
    String? keterangan,
    bool anonim = false,
    String? doaHarapan,
  }) async {
    try {
      final data = {
        'kampanye_donasi_id': kampanyeDonasiId,
        'jumlah': jumlah,
        'metode_pembayaran': metodePembayaran,
        'nama_donatur': namaDonatur,
        'email': email,
        'telepon': telepon,
        if (keterangan != null) 'keterangan': keterangan,
        'anonim': anonim,
        if (doaHarapan != null) 'doa_harapan': doaHarapan,
      };

      final response = await _apiService.post('donasi', data);
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'data': response['data'],
          'message': response['message'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal membuat donasi',
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

  // Create donation with Midtrans WebView
  Future<Map<String, dynamic>> createDonasiMidtrans({
    required BuildContext context,
    required int kampanyeDonasiId,
    required int jumlah,
    required String namaDonatur,
    required String email,
    required String telepon,
    String? keterangan,
    bool anonim = false,
    String? doaHarapan,
  }) async {
    try {
      final data = {
        'kampanye_donasi_id': kampanyeDonasiId,
        'jumlah': jumlah,
        'metode_pembayaran': 'midtrans',
        'nama_donatur': namaDonatur,
        'email': email,
        'telepon': telepon,
        if (keterangan != null) 'keterangan': keterangan,
        'anonim': anonim,
        if (doaHarapan != null) 'doa_harapan': doaHarapan,
      };

      final response = await _apiService.post('donasi', data);
      
      if (response['status'] == 'success') {
        final donasiData = response['data'];
        final snapToken = donasiData['payment']['snap_token'];
        final clientKey = donasiData['payment']['client_key'];
        final orderId = donasiData['payment']['order_id'];
        
        // Create Donasi object from response
        final donasi = Donasi(
          id: donasiData['donasi']['id'] ?? 0,
          userId: donasiData['donasi']['user_id'] ?? 0,
          datalansiaId: donasiData['donasi']['datalansia_id'] ?? 0,
          jumlah: jumlah,
          metodePembayaran: 'midtrans',
          status: 'pending',
          orderId: orderId,
          namaDonatur: namaDonatur,
          emailDonatur: email,
kodeDonasi: donasiData['payment']['order_id'],
          teleponDonatur: telepon,
          keterangan: keterangan,
          createdAt: DateTime.now(),
          snapToken: snapToken,
          clientKey: clientKey,
        );

        // Open Midtrans WebView
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MidtransPaymentScreen(
              snapToken: snapToken,
              clientKey: clientKey,
              donasi: donasi,
              onPaymentComplete: (success, resultData) {
                if (success) {
                  print('✅ Payment successful for donation ID: ${donasi.id}');
                  return {
                    'success': true,
                    'message': 'Pembayaran berhasil',
                    'data': resultData,
                  };
                } else {
                  print('❌ Payment failed for donation ID: ${donasi.id}');
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
          'donasi': donasi,
          'payment': {
            'snap_token': snapToken,
            'client_key': clientKey,
            'order_id': orderId,
            'amount': jumlah,
          },
          'webview_result': result ?? {'success': false, 'message': 'WebView closed'},
          'message': response['message'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal membuat donasi',
          'errors': response['errors'] ?? [],
        };
      }
    } catch (e) {
      print('❌ Error in createDonasiMidtrans: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get donation history by user
  Future<List<Donasi>> getDonasiHistory({String? userId}) async {
    try {
      final endpoint = userId != null ? 'donasi/user/$userId' : 'donasi/user';
      final response = await _apiService.get(endpoint);
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((json) => Donasi.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil riwayat donasi');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get donation detail
  Future<Donasi> getDonasiDetail(int id) async {
    try {
      final response = await _apiService.get('donasi/$id');
      
      if (response['status'] == 'success') {
        return Donasi.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Donasi tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(String kodeDonasi) async {
    try {
      final response = await _apiService.get('donasi/check/$kodeDonasi');
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'data': response['data'],
          'message': response['message'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal memeriksa status pembayaran',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get Snap token for existing donation
  Future<Map<String, dynamic>> getSnapToken(int donasiId) async {
    try {
      final response = await _apiService.get('donasi/$donasiId/snap-token');
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'data': response['data'],
          'message': response['message'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal mendapatkan snap token',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Update payment proof (for manual transfer)
  Future<Map<String, dynamic>> updatePaymentProof({
    required int donasiId,
    required String buktiPembayaran, // base64 string
  }) async {
    try {
      final data = {
        'bukti_pembayaran': buktiPembayaran,
      };

      final response = await _apiService.post('donasi/$donasiId/bukti', data);
      
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

  // Get payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final response = await _apiService.get('donasi/payment-methods');
      
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

  // Get campaign statistics
  Future<Map<String, dynamic>> getKampanyeStatistics() async {
    try {
      final response = await _apiService.get('kampanye/statistics');
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'data': response['data'],
          'message': response['message'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal mengambil statistik',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get campaign categories
  Future<List<String>> getKampanyeCategories() async {
    try {
      final response = await _apiService.get('kampanye/categories');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.cast<String>();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil kategori');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get campaign by category
  Future<List<KampanyeDonasi>> getKampanyeByCategory(String category) async {
    try {
      final response = await _apiService.get('kampanye/category/$category');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((json) => KampanyeDonasi.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil kampanye kategori $category');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get trending campaigns
  Future<List<KampanyeDonasi>> getTrendingKampanye() async {
    try {
      final response = await _apiService.get('kampanye/trending');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((json) => KampanyeDonasi.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil kampanye trending');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get campaigns for specific elderly
  Future<List<KampanyeDonasi>> getKampanyeForElderly(int datalansiaId) async {
    try {
      final response = await _apiService.get('kampanye/elderly/$datalansiaId');
      
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        return data.map((json) => KampanyeDonasi.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil kampanye untuk lansia');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update donation status
  Future<Map<String, dynamic>> updateDonasiStatus({
    required int donasiId,
    required String status,
  }) async {
    try {
      final data = {
        'status': status,
      };

      final response = await _apiService.post('donasi/$donasiId/status', data);
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'data': response['data'],
          'message': response['message'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal mengupdate status donasi',
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

  // Get recent donations for a campaign
  Future<List<Map<String, dynamic>>> getRecentDonations(int kampanyeId) async {
    try {
      // This would be from campaign detail endpoint
      final response = await _apiService.get('kampanye/$kampanyeId');
      
      if (response['status'] == 'success') {
        final kampanyeData = response['data'];
        final recentDonations = kampanyeData['recent_donations'] ?? [];
        return List<Map<String, dynamic>>.from(recentDonations);
      } else {
        throw Exception('Gagal mengambil donasi terbaru');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Helper: Format currency
  static String formatCurrency(int amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(1)} Rb';
    } else {
      return 'Rp $amount';
    }
  }

  // Helper: Get user data from shared preferences
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      final phone = prefs.getString('user_phone');

      if (token != null && name != null && email != null) {
        return {
          'token': token,
          'name': name,
          'email': email,
          'phone': phone ?? '',
        };
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}