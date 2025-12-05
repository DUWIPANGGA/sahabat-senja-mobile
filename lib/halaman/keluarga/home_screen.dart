import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/keluarga/biodata_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/chat_list_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/jadwal_aktifitas_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/kesehatan_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/transaction_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/donation_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/notification_screen.dart';
import 'package:sahabatsenja_app/models/jadwal_aktivitas_model.dart' show JadwalAktivitas;
import 'package:sahabatsenja_app/services/datalansia_service.dart';
import 'package:sahabatsenja_app/services/jadwal_aktifitas_service.dart';
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
  List<JadwalAktivitas> _jadwalAktivitas = [];

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
        for (var lansia in _lansiaList) {
          final kondisi = await _kondisiService.getTodayData(lansia.namaLansia ?? '');
          if (kondisi != null) {
            _kondisiTerbaru.add(kondisi);
          }
        }
        
        _lansiaStabil = _kondisiTerbaru.where((k) {
          final nadi = int.tryParse(k.nadi ?? '0') ?? 0;
          return nadi >= 60 && nadi <= 100;
        }).length;
      }

      // 3. Load jadwal aktivitas hari ini
      if (_lansiaList.isNotEmpty) {
        try {
          final jadwalService = JadwalAktivitasService();
          _jadwalAktivitas = await jadwalService.getJadwalHariIni();
        } catch (e) {
          print('⚠️ Error loading jadwal: $e');
        }
      }

      // 4. Hitung notifikasi
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

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatListScreen()),
    );
  }

  void _navigateToJadwal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JadwalAktivitasScreen()),
    );
  }

  void _navigateToSettings(BuildContext context) {
    // TODO: Implement settings screen
  }

  void _navigateToHelp(BuildContext context) {
    // TODO: Implement help screen
  }

  Future<void> _refreshJadwal() async {
    try {
      final jadwalService = JadwalAktivitasService();
      final jadwal = await jadwalService.getJadwalHariIni();
      
      setState(() {
        _jadwalAktivitas = jadwal;
      });
    } catch (e) {
      print('⚠️ Error refresh jadwal: $e');
    }
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
                    // Widget aktivitas akan muncul di sini jika ada jadwal
                    if (_lansiaList.isNotEmpty) _buildAktivitasHariIni(),
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
                    'Chat', 
                    Icons.chat_outlined, 
                    const Color(0xFFFF9800), 
                    () => _navigateToChat(context),
                    'Chat dengan perawat',
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
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final buttonSize = constraints.maxWidth / 4 - 16;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMenuButton(
                    'Donasi', 
                    Icons.volunteer_activism_outlined, 
                    const Color(0xFFE91E63), 
                    () => _navigateToDonation(context),
                    'Berikan dukungan',
                    buttonSize,
                  ),
                  _buildMenuButton(
                    'Notifikasi', 
                    Icons.notifications_outlined, 
                    const Color(0xFF9C6223), 
                    () => _navigateToNotifications(context),
                    'Lihat pemberitahuan',
                    buttonSize,
                  ),
                  _buildMenuButton(
                    'Jadwal', 
                    Icons.schedule_outlined, 
                    const Color(0xFF009688), 
                    () => _navigateToJadwal(context),
                    'Kelola jadwal aktivitas',
                    buttonSize,
                  ),
                  _buildMenuButton(
                    'Pengaturan', 
                    Icons.settings_outlined, 
                    const Color(0xFF607D8B), 
                    () => _navigateToSettings(context),
                    'Pengaturan akun',
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

  Widget _buildAktivitasHariIni() {
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C6223).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.today_outlined,
                      color: Color(0xFF9C6223),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Aktivitas Lansia Hari Ini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onSelected: (value) {
                  if (value == 'refresh') {
                    _refreshJadwal();
                  } else if (value == 'lihat_semua') {
                    _navigateToJadwal(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 18),
                        SizedBox(width: 8),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'lihat_semua',
                    child: Row(
                      children: [
                        Icon(Icons.list, size: 18),
                        SizedBox(width: 8),
                        Text('Lihat Semua'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Konten utama
          if (_jadwalAktivitas.isEmpty)
            _buildEmptyAktivitas()
          else
            Column(
              children: [
                // Progress Summary
                _buildProgressSummary(),
                const SizedBox(height: 16),
                // List Aktivitas
                _buildListAktivitas(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    final totalAktivitas = _jadwalAktivitas.length;
    final selesaiAktivitas = _jadwalAktivitas.where((a) => a.completed).length;
    final progress = totalAktivitas > 0 ? selesaiAktivitas / totalAktivitas : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Hari Ini',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${selesaiAktivitas}/$totalAktivitas selesai',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.toDouble(),
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF4CAF50),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'Total',
                totalAktivitas.toString(),
                Icons.list_alt,
                Colors.blue,
              ),
              _buildStatItem(
                'Selesai',
                selesaiAktivitas.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatItem(
                'Belum',
                (totalAktivitas - selesaiAktivitas).toString(),
                Icons.pending,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildListAktivitas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Aktivitas',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        ..._jadwalAktivitas.map((aktivitas) => _buildAktivitasItem(aktivitas)).toList(),
        
        // View all button jika lebih dari 3
        if (_jadwalAktivitas.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => _navigateToJadwal(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat Semua Aktivitas',
                      style: TextStyle(
                        color: const Color(0xFF9C6223),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF9C6223),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAktivitasItem(JadwalAktivitas aktivitas) {
    final isCompleted = aktivitas.completed;
    final time = aktivitas.jam;
    final title = aktivitas.namaAktivitas;
    final keterangan = aktivitas.keterangan;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFE8F5E8) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted 
              ? const Color(0xFF4CAF50).withOpacity(0.2) 
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? const Color(0xFF4CAF50).withOpacity(0.1) 
                  : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isCompleted ? Icons.check : Icons.access_time,
                color: isCompleted ? const Color(0xFF4CAF50) : Colors.orange,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time and Title row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? Colors.grey[600] : const Color(0xFF333333),
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                // Keterangan (jika ada)
                if (keterangan != null && keterangan.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    keterangan,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                // Status and action
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? const Color(0xFF4CAF50).withOpacity(0.1) 
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isCompleted ? 'Selesai' : 'Belum Selesai',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? const Color(0xFF4CAF50) : Colors.orange,
                        ),
                      ),
                    ),
                    
                    // Action buttons
                    Row(
                      children: [
                        if (!isCompleted)
                          GestureDetector(
                            onTap: () {
                              // TODO: Implement mark as completed
                              print('Mark as completed: ${aktivitas.id}');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement view details
                            print('View details: ${aktivitas.id}');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.visibility_outlined,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildEmptyAktivitas() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada aktivitas hari ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan jadwal aktivitas untuk lansia',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
                  // TODO: Navigasi ke screen kondisi lengkap
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