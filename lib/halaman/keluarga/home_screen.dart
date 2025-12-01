import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/keluarga/biodata_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/kesehatan_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/transaction_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/donation_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/notification_screen.dart';
import 'package:sahabatsenja_app/services/datalansia_service.dart';
import 'package:sahabatsenja_app/services/kondisi_service.dart';
import 'package:sahabatsenja_app/services/keluarga_service.dart' hide DatalansiaService;
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/models/kondisi_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final String namaKeluarga;

  const HomeScreen({super.key, required this.namaKeluarga});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatalansiaService _datalansiaService = DatalansiaService();
  final KondisiService _kondisiService = KondisiService();
  final KeluargaService _keluargaService = KeluargaService();
  
  int _notificationCount = 0;
  List<Datalansia> _lansiaList = [];
  List<KondisiHarian> _kondisiTerbaru = [];
  int _totalLansia = 0;
  int _lansiaStabil = 0;
  bool _isLoading = true;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('user_email');
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Load data lansia terhubung
      if (_userEmail != null) {
        _lansiaList = await _datalansiaService.getDatalansiaByKeluarga(_userEmail!);
      } else {
        _lansiaList = await _keluargaService.getLansiaTerhubung();
      }
      
      _totalLansia = _lansiaList.length;

      // 2. Load kondisi terbaru
      if (_lansiaList.isNotEmpty) {
        // Ambil kondisi untuk semua lansia
        for (var lansia in _lansiaList) {
          final kondisi = await _kondisiService.getTodayData(lansia.namaLansia ?? '');
          if (kondisi != null) {
            _kondisiTerbaru.add(kondisi);
          }
        }
        
        // Hitung lansia stabil
        _lansiaStabil = _kondisiTerbaru.where((k) {
          final nadi = int.tryParse(k.nadi ?? '0') ?? 0;
          return nadi >= 60 && nadi <= 100;
        }).length;
      }

      // 3. Hitung notifikasi (contoh: lansia perlu perhatian)
      _notificationCount = _totalLansia - _lansiaStabil;

    } catch (e) {
      print('❌ Error load home data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _navigateToBiodataLansia(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BiodataLansiaScreen()),
    ).then((_) {
      // Refresh data setelah kembali dari biodata
      _refreshData();
    });
  }

  void _navigateToKesehatan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KesehatanScreen()),
    );
  }

  void _navigateToTransactions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransactionScreen()),
    );
  }

  void _navigateToDonation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DonationScreen()),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    setState(() {
      _notificationCount = 0;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  if (_isLoading) ...[
                    _buildLoadingSection(),
                  ] else ...[
                    _buildStatsSection(),
                    _buildQuickMenu(context),
                    if (_kondisiTerbaru.isNotEmpty) ...[
                      _buildRecentActivities(),
                    ],
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/home_gambar.jpeg'),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Halo,',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sahabat Senja',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.namaKeluarga,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Keluarga Lansia',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_userEmail != null)
                        Text(
                          _userEmail!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none,
                            color: Colors.white, size: 26),
                        onPressed: () => _navigateToNotifications(context),
                      ),
                    ),
                    if (_notificationCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            _notificationCount > 9 ? '9+' : _notificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(40),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF9C6223)),
          SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
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
          const Row(
            children: [
              Icon(Icons.insights_outlined, color: Color(0xFF9C6223), size: 22),
              SizedBox(width: 8),
              Text(
                'Statistik Lansia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Total Lansia',
                _totalLansia.toString(),
                Icons.people_outline,
                Colors.blue,
              ),
              _buildStatCard(
                'Kondisi Stabil',
                _lansiaStabil.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
              _buildStatCard(
                'Perlu Perhatian',
                (_totalLansia - _lansiaStabil).toString(),
                Icons.warning,
                Colors.orange,
              ),
            ],
          ),
          if (_lansiaList.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Belum ada lansia terhubung',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.amber,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email Anda: ${_userEmail ?? "Tidak ada"}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2), width: 2),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu(BuildContext context) {
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
          const Row(
            children: [
              Icon(Icons.dashboard_outlined, color: Color(0xFF9C6223), size: 22),
              SizedBox(width: 8),
              Text(
                'Menu Keluarga',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final buttonSize = constraints.maxWidth / 4 - 16;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMenuButton(
                    'Kesehatan', 
                    Icons.medical_services_outlined, 
                    const Color(0xFF4CAF50), 
                    () => _navigateToKesehatan(context),
                    'Pantau kesehatan lansia',
                    buttonSize,
                  ),
                  _buildMenuButton(
                    'Biodata', 
                    Icons.person_outline, 
                    const Color(0xFF2196F3), 
                    () => _navigateToBiodataLansia(context),
                    'Kelola data pribadi lansia',
                    buttonSize,
                  ),
                  _buildMenuButton(
                    'Donasi', 
                    Icons.volunteer_activism_outlined, 
                    const Color(0xFFFF9800), 
                    () => _navigateToDonation(context),
                    'Berikan dukungan',
                    buttonSize,
                  ),
                  _buildMenuButton(
                    'Transaksi', 
                    Icons.payment_outlined, 
                    const Color(0xFF9C27B0), 
                    () => _navigateToTransactions(context),
                    'Riwayat pembayaran',
                    buttonSize,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, Color color, 
      VoidCallback onTap, String description, double size) {
    return Tooltip(
      message: description,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size,
          child: Column(
            children: [
              Container(
                width: size * 0.7,
                height: size * 0.7,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.2), width: 2),
                ),
                child: Icon(icon, color: color, size: size * 0.35),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
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
              Icon(Icons.history_outlined, color: Color(0xFF9C6223), size: 22),
              SizedBox(width: 8),
              Text(
                'Kondisi Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_kondisiTerbaru.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    'Belum ada data kondisi hari ini',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _kondisiTerbaru.take(3).map((kondisi) {
                final isStabil = (int.tryParse(kondisi.nadi ?? '0') ?? 0) >= 60 && 
                                (int.tryParse(kondisi.nadi ?? '0') ?? 0) <= 100;
                
                return _buildActivityItem(
                  kondisi.namaLansia ?? 'Lansia',
                  '${kondisi.tanggal.day}/${kondisi.tanggal.month}/${kondisi.tanggal.year}',
                  isStabil ? 'Stabil' : 'Perlu Perhatian',
                  isStabil ? Colors.green : Colors.orange,
                  isStabil ? Icons.check_circle_outline : Icons.warning,
                  'Detak: ${kondisi.nadi ?? "-"} bpm • TD: ${kondisi.tekananDarah ?? "-"}',
                );
              }).toList(),
            ),
          if (_kondisiTerbaru.length > 3)
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigasi ke screen kondisi lengkap
                },
                child: const Text(
                  'Lihat Semua Kondisi',
                  style: TextStyle(
                    color: Color(0xFF9C6223),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, String status, 
      Color color, IconData icon, String description) {
    return Tooltip(
      message: description,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Update: $time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}