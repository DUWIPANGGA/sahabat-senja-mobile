// lib/screens/donasi_midtrans_screen.dart
import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/donasi_model.dart';
import 'package:sahabatsenja_app/services/donasi_service.dart';

class DonasiScreen extends StatefulWidget {
  const DonasiScreen({super.key});

  @override
  State<DonasiScreen> createState() => _DonasiScreenState();
}

class _DonasiScreenState extends State<DonasiScreen> {
  final DonasiServiceMidtrans _donasiService = DonasiServiceMidtrans();
  final List<int> _amountOptions = [50000, 100000, 250000, 500000, 1000000];
  int _selectedAmount = 100000;
  
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _nominalController.text = _selectedAmount.toString();
  }

  Future<void> _initializeServices() async {
    setState(() => _isLoading = true);
    await _donasiService.initialize();
    setState(() => _isLoading = false);
  }

  Future<void> _processDonation() async {
    // Validasi input
    if (_namaController.text.isEmpty) {
      _showError('Harap masukkan nama lengkap');
      return;
    }
    
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError('Harap masukkan email yang valid');
      return;
    }
    
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      _showError('Harap masukkan nomor telepon yang valid');
      return;
    }

    final amount = int.tryParse(_nominalController.text) ?? _selectedAmount;
    if (amount < 10000) {
      _showError('Minimum donasi adalah Rp 10,000');
      return;
    }

    setState(() => _isProcessing = true);
    _errorMessage = null;

    try {
      final result = await _donasiService.createDonation(
        amount: amount,
        donorName: _namaController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        description: _keteranganController.text,
        userId: 1, // Ganti dengan user ID dari auth
        datalansiaId: 0, // Bisa 0 untuk donasi umum
      );

      if (result['success'] == true) {
        _showSuccessDialog(result);
      } else {
        _showError(result['message'] ?? 'Gagal memproses donasi');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Donasi Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${result['order_id']}'),
            const SizedBox(height: 8),
            Text('Status: ${result['status']}'),
            const SizedBox(height: 16),
            const Text(
              'Terima kasih atas donasi Anda! Kami akan mengirimkan notifikasi via email.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset form
              _namaController.clear();
              _emailController.clear();
              _phoneController.clear();
              _keteranganController.clear();
              _nominalController.text = _selectedAmount.toString();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donasi dengan Midtrans'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding:  EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.brown[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.brown[100]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.volunteer_activism, 
                            size: 40, color: Colors.brown),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Donasi Mudah & Aman',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gunakan Midtrans untuk donasi cepat dan terpercaya',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Donasi
                  const Text(
                    'Data Donatur',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama Lengkap
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Telepon
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Nominal Donasi
                  const Text(
                    'Nominal Donasi',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _amountOptions.map((amount) {
                      return ChoiceChip(
                        label: Text('Rp ${_formatCurrency(amount)}'),
                        selected: _selectedAmount == amount,
                        onSelected: (selected) {
                          setState(() {
                            _selectedAmount = amount;
                            _nominalController.text = amount.toString();
                          });
                        },
                        selectedColor: Colors.brown[100],
                        labelStyle: TextStyle(
                          color: _selectedAmount == amount 
                              ? Colors.brown[700] 
                              : Colors.grey[700],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Input Nominal Manual
                  TextFormField(
                    controller: _nominalController,
                    decoration: const InputDecoration(
                      labelText: 'Atau Masukkan Nominal Lain',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _selectedAmount = int.tryParse(value) ?? 0;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Keterangan
                  TextFormField(
                    controller: _keteranganController,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan (Opsional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[100]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (_errorMessage != null) const SizedBox(height: 16),

                  // Tombol Donasi
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processDonation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payment, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'LANJUTKAN PEMBAYARAN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Info Pembayaran
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Info Pembayaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Metode Pembayaran yang Tersedia:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          const Text('• Transfer Bank (BCA, BRI, BNI, Mandiri)'),
                          const Text('• E-Wallet (Gopay, ShopeePay, OVO)'),
                          const Text('• QRIS'),
                          const Text('• Kartu Kredit/Debit'),
                          const SizedBox(height: 12),
                          const Text(
                            'Setelah klik tombol di atas, Anda akan diarahkan ke halaman pembayaran Midtrans.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}