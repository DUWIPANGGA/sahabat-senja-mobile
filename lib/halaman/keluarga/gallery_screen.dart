import 'package:flutter/material.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final List<Map<String, dynamic>> _donationPrograms = [
    {
      'title': 'Paket Makanan Sehat',
      'description': 'Bantu penuhi kebutuhan nutrisi lansia dengan paket makanan bergizi',
      'target': 5000000,
      'collected': 3250000,
      'donors': 45,
      'image': 'assets/images/food.jpg',
      'color': Colors.orange,
    },
    {
      'title': 'Alat Bantu Jalan',
      'description': 'Sediakan alat bantu jalan untuk lansia yang membutuhkan',
      'target': 3000000,
      'collected': 1800000,
      'donors': 28,
      'image': 'assets/images/walker.jpg',
      'color': Colors.blue,
    },
    {
      'title': 'Obat-obatan Rutin',
      'description': 'Dukung penyediaan obat rutin untuk lansia sakit kronis',
      'target': 7500000,
      'collected': 4200000,
      'donors': 67,
      'image': 'assets/images/medicine.jpg',
      'color': Colors.green,
    },
    {
      'title': 'Kegiatan Rekreasi',
      'description': 'Bantu lansia refreshing dengan kegiatan rekreasi menyenangkan',
      'target': 2500000,
      'collected': 1250000,
      'donors': 32,
      'image': 'assets/images/recreation.jpg',
      'color': Colors.purple,
    },
  ];

  int _selectedAmount = 50000;
  final List<int> _amountOptions = [25000, 50000, 100000, 250000, 500000];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donasi'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Program Donasi
            _buildDonationPrograms(),
            
            // Quick Donation
            _buildQuickDonation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange[700]!, Colors.orange[500]!],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Bersama Berikan Senyuman',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Setiap donasi Anda membantu meningkatkan kualitas hidup para lansia di panti jompo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('500+', 'Donatur'),
              _buildStatItem('Rp 25Jt+', 'Terkumpul'),
              _buildStatItem('150+', 'Lansia Terbantu'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDonationPrograms() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Program Donasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih program yang ingin Anda dukung',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ..._donationPrograms.map((program) => _buildProgramCard(program)),
        ],
      ),
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program) {
    double progress = program['collected'] / program['target'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: program['color'].withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.volunteer_activism,
                color: program['color'],
                size: 50,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  program['description'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Progress Bar
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: program['color'],
                ),
                const SizedBox(height: 8),
                
                // Progress Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${_formatCurrency(program['collected'])}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: program['color'],
                      ),
                    ),
                    Text(
                      'Rp ${_formatCurrency(program['target'])}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Donors Info
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${program['donors']} donatur',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        _showDonationDialog(program);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: program['color'],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Donasi Sekarang'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDonation() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donasi Cepat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih nominal donasi cepat',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          
          // Amount Options
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
                  });
                },
                selectedColor: Colors.orange[100],
                labelStyle: TextStyle(
                  color: _selectedAmount == amount ? Colors.orange[700] : Colors.grey[700],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // Custom Amount
          const TextField(
            decoration: InputDecoration(
              labelText: 'Atau masukkan nominal lain',
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Donate Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _showPaymentDialog(_selectedAmount);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Donasi Sekarang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showDonationDialog(Map<String, dynamic> program) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Donasi untuk ${program['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(program['description']),
            const SizedBox(height: 16),
            const Text('Pilih nominal donasi:'),
            const SizedBox(height: 8),
            ..._amountOptions.map((amount) {
              return ListTile(
                leading: Radio<int>(
                  value: amount,
                  groupValue: _selectedAmount,
                  onChanged: (value) {
                    setState(() {
                      _selectedAmount = value!;
                    });
                    Navigator.pop(context);
                    _showDonationDialog(program);
                  },
                ),
                title: Text('Rp ${_formatCurrency(amount)}'),
                onTap: () {
                  setState(() {
                    _selectedAmount = amount;
                  });
                  Navigator.pop(context);
                  _showPaymentDialog(amount);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPaymentDialog(_selectedAmount);
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(int amount) {
    // Implement payment dialog similar to transaction screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Donasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Anda akan melakukan donasi sebesar:'),
            const SizedBox(height: 8),
            Text(
              'Rp ${_formatCurrency(amount)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Terima kasih atas kebaikan hati Anda!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processDonation(amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
            ),
            child: const Text('Donasi Sekarang'),
          ),
        ],
      ),
    );
  }

  void _processDonation(int amount) {
    // Implement donation processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memproses donasi...'),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      _showSuccessDialog(amount);
    });
  }

  void _showSuccessDialog(int amount) {
    showDialog(
      context: context,
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
          children: [
            Text(
              'Rp ${_formatCurrency(amount)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terima kasih telah berdonasi! Kontribusi Anda sangat berarti bagi para lansia.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    );
  }
}