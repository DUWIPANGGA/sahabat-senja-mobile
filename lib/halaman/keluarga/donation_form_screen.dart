import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/kampanye_model.dart';
import 'package:sahabatsenja_app/services/donasi_service.dart';

class DonationFormScreen extends StatefulWidget {
  final KampanyeDonasi kampanye;

  const DonationFormScreen({Key? key, required this.kampanye}) : super(key: key);

  @override
  _DonationFormScreenState createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  final DonasiService _donasiService = DonasiService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _doaController = TextEditingController();
  
  bool _anonim = false;
  bool _isLoading = false;
  String _selectedPaymentMethod = 'midtrans';

  @override
  void initState() {
    super.initState();
    _amountController.text = '50000';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _donasiService.getUserData();
    if (userData != null) {
      setState(() {
        _namaController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _teleponController.text = userData['phone'] ?? '';
      });
    }
  }

  Future<void> _submitDonasi() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final amount = int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
      
      if (amount < 10000) {
        _showError('Minimum donasi Rp 10.000');
        setState(() => _isLoading = false);
        return;
      }

      final result = await _donasiService.createDonasiMidtrans(
        context: context,
        kampanyeDonasiId: widget.kampanye.id,
        jumlah: amount,
        namaDonatur: _anonim ? 'Anonim' : _namaController.text,
        email: _emailController.text,
        telepon: _teleponController.text,
        keterangan: widget.kampanye.judul,
        anonim: _anonim,
        doaHarapan: _doaController.text.isEmpty ? null : _doaController.text,
      );

      if (result['success'] == true) {
        // Success handled by WebView
        print('Donasi created successfully');
      } else {
        _showError(result['message'] ?? 'Gagal membuat donasi');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Donasi Berhasil!'),
        content: const Text('Terima kasih atas donasi Anda. '
            'Kontribusi Anda sangat berarti untuk membantu lansia.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to campaign
            },
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
        title: const Text('Donasi Sekarang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.kampanye.judul,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target: ${widget.kampanye.formattedTargetDana}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Donasi (Rp)',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah donasi';
                  }
                  final amount = int.tryParse(value.replaceAll('.', '')) ?? 0;
                  if (amount < 10000) {
                    return 'Minimum donasi Rp 10.000';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Anonim option
              CheckboxListTile(
                title: const Text('Donasi sebagai Anonim'),
                value: _anonim,
                onChanged: (value) {
                  setState(() {
                    _anonim = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              if (!_anonim) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (!_anonim && (value == null || value.isEmpty)) {
                      return 'Masukkan nama lengkap';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan email';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _teleponController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'No. Telepon',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan nomor telepon';
                    }
                    if (value.length < 10) {
                      return 'Nomor telepon minimal 10 digit';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 16),
              TextFormField(
                controller: _doaController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Doa & Harapan (Opsional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitDonasi,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.favorite, size: 20),
                  label: _isLoading
                      ? const Text('MEMPROSES...')
                      : const Text(
                          'DONASI SEKARANG',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}