import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'models/donasi_model.dart';
import 'services/api_service.dart';

class MidtransPaymentScreen extends StatefulWidget {
  final String snapToken;
  final String? clientKey;
  final Donasi donasi;
  final Function(bool success, Map<String, dynamic>? data) onPaymentComplete;

  const MidtransPaymentScreen({
    Key? key,
    required this.snapToken,
    this.clientKey,
    required this.donasi,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<MidtransPaymentScreen> createState() => _MidtransPaymentScreenState();
}

class _MidtransPaymentScreenState extends State<MidtransPaymentScreen> {
  late final WebViewController controller;
  bool _isLoading = true;
  bool _paymentCompleted = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('🔄 WebView progress: $progress%');
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            print('🌐 Page started: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            print('✅ Page finished: $url');
            _checkPaymentStatus(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            print('❌ WebView Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🧭 Navigation request: ${request.url}');
            
            // Handle payment completion URLs
            if (_isSuccessUrl(request.url)) {
              print('🎉 Payment success detected via navigation');
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            }
            
            if (_isPendingUrl(request.url)) {
              print('⏳ Payment pending detected via navigation');
              _handlePaymentPending();
              return NavigationDecision.prevent;
            }
            
            if (_isFailureUrl(request.url)) {
              print('💥 Payment failed detected via navigation');
              _handlePaymentFailure();
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_generateHtml());
  }

  String _generateHtml() {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          body { 
            margin: 0; 
            padding: 0; 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
          }
          .container {
            width: 100%;
            max-width: 400px;
          }
          .loading {
            text-align: center;
            padding: 20px;
            color: #666;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div id="snap-container"></div>
          <div id="loading" class="loading">Memuat pembayaran donasi...</div>
        </div>
        
        <script type="text/javascript"
          src="https://app.sandbox.midtrans.com/snap/snap.js"
          data-client-key="${widget.clientKey ?? 'SB-Mid-client-xxx'}">
        </script>
        <script type="text/javascript">
          // Init Midtrans Snap
          function initSnap() {
            try {
              window.snap.pay('${widget.snapToken}', {
                onSuccess: function(result) {
                  console.log('Payment success:', result);
                  const transactionId = result.transaction_id || '';
                  window.location.href = 'sahabatsenja://payment/success?donasi_id=${widget.donasi.id}&order_id=${widget.donasi.kodeDonasi}&transaction_id=' + transactionId;
                },
                onPending: function(result) {
                  console.log('Payment pending:', result);
                  const transactionId = result.transaction_id || '';
                  window.location.href = 'sahabatsenja://payment/pending?donasi_id=${widget.donasi.id}&order_id=${widget.donasi.kodeDonasi}&transaction_id=' + transactionId;
                },
                onError: function(result) {
                  console.log('Payment error:', result);
                  window.location.href = 'sahabatsenja://payment/error?donasi_id=${widget.donasi.id}&order_id=${widget.donasi.kodeDonasi}';
                },
                onClose: function() {
                  console.log('Payment closed by user');
                  window.location.href = 'sahabatsenja://payment/closed?donasi_id=${widget.donasi.id}&order_id=${widget.donasi.kodeDonasi}';
                }
              });
              document.getElementById('loading').style.display = 'none';
            } catch (error) {
              console.error('Snap error:', error);
              document.getElementById('loading').innerHTML = 'Error memuat pembayaran: ' + error;
            }
          }

          // Initialize when Snap is loaded
          if (window.snap) {
            initSnap();
          } else {
            document.addEventListener('DOMContentLoaded', initSnap);
          }
        </script>
      </body>
      </html>
    ''';
  }

  bool _isSuccessUrl(String url) {
    return url.contains('sahabatsenja://payment/success') ||
           url.contains('payment/success') ||
           url.contains('status=success');
  }

  bool _isPendingUrl(String url) {
    return url.contains('sahabatsenja://payment/pending') ||
           url.contains('payment/pending') ||
           url.contains('status=pending');
  }

  bool _isFailureUrl(String url) {
    return url.contains('sahabatsenja://payment/error') ||
           url.contains('sahabatsenja://payment/closed') ||
           url.contains('payment/error') ||
           url.contains('payment/failed') ||
           url.contains('status=failed');
  }

  void _checkPaymentStatus(String url) {
    print('🔍 Checking payment status from URL: $url');
    
    if (_isSuccessUrl(url)) {
      _handlePaymentSuccess();
    } else if (_isPendingUrl(url)) {
      _handlePaymentPending();
    } else if (_isFailureUrl(url)) {
      _handlePaymentFailure();
    }
  }

  // 🔹 Helper untuk ekstrak parameter dari URL
  Map<String, String> _extractParamsFromUrl(String url) {
    final params = <String, String>{};
    final uri = Uri.parse(url);
    
    uri.queryParameters.forEach((key, value) {
      params[key] = value;
    });
    
    return params;
  }

  // 🔹 Kirim request update status ke backend menggunakan ApiService
  Future<void> _updateDonasiStatus({
    required String status,
    String? transactionId,
    String? paymentType = 'midtrans',
  }) async {
    try {
      print('🌐 Updating donation status to: $status');
      print('📦 Donation ID: ${widget.donasi.kodeDonasi}');
      if (transactionId != null) {
        print('📦 Transaction ID: $transactionId');
      }

      final data = {
        'status': status,
        if (transactionId != null && transactionId.isNotEmpty) 
          'transaction_id': transactionId,
        'payment_type': paymentType,
      };

      // Gunakan ApiService untuk POST request
      final response = await _apiService.post(
        'donasi/${widget.donasi.kodeDonasi}/update-status',
        data,
        includeAuth: true,
      );

      if (response['status'] == 'success') {
        print('✅ Status updated successfully: ${response['message']}');
        print('✅ Updated data: ${response['data']}');
      } else {
        print('❌ Failed to update status: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error updating status: $e');
      // Tetap lanjutkan walaupun update gagal
    }
  }

  // 🔹 Tangani pembayaran sukses
  Future<void> _handlePaymentSuccess() async {
    if (!_paymentCompleted) {
      _paymentCompleted = true;
      print('🎉 Payment success confirmed for donation: ${widget.donasi.id}');
      
      // Ekstrak transaction_id dari URL jika ada
      final params = _extractParamsFromUrl('sahabatsenja://payment/success');
      final transactionId = params['transaction_id'];
      
      // Kirim update ke backend
      await _updateDonasiStatus(
        status: 'sukses',
        transactionId: transactionId,
      );
      
      final result = {
        'status': 'success',
        'donasi_id': widget.donasi.id,
        'kode_donasi': widget.donasi.kodeDonasi,
        'transaction_id': transactionId,
        'amount': widget.donasi.jumlah,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      widget.onPaymentComplete(true, result);
      
      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog();
      }
    }
  }

  // 🔹 Tangani pembayaran pending
  Future<void> _handlePaymentPending() async {
    if (!_paymentCompleted) {
      print('⏳ Payment pending for donation: ${widget.donasi.id}');
      
      final params = _extractParamsFromUrl('sahabatsenja://payment/pending');
      final transactionId = params['transaction_id'];
      
      // Kirim update ke backend
      await _updateDonasiStatus(
        status: 'pending',
        transactionId: transactionId,
      );
      
      final result = {
        'status': 'pending',
        'donasi_id': widget.donasi.id,
        'kode_donasi': widget.donasi.kodeDonasi,
        'transaction_id': transactionId,
        'message': 'Pembayaran sedang diproses',
      };
      
      widget.onPaymentComplete(false, result);
      
      if (mounted) {
        Navigator.pop(context);
        _showPendingDialog();
      }
    }
  }

  // 🔹 Tangani pembayaran gagal
  void _handlePaymentFailure() {
    if (!_paymentCompleted) {
      _paymentCompleted = true;
      print('💥 Payment failed for donation: ${widget.donasi.id}');
      
      // Untuk error/closed, tidak perlu kirim ke backend karena biasanya backend sudah tahu
      // Tapi kalau mau tetap update, bisa uncomment kode di bawah
      // await _updateDonasiStatus(
      //   status: 'failed',
      // );
      
      final result = {
        'status': 'failed',
        'donasi_id': widget.donasi.id,
        'kode_donasi': widget.donasi.kodeDonasi,
        'message': 'Pembayaran gagal atau dibatalkan',
      };
      
      widget.onPaymentComplete(false, result);
      
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('Donasi Berhasil!'),
          ],
        ),
        content: const Text('Terima kasih atas donasi Anda. '
            'Kontribusi Anda sangat berarti untuk membantu lansia.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.schedule, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Text('Pembayaran Pending'),
          ],
        ),
        content: const Text('Pembayaran Anda sedang diproses. '
            'Silakan cek status pembayaran di menu Riwayat Donasi.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Pembayaran Gagal'),
          ],
        ),
        content: const Text('Pembayaran donasi gagal atau dibatalkan. '
            'Silakan coba lagi atau gunakan metode pembayaran lain.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Donasi'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showExitConfirmation(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat halaman pembayaran...'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showExitConfirmation() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text('Apakah Anda yakin ingin membatalkan pembayaran? '
            'Donasi yang pending akan kadaluarsa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Lanjutkan'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              _handlePaymentFailure();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
  }
}