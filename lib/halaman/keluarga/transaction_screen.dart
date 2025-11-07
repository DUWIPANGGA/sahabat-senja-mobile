import 'package:flutter/material.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TRX001',
      'type': 'Iuran Bulanan',
      'amount': 'Rp 500.000',
      'date': '25 Sep 2024',
      'time': '10:30',
      'status': 'Lunas',
      'color': Colors.green,
      'category': 'iuran',
      'paymentMethod': 'Transfer Bank BRI',
      'accountNumber': '1234-5678-9012-3456',
      'merchantName': 'Panti Jompo Senja Bahagia',
    },
    {
      'id': 'TRX002',
      'type': 'Donasi',
      'amount': 'Rp 200.000',
      'date': '20 Sep 2024', 
      'time': '14:15',
      'status': 'Lunas',
      'color': Colors.green,
      'category': 'donasi',
      'paymentMethod': 'DANA',
      'accountNumber': '0831****0001',
      'merchantName': 'Panti Jompo Senja Bahagia',
    },
    {
      'id': 'TRX003',
      'type': 'Iuran Bulanan',
      'amount': 'Rp 500.000',
      'date': '25 Agu 2024',
      'time': '09:45',
      'status': 'Lunas',
      'color': Colors.green,
      'category': 'iuran',
      'paymentMethod': 'Transfer Bank BCA',
      'accountNumber': '9876-5432-1098-7654',
      'merchantName': 'Panti Jompo Senja Bahagia',
    },
    {
      'id': 'TRX004',
      'type': 'Donasi',
      'amount': 'Rp 100.000',
      'date': '15 Agu 2024',
      'time': '16:20',
      'status': 'Lunas',
      'color': Colors.green,
      'category': 'donasi',
      'paymentMethod': 'Gopay',
      'accountNumber': '0812****3456',
      'merchantName': 'Panti Jompo Senja Bahagia',
    },
    {
      'id': 'TRX005',
      'type': 'Iuran Bulanan',
      'amount': 'Rp 500.000',
      'date': '25 Okt 2024',
      'time': '11:20',
      'status': 'Menunggu',
      'color': Colors.orange,
      'category': 'iuran',
      'paymentMethod': 'Gopay',
      'accountNumber': '0812****3456',
      'merchantName': 'Panti Jompo Senja Bahagia',
    },
    {
      'id': 'TRX006',
      'type': 'Donasi',
      'amount': 'Rp 300.000',
      'date': '10 Okt 2024',
      'time': '13:45',
      'status': 'Lunas',
      'color': Colors.green,
      'category': 'donasi',
      'paymentMethod': 'Transfer Bank BRI',
      'accountNumber': '1234-5678-9012-3456',
      'merchantName': 'Panti Jompo Senja Bahagia',
    },
  ];

  String _selectedFilter = 'Semua'; // 'Semua', 'Iuran', 'Donasi'

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'Semua') {
      return _transactions;
    } else if (_selectedFilter == 'Iuran') {
      return _transactions.where((transaction) => transaction['category'] == 'iuran').toList();
    } else if (_selectedFilter == 'Donasi') {
      return _transactions.where((transaction) => transaction['category'] == 'donasi').toList();
    }
    return _transactions;
  }

  void _showPaymentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const PaymentScreen(),
    );
  }

  Widget _buildFilterButtons() {
    final filters = ['Semua', 'Iuran', 'Donasi'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: Colors.brown[100],
              checkmarkColor: Colors.brown,
              labelStyle: TextStyle(
                color: _selectedFilter == filter ? Colors.brown : Colors.grey[700],
                fontWeight: _selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi & Iuran'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Summary Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Iuran Bulan Ini',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Rp 500.000',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Batas Pembayaran'),
                      Text('30 Sep 2024', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _showPaymentDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Bayar Sekarang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List Transaksi dengan Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Row(
                  children: [
                    Text(
                      'Riwayat Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFilterButtons(),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _filteredTransactions[index];
                return _buildTransactionItem(transaction, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: transaction['category'] == 'donasi' ? Colors.orange[100] : Colors.brown[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction['category'] == 'donasi' ? Icons.volunteer_activism : Icons.receipt,
            color: transaction['category'] == 'donasi' ? Colors.orange[700] : Colors.brown[700],
            size: 20,
          ),
        ),
        title: Text(
          transaction['type']!,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          transaction['date']!,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction['amount']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: transaction['color']!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transaction['status']!,
                style: TextStyle(
                  fontSize: 10,
                  color: transaction['color']!,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailScreen(transaction: transaction),
            ),
          );
        },
      ),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'BCA';
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'BCA',
      'description': 'Bank Central Asia',
      'type': 'bank',
      'icon': Icons.account_balance,
      'color': Colors.blue,
    },
    {
      'name': 'BRI',
      'description': 'Bank Rakyat Indonesia',
      'type': 'bank',
      'icon': Icons.account_balance,
      'color': Colors.orange,
    },
    {
      'name': 'BNI',
      'description': 'Bank Negara Indonesia',
      'type': 'bank',
      'icon': Icons.account_balance,
      'color': Colors.blue[800]!,
    },
    {
      'name': 'Mandiri',
      'description': 'Bank Mandiri',
      'type': 'bank',
      'icon': Icons.account_balance,
      'color': Colors.red,
    },
    {
      'name': 'GoPay',
      'description': 'Tautkan akun GoPay Anda',
      'type': 'ewallet',
      'icon': Icons.phone_android,
      'color': Colors.purple,
    },
    {
      'name': 'DANA',
      'description': '62-******0001 - Tidak Cukup Saldo',
      'type': 'ewallet',
      'icon': Icons.payment,
      'color': Colors.blue,
      'disabled': true,
    },
    {
      'name': 'OVO',
      'description': '****0002 - Tidak Cukup Saldo',
      'type': 'ewallet',
      'icon': Icons.payment,
      'color': Colors.purple[300]!,
      'disabled': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bayar Iuran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info Tagihan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jumlah tagihan',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Rp 0',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Jatuh tempo 2 Okt 2025'),
                    Text(
                      'Rp 500.000',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Keamanan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.blue[700], size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Keamanan dan privasi Anda terjamin',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 12),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Metode Pembayaran
          const Text(
            'Metode pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Rekening Virtual Section
          const Text(
            'Rekening virtual',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          // Daftar Metode Pembayaran
          Expanded(
            child: ListView(
              children: _paymentMethods.map((method) {
                return _buildPaymentMethodItem(method);
              }).toList(),
            ),
          ),

          // Total dan Tombol Bayar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp 500.000',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedMethod.isNotEmpty ? () {
                        _processPayment(_selectedMethod);
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Bayar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(Map<String, dynamic> method) {
    bool isSelected = _selectedMethod == method['name'];
    bool isDisabled = method['disabled'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDisabled ? Colors.grey[100] : null,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: method['color'],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(method['icon'], color: Colors.white, size: 20),
        ),
        title: Text(
          method['name'],
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDisabled ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(
          method['description'],
          style: TextStyle(
            color: isDisabled ? Colors.grey : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Colors.brown[700])
            : null,
        onTap: isDisabled ? null : () {
          setState(() {
            _selectedMethod = method['name'];
          });
        },
      ),
    );
  }

  void _processPayment(String method) {
    Navigator.pop(context); // Tutup bottom sheet
    
    // Tampilkan loading
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
              Text('Memproses pembayaran...'),
            ],
          ),
        ),
      ),
    );

    // Simulasi delay pembayaran
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Tutup loading
      
      // Tampilkan Virtual Account
      _showVirtualAccount(method);
    });
  }

  void _showVirtualAccount(String method) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => VirtualAccountScreen(paymentMethod: method),
    );
  }
}

class VirtualAccountScreen extends StatelessWidget {
  final String paymentMethod;

  const VirtualAccountScreen({super.key, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kode Pembayaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Pembayaran
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  'Menunggu Pembayaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Rp 500.000',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Jatuh tempo pada 20:55, 5 Okt 2025',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Virtual Account Number
          Text(
            paymentMethod,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  '8077 7000 1955 1852 5',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Copy to clipboard
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Salin'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Ambil tangkapan layar halaman ini atau catat kode pembayaran Anda untuk melakukan pembayaran.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Cara Pembayaran
          const Text(
            'Bagaimana cara melakukan pembayaran?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildPaymentStep('Pembayaran via mobile banking', [
            'Masuk ke aplikasi mobile banking $paymentMethod',
            'Pilih menu pembayaran',
            'Pilih menu Virtual Account',
            'Masukkan nomor Virtual Account yang tertera',
            'Masukkan PIN mobile banking',
            'Anda akan mendapatkan notifikasi pembayaran'
          ]),

          const SizedBox(height: 16),

          _buildPaymentStep('Pembayaran via internet banking', [
            'Masuk ke internet banking $paymentMethod',
            'Pilih menu pembayaran',
            'Pilih menu Virtual Account', 
            'Masukkan nomor Virtual Account yang tertera',
            'Konfirmasi pembayaran',
            'Transaksi berhasil'
          ]),

          const Spacer(),

          // Tombol Lihat Pesanan
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Lihat Riwayat Transaksi',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep(String title, List<String> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...steps.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${entry.key + 1}. '),
                Expanded(child: Text(entry.value)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class TransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          transaction['type']!,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info dengan tanggal dan jam
              _buildHeaderInfo(),
              const SizedBox(height: 24),
              
              // Status 
              _buildStatus(),
              const SizedBox(height: 24),
              
              // Detail Pembayaran
              _buildPaymentDetails(),
              const SizedBox(height: 24),
              
              // Info Merchant
              _buildMerchantInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${transaction['date']} · ${transaction['time']}',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getPaymentMethodColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getPaymentMethodIcon(),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['paymentMethod']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  transaction['accountNumber']!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: transaction['status'] == 'Lunas' ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            transaction['status'] == 'Lunas' ? Icons.check_circle : Icons.pending,
            color: transaction['status'] == 'Lunas' ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['status'] == 'Lunas' ? 'Pembayaran Berhasil!' : 'Menunggu Pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction['status'] == 'Lunas' ? Colors.green : Colors.orange,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction['status'] == 'Lunas' 
                    ? 'Pembayaran ${transaction['type']} telah berhasil diproses'
                    : 'Menunggu konfirmasi pembayaran ${transaction['type']}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detail Pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          DetailRow(title: 'Jenis Transaksi', value: transaction['type']!),
          DetailRow(title: 'Jumlah', value: transaction['amount']!),
          DetailRow(title: 'Metode Pembayaran', value: transaction['paymentMethod']!),
          DetailRow(title: 'No. Rekening/Akun', value: transaction['accountNumber']!),
          DetailRow(title: 'Status', value: transaction['status']!),
          DetailRow(title: 'Tanggal', value: transaction['date']!),
          DetailRow(title: 'Waktu', value: transaction['time']!),
          DetailRow(title: 'ID Transaksi', value: transaction['id']!),
        ],
      ),
    );
  }

  Widget _buildMerchantInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Diterima Oleh',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(height: 1),
          SizedBox(height: 12),
          DetailRow(title: 'Nama', value: 'Panti Jompo Senja Bahagia'),
          DetailRow(title: 'Alamat', value: 'Jl. Senja Bahagia No. 123, Jakarta'),
          DetailRow(title: 'Kontak', value: '(021) 1234-5678'),
        ],
      ),
    );
  }

  Color _getPaymentMethodColor() {
    switch (transaction['paymentMethod']) {
      case 'Transfer Bank BRI':
        return Colors.orange;
      case 'Transfer Bank BCA':
        return Colors.blue;
      case 'DANA':
        return Colors.blue;
      case 'Gopay':
        return Colors.purple;
      default:
        return Colors.brown;
    }
  }

  IconData _getPaymentMethodIcon() {
    switch (transaction['paymentMethod']) {
      case 'Transfer Bank BRI':
        return Icons.account_balance;
      case 'Transfer Bank BCA':
        return Icons.account_balance;
      case 'DANA':
        return Icons.payment;
      case 'Gopay':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }
}

class DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const DetailRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}