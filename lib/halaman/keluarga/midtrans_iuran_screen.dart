import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/iuran_model.dart';
import 'package:sahabatsenja_app/services/api_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransIuranScreen extends StatefulWidget {
  final String snapToken;
  final String? clientKey;
  final String orderId;
  final double amount;
  final IuranBulanan iuran;
  final Function(bool success, Map<String, dynamic>? data) onPaymentComplete;

  const MidtransIuranScreen({
    Key? key,
    required this.snapToken,
    this.clientKey,
    required this.orderId,
    required this.amount,
    required this.iuran,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<MidtransIuranScreen> createState() => _MidtransIuranScreenState();
}

class _MidtransIuranScreenState extends State<MidtransIuranScreen> {
  late final WebViewController controller;
  bool _isLoading = true;
  bool _paymentCompleted = false;
  final ApiService _apiService = ApiService();
  
  // Tambahkan variabel untuk menyimpan URL
  String? _lastPaymentUrl;

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
            print('🔄 Iuran WebView progress: $progress%');
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            print('🌐 Iuran page started: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            print('✅ Iuran page finished: $url');
            _checkPaymentStatus(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            print('❌ Iuran WebView Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🧭 Iuran navigation request: ${request.url}');
            
            // Simpan URL untuk digunakan nanti
            _lastPaymentUrl = request.url;
            
            // Handle payment completion URLs
            if (_isSuccessUrl(request.url)) {
              print('🎉 Iuran payment success detected via navigation');
              // Gunakan URL dari request langsung
              _handlePaymentSuccessFromUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            if (_isFailureUrl(request.url)) {
              print('💥 Iuran payment failed detected via navigation');
              // Gunakan URL dari request langsung
              _handlePaymentFailureFromUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            if (_isPendingUrl(request.url)) {
              print('⏳ Iuran payment pending detected via navigation');
              // Gunakan URL dari request langsung
              _handlePaymentPendingFromUrl(request.url);
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
        <meta charset="UTF-8">
        <style>
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }
          
          html, body {
            height: 100%;
            width: 100%;
            overflow: hidden;
          }
          
          #snap-container {
            width: 100%;
            height: 100vh;
            border: none;
            display: block;
          }
        </style>
      </head>
      <body>
        <div id="snap-container"></div>
        
        <script type="text/javascript"
          src="https://app.sandbox.midtrans.com/snap/snap.js"
          data-client-key="${widget.clientKey ?? 'SB-Mid-client-Your-Client-Key'}">
        </script>
        
        <script type="text/javascript">
          // Initialize Midtrans Snap for Iuran
          function initializePayment() {
            try {
              // Embed Snap payment in full screen
              window.snap.embed('${widget.snapToken}', {
                embedId: 'snap-container',
                onSuccess: function(result) {
                  console.log('Iuran payment success:', result);
                  window.location.href = 'sahabatsenja://iuran/success?iuran_id=${widget.iuran.id}&kode_iuran=${widget.iuran.kodeIuran}&status=success&order_id=' + result.order_id + '&payment_type=' + result.payment_type + '&gross_amount=' + result.gross_amount + '&transaction_time=' + result.transaction_time;
                },
                onPending: function(result) {
                  console.log('Iuran payment pending:', result);
                  window.location.href = 'sahabatsenja://iuran/pending?iuran_id=${widget.iuran.id}&kode_iuran=${widget.iuran.kodeIuran}&status=pending&order_id=' + result.order_id + '&payment_type=' + result.payment_type;
                },
                onError: function(result) {
                  console.log('Iuran payment error:', result);
                  window.location.href = 'sahabatsenja://iuran/error?iuran_id=${widget.iuran.id}&kode_iuran=${widget.iuran.kodeIuran}&status=failed';
                },
                onClose: function() {
                  console.log('Iuran payment closed by user');
                  window.location.href = 'sahabatsenja://iuran/closed?iuran_id=${widget.iuran.id}&kode_iuran=${widget.iuran.kodeIuran}&status=canceled';
                }
              });
              
            } catch (error) {
              console.error('Snap initialization error:', error);
            }
          }
          
          // Wait for Snap to load
          if (window.snap) {
            initializePayment();
          } else {
            document.addEventListener('DOMContentLoaded', initializePayment);
            // Fallback timeout
            setTimeout(initializePayment, 3000);
          }
        </script>
      </body>
      </html>
    ''';
  }

  bool _isSuccessUrl(String url) {
    return url.contains('sahabatsenja://iuran/success');
  }

  bool _isFailureUrl(String url) {
    return url.contains('sahabatsenja://iuran/error') ||
           url.contains('sahabatsenja://iuran/closed');
  }

  bool _isPendingUrl(String url) {
    return url.contains('sahabatsenja://iuran/pending');
  }

  void _checkPaymentStatus(String url) {
    print('🔍 Checking iuran payment status from URL: $url');
    
    if (_isSuccessUrl(url)) {
      _handlePaymentSuccessFromUrl(url);
    } else if (_isFailureUrl(url)) {
      _handlePaymentFailureFromUrl(url);
    } else if (_isPendingUrl(url)) {
      _handlePaymentPendingFromUrl(url);
    }
  }

  Future<void> _updateIuranStatus(Map<String, dynamic> paymentData) async {
    try {
      print('📤 Updating iuran status to backend...');
      print('📦 Data yang dikirim: $paymentData');
      
      final response = await _apiService.post(
        'iuran/${widget.iuran.kodeIuran}/update-status',
        paymentData,
      );
      
      print('📥 Response dari backend: $response');
      
      if (response['status'] == 'success') {
        print('✅ Iuran status updated successfully on backend');
      } else {
        print('⚠️ Failed to update iuran status on backend: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error updating iuran status: $e');
    }
  }

  void _handlePaymentSuccessFromUrl(String url) {
    if (!_paymentCompleted) {
      _paymentCompleted = true;
      
      // Parse data dari URL
      final uri = Uri.parse(url);
      final params = uri.queryParameters;
      
      final result = {
        'status': 'lunas',
        'iuran_id': widget.iuran.id,
        'kode_iuran': widget.iuran.kodeIuran,
        'amount': widget.amount,
        'denda': widget.iuran.denda,
        'total': widget.amount + widget.iuran.denda,
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Pembayaran iuran berhasil',
        'transaction_id': params['order_id'],
        'payment_type': params['payment_type'],
        'gross_amount': params['gross_amount'] != null ? 
            double.tryParse(params['gross_amount']!) : null,
        'transaction_time': params['transaction_time'],
      };
      
      print('🎉 Iuran payment success confirmed: ${widget.iuran.kodeIuran}');
      print('📊 Data parsed from URL:');
      print('  - order_id: ${params['order_id']}');
      print('  - payment_type: ${params['payment_type']}');
      print('  - gross_amount: ${params['gross_amount']}');
      print('  - transaction_time: ${params['transaction_time']}');
      
      // Update status ke backend
      _updateIuranStatus({
        'status': 'lunas',
        'transaction_id': params['order_id'],
        'payment_type': params['payment_type'],
        'gross_amount': params['gross_amount'],
        'transaction_time': params['transaction_time'],
      }).then((_) {
        // Panggil callback
        widget.onPaymentComplete(true, result);
        
        if (mounted) {
          Navigator.pop(context, result);
        }
      });
    }
  }

  void _handlePaymentPendingFromUrl(String url) {
    if (!_paymentCompleted) {
      _paymentCompleted = true;
      
      // Parse data dari URL
      final uri = Uri.parse(url);
      final params = uri.queryParameters;
      
      final result = {
        'status': 'pending',
        'iuran_id': widget.iuran.id,
        'kode_iuran': widget.iuran.kodeIuran,
        'message': 'Pembayaran iuran sedang diproses',
        'transaction_id': params['order_id'],
        'payment_type': params['payment_type'],
      };
      
      print('⏳ Iuran payment pending: ${widget.iuran.kodeIuran}');
      print('📊 Data parsed from URL:');
      print('  - order_id: ${params['order_id']}');
      print('  - payment_type: ${params['payment_type']}');
      
      // Update status ke backend
      _updateIuranStatus({
        'status': 'pending',
        'transaction_id': params['order_id'],
        'payment_type': params['payment_type'],
      }).then((_) {
        // Panggil callback
        widget.onPaymentComplete(false, result);
        
        if (mounted) {
          Navigator.pop(context, result);
        }
      });
    }
  }

  void _handlePaymentFailureFromUrl(String url) {
    if (!_paymentCompleted) {
      _paymentCompleted = true;
      
      final uri = Uri.parse(url);
      final params = uri.queryParameters;
      final status = params['status'] ?? 'failed';
      
      final result = {
        'status': status,
        'iuran_id': widget.iuran.id,
        'kode_iuran': widget.iuran.kodeIuran,
        'message': status == 'canceled' 
            ? 'Pembayaran iuran dibatalkan' 
            : 'Pembayaran iuran gagal',
      };
      
      print('💥 Iuran payment $status: ${widget.iuran.kodeIuran}');
      print('📊 Data parsed from URL:');
      print('  - status: $status');
      
      // Update status ke backend jika gagal (tidak perlu untuk canceled)
      if (status == 'failed') {
        _updateIuranStatus({
          'status': 'failed',
        }).then((_) {
          widget.onPaymentComplete(false, result);
          
          if (mounted) {
            Navigator.pop(context, result);
          }
        });
      } else {
        widget.onPaymentComplete(false, result);
        
        if (mounted) {
          Navigator.pop(context, result);
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Iuran'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showExitConfirmation(),
        ),
      ),
      body: Column(
        children: [
          if (_isLoading)
            Container(
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF9C6223)),
                    const SizedBox(height: 16),
                    const Text('Memuat halaman pembayaran...'),
                    const SizedBox(height: 8),
                    Text(
                      widget.iuran.namaIuran,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!_isLoading)
            Expanded(
              child: WebViewWidget(controller: controller),
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
        content: const Text('Apakah Anda yakin ingin membatalkan pembayaran iuran? '
            'Iuran yang pending akan tetap tercatat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Lanjutkan'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              // Buat URL manual untuk cancelled payment
              final cancelledUrl = 'sahabatsenja://iuran/closed?iuran_id=${widget.iuran.id}&kode_iuran=${widget.iuran.kodeIuran}&status=canceled';
              _handlePaymentFailureFromUrl(cancelledUrl);
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
      // Tidak perlu Navigator.pop lagi karena sudah dipanggil di _handlePaymentFailureFromUrl
    }
  }
}