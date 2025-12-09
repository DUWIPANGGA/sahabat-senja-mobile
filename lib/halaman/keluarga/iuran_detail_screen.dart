import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sahabatsenja_app/models/iuran_model.dart';
import 'package:sahabatsenja_app/services/iuran_service.dart';

class IuranDetailScreen extends StatefulWidget {
  final IuranBulanan iuran;

  const IuranDetailScreen({super.key, required this.iuran});

  @override
  State<IuranDetailScreen> createState() => _IuranDetailScreenState();
}

class _IuranDetailScreenState extends State<IuranDetailScreen> {
  final IuranService _iuranService = IuranService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  bool _isRefreshing = false;
  IuranBulanan? _iuranDetail;
  File? _selectedImage;
  String? _selectedPaymentMethod;
  List<Map<String, dynamic>> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _loadIuranDetail();
    _loadPaymentMethods();
  }

  Future<void> _loadIuranDetail() async {
    setState(() => _isRefreshing = true);
    
    try {
      final detail = await _iuranService.getIuranDetail(widget.iuran.id!);
      setState(() => _iuranDetail = detail);
    } catch (e) {
      print('❌ Error loading iuran detail: $e');
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final methods = await _iuranService.getPaymentMethods();
      setState(() => _paymentMethods = methods);
      if (methods.isNotEmpty) {
        _selectedPaymentMethod = methods.first['code'];
      }
    } catch (e) {
      print('⚠️ Error loading payment methods: $e');
    }
  }

  Future<void> _payWithMidtrans() async {
    if (!_iuranDetail!.isPayable) {
      _showSnackbar('Iuran tidak dapat dibayar');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _iuranService.payIuranMidtrans(
        context: context,
        iuranId: _iuranDetail!.id!,
        paymentMethod: _selectedPaymentMethod,
      );

      if (result['success'] == true) {
        _showSuccessDialog('Pembayaran berhasil diproses');
        _loadIuranDetail();
      } else {
        _showErrorDialog(result['message'] ?? 'Gagal melakukan pembayaran');
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _uploadPaymentProof() async {
    if (_selectedImage == null) {
      _showSnackbar('Pilih bukti pembayaran terlebih dahulu');
      return;
    }

    if (_selectedPaymentMethod == null || _selectedPaymentMethod!.isEmpty) {
      _showSnackbar('Pilih metode pembayaran terlebih dahulu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Convert image to base64
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = _selectedImage!.path.split('.').last;
      final base64String = 'data:image/$mimeType;base64,$base64Image';

      final result = await _iuranService.payIuranManual(
        iuranId: _iuranDetail!.id!,
        metodePembayaran: _selectedPaymentMethod!,
        buktiPembayaran: base64String,
      );

      if (result['success'] == true) {
        _showSuccessDialog('Bukti pembayaran berhasil diupload. Menunggu verifikasi admin.');
        setState(() {
          _selectedImage = null;
        });
        _loadIuranDetail();
      } else {
        _showErrorDialog(result['message'] ?? 'Gagal mengupload bukti pembayaran');
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berhasil'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Iuran'),
        content: const Text('Apakah Anda yakin ingin menghapus iuran ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteIuran();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteIuran() async {
    // TODO: Implement delete iuran API
    _showSnackbar('Fitur hapus iuran sedang dalam pengembangan');
  }

  @override
  Widget build(BuildContext context) {
    final iuran = _iuranDetail ?? widget.iuran;
    final isPayable = iuran.isPayable;
    final isOverdue = iuran.isTerlambat;
    final isVerified = iuran.isVerified;
    final isWaitingVerification = iuran.isWaitingVerification;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadIuranDetail,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              _buildHeader(iuran),
              
              // Fixed App Bar
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 1,
                pinned: true,
                floating: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  iuran.namaIuran,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                centerTitle: true,
                actions: [
                  if (isPayable)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFF333333)),
                      onPressed: _showDeleteConfirmation,
                    ),
                ],
              ),
              
              // Content
              _buildContent(iuran),
              
              // Payment Section (if payable)
              if (isPayable) _buildPaymentSection(iuran),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: 100), // Spacer for bottom button
              ),
            ],
          ),
        ),
      ),
      
      // Fixed Action Button
      bottomNavigationBar: isPayable ? _buildActionButton(iuran) : null,
    );
  }

  SliverAppBar _buildHeader(IuranBulanan iuran) {
    final isOverdue = iuran.isTerlambat;
    
    return SliverAppBar(
      expandedHeight: 160,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isOverdue
                  ? [Colors.red[400]!, Colors.red[600]!]
                  : iuran.statusColor == Colors.green
                    ? [Colors.green[400]!, Colors.green[600]!]
                    : [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/iuran_pattern.png'),
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isOverdue ? Icons.warning : Icons.payment,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              iuran.namaIuran,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              iuran.kodeIuran,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverList _buildContent(IuranBulanan iuran) {
    final isOverdue = iuran.isTerlambat;
    final isPayable = iuran.isPayable;
    final isVerified = iuran.isVerified;
    
    return SliverList(
      delegate: SliverChildListDelegate([
        // Status Card
        _buildStatusCard(iuran),
        
        // Amount Card
        _buildAmountCard(iuran),
        
        // Details Card
        _buildDetailsCard(iuran),
        
        // Payment Info Card (if paid)
        if (iuran.tanggalBayar != null) _buildPaymentInfoCard(iuran),
        
        // Admin Notes (if any)
        if (iuran.catatanAdmin != null && iuran.catatanAdmin!.isNotEmpty)
          _buildAdminNotesCard(iuran),
      ]),
    );
  }

  Widget _buildStatusCard(IuranBulanan iuran) {
    final isOverdue = iuran.isTerlambat;
    final isPayable = iuran.isPayable;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iuran.statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(iuran.status),
                  color: iuran.statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      iuran.statusText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: iuran.statusColor,
                      ),
                    ),
                    Text(
                      iuran.bulanTahun,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[100]!),
                  ),
                  child: Text(
                    '${iuran.hariTersisa.abs()} hari terlambat',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          if (isPayable) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: isOverdue ? 1.0 : 0.5,
              backgroundColor: Colors.grey[200],
              color: isOverdue ? Colors.red : Colors.orange,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOverdue ? 'TERLAMBAT' : 'BELUM DIBAYAR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOverdue ? Colors.red : Colors.orange,
                  ),
                ),
                Text(
                  iuran.denda > 0 ? '+ DENDA ${iuran.formattedDenda}' : '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountCard(IuranBulanan iuran) {
    final isOverdue = iuran.isTerlambat;
    final showTotal = isOverdue || iuran.denda > 0;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.money_outlined, color: Color(0xFF4CAF50), size: 22),
              SizedBox(width: 8),
              Text(
                'Rincian Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Iuran Amount
          _buildAmountRow(
            'Jumlah Iuran',
            iuran.formattedJumlah,
            Colors.grey[700]!,
            false,
          ),
          
          // Due Date
          _buildAmountRow(
            'Jatuh Tempo',
            '${iuran.tanggalJatuhTempo.day}/${iuran.tanggalJatuhTempo.month}/${iuran.tanggalJatuhTempo.year}',
            Colors.grey[700]!,
            false,
          ),
          
          // Late Fee (if any)
          if (iuran.denda > 0) ...[
            const Divider(height: 24),
            _buildAmountRow(
              'Denda Keterlambatan',
              iuran.formattedDenda,
              Colors.red,
              true,
            ),
          ],
          
          // Total (if late fee exists)
          if (showTotal) ...[
            const Divider(height: 24),
            _buildAmountRow(
              'TOTAL YANG HARUS DIBAYAR',
              iuran.formattedTotalBayar,
              const Color(0xFF4CAF50),
              true,
              isBold: true,
            ),
          ],
          
          // Days Left or Overdue
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOverdue ? Colors.red[50] : Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOverdue ? Colors.red[100]! : Colors.blue[100]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isOverdue ? Icons.warning : Icons.access_time,
                  color: isOverdue ? Colors.red : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isOverdue
                        ? 'Iuran terlambat ${iuran.hariTersisa.abs()} hari'
                        : iuran.hariTersisa > 0
                            ? '${iuran.hariTersisa} hari menuju jatuh tempo'
                            : 'Jatuh tempo hari ini',
                    style: TextStyle(
                      fontSize: 14,
                      color: isOverdue ? Colors.red : Colors.blue,
                      fontWeight: FontWeight.w500,
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

  Widget _buildAmountRow(String label, String value, Color color, bool isImportant, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: isImportant ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 16,
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(IuranBulanan iuran) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF4CAF50), size: 22),
              SizedBox(width: 8),
              Text(
                'Detail Iuran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildDetailRow('Kode Iuran', iuran.kodeIuran),
          _buildDetailRow('Periode', iuran.bulanTahun),
          _buildDetailRow('Jenis', iuran.isOtomatis ? 'Berulang Otomatis' : 'Satu Kali'),
          
          if (iuran.isOtomatis) ...[
            if (iuran.intervalBulan != null)
              _buildDetailRow('Interval', 'Setiap ${iuran.intervalBulan} bulan'),
            if (iuran.berlakuDari != null)
              _buildDetailRow('Berlaku Dari', _formatDate(iuran.berlakuDari!)),
            if (iuran.berlakuSampai != null)
              _buildDetailRow('Berlaku Sampai', _formatDate(iuran.berlakuSampai!)),
          ],
          
          if (iuran.deskripsi.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Deskripsi:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              iuran.deskripsi,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(IuranBulanan iuran) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_outlined, color: Colors.green, size: 22),
              SizedBox(width: 8),
              Text(
                'Informasi Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (iuran.tanggalBayar != null)
            _buildDetailRow('Tanggal Bayar', _formatDate(iuran.tanggalBayar!)),
          
          if (iuran.metodePembayaran != null && iuran.metodePembayaran!.isNotEmpty)
            _buildDetailRow('Metode Pembayaran', iuran.metodePembayaran!.toUpperCase()),
          
          if (iuran.buktiPembayaran != null && iuran.buktiPembayaran!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Bukti Pembayaran:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                // TODO: Show image in full screen
                _showImageDialog(iuran.buktiPembayaran!);
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    iuran.buktiPembayaran!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Gambar tidak tersedia'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminNotesCard(IuranBulanan iuran) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.announcement_outlined, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Catatan Admin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            iuran.catatanAdmin!,
            style:  TextStyle(
              fontSize: 14,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildPaymentSection(IuranBulanan iuran) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Row(
              children: [
                Icon(Icons.payment_outlined, color: Color(0xFF4CAF50), size: 22),
                SizedBox(width: 8),
                Text(
                  'Pembayaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Payment Method Selection
            const Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            
            // Payment Methods Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final isSelected = _selectedPaymentMethod == method['code'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedPaymentMethod = method['code']);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getPaymentMethodIcon(method['code']),
                          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          method['name'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Upload Proof Section (for manual payment)
            if (_selectedPaymentMethod != 'midtrans') ...[
              const SizedBox(height: 20),
              const Text(
                'Upload Bukti Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border:  Border.all(
                      color: Colors.grey[300]!,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tap untuk memilih gambar'),
                            SizedBox(height: 4),
                            Text(
                              'Format: JPG, PNG, PDF',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
              
              if (_selectedImage != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedImage!.path.split('/').last,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _selectedImage = null),
                    ),
                  ],
                ),
              ],
            ],
            
            // Instructions
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[100]!),
              ),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Instruksi Pembayaran',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Untuk pembayaran via Midtrans, Anda akan diarahkan ke halaman pembayaran',
                    style: TextStyle(fontSize: 12, color: Colors.amber[800]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Untuk transfer manual, upload bukti transfer setelah pembayaran',
                    style: TextStyle(fontSize: 12, color: Colors.amber[800]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Status akan berubah setelah admin memverifikasi pembayaran',
                    style: TextStyle(fontSize: 12, color: Colors.amber[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IuranBulanan iuran) {
    final isMidtrans = _selectedPaymentMethod == 'midtrans';
    final showUploadButton = _selectedPaymentMethod != 'midtrans' && _selectedImage != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total Amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Bayar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  iuran.formattedTotalBayar,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
          
          // Action Button
          SizedBox(
            width: 150,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () {
                if (isMidtrans) {
                  _payWithMidtrans();
                } else if (showUploadButton) {
                  _uploadPaymentProof();
                } else if (_selectedPaymentMethod != 'midtrans') {
                  _showSnackbar('Upload bukti pembayaran terlebih dahulu');
                }
              },
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(
                      isMidtrans ? Icons.payment : Icons.cloud_upload,
                      size: 18,
                    ),
              label: _isLoading
                  ? const Text('MEMPROSES...')
                  : Text(
                      isMidtrans
                          ? 'BAYAR SEKARANG'
                          : showUploadButton
                              ? 'UPLOAD BUKTI'
                              : 'PILIH METODE',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'menunggu_verifikasi':
        return Icons.access_time;
      case 'ditolak':
        return Icons.cancel;
      case 'terlambat':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getPaymentMethodIcon(String code) {
    switch (code) {
      case 'midtrans':
        return Icons.payment;
      case 'transfer_bank':
        return Icons.account_balance;
      case 'ewallet':
        return Icons.wallet;
      case 'qris':
        return Icons.qr_code;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}