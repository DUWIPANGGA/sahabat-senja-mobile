import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/keluarga/biodata_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/health_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/transaction_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/donation_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  final String namaKeluarga;

  const HomeScreen({super.key, required this.namaKeluarga});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _notificationCount = 2;

  void _navigateToBiodataLansia(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BiodataLansiaScreen()),
    );
  }

  void _navigateToTransactions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransactionScreen()),
    );
  }

  void _navigateToHealth(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HealthScreen()),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildQuickMenu(context),
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 180, // Diperkecil lagi
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9C6223),
            const Color(0xFF9C6223).withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${widget.namaKeluarga}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFFFF9F5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sahabat Senja',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFFFFF9F5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9F5).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none,
                              color: Color(0xFFFFF9F5), size: 24),
                          onPressed: () => _navigateToNotifications(context),
                        ),
                      ),
                      if (_notificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              _notificationCount.toString(),
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
              const SizedBox(height: 20),
              const Text(
                'Pantau kondisi lansia Anda dengan mudah',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFFF9F5),
                ),
              ),
            ],
          ),
        ),
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
              Icon(Icons.dashboard_outlined, color: Color(0xFF9C6223), size: 20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMenuButton(
                'Kesehatan', 
                Icons.medical_services_outlined, 
                const Color(0xFF4CAF50), 
                () => _navigateToHealth(context),
                'Pantau kesehatan lansia'
              ),
              _buildMenuButton(
                'Biodata Lansia', 
                Icons.person_outline, 
                const Color(0xFF2196F3), 
                () => _navigateToBiodataLansia(context),
                'Kelola data pribadi lansia'
              ),
              _buildMenuButton(
                'Donasi', 
                Icons.volunteer_activism_outlined, 
                const Color(0xFFFF9800), 
                () => _navigateToDonation(context),
                'Berikan dukungan'
              ),
              _buildMenuButton(
                'Transaksi', 
                Icons.payment_outlined, 
                const Color(0xFF9C27B0), 
                () => _navigateToTransactions(context),
                'Riwayat pembayaran'
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, Color color, VoidCallback onTap, String description) {
    return Tooltip(
      message: description,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2), width: 2),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    final activities = [
      {
        'title': 'Update Kondisi Lansia',
        'time': 'Hari ini, 10:30',
        'status': 'Stabil',
        'color': Colors.green,
        'icon': Icons.monitor_heart_outlined,
        'description': 'Pemeriksaan kesehatan rutin'
      },
      {
        'title': 'Pemeriksaan Rutin',
        'time': 'Hari ini, 08:00',
        'status': 'Selesai',
        'color': Colors.blue,
        'icon': Icons.medical_services_outlined,
        'description': 'Kontrol dokter mingguan'
      },
      {
        'title': 'Aktivitas Senam',
        'time': 'Kemarin, 07:30',
        'status': 'Selesai',
        'color': Colors.orange,
        'icon': Icons.fitness_center_outlined,
        'description': 'Senam pagi lansia'
      },
    ];

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
              Icon(Icons.history_outlined, color: Color(0xFF9C6223), size: 20),
              SizedBox(width: 8),
              Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: activities.map((activity) {
              return _buildActivityItem(
                activity['title'] as String,
                activity['time'] as String,
                activity['status'] as String,
                activity['color'] as Color,
                activity['icon'] as IconData,
                activity['description'] as String,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                // Aksi untuk lihat semua aktivitas
              },
              child: const Text(
                'Lihat Semua Aktivitas',
                style: TextStyle(
                  color: Color(0xFF9C6223),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, String status, Color color, IconData icon, String description) {
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
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
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