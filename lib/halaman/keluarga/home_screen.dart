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
      height: 280,
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
                      IconButton(
                        icon: const Icon(Icons.notifications_none,
                            color: Color(0xFFFFF9F5), size: 28),
                        onPressed: () => _navigateToNotifications(context),
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
                              minWidth: 16,
                              minHeight: 16,
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Lansia',
                      '3',
                      Icons.people,
                      const Color(0xFFFFF9F5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Kondisi',
                      'Stabil',
                      Icons.monitor_heart,
                      const Color(0xFFFFF9F5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Update',
                      'Hari Ini',
                      Icons.update,
                      const Color(0xFFFFF9F5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
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
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Keluarga',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMenuButton(
                'Monitoring', 
                Icons.monitor_heart, 
                Colors.red, 
                () => _navigateToHealth(context)
              ),
              _buildMenuButton(
                'Kesehatan', 
                Icons.medical_services, 
                Colors.green, 
                () => _navigateToHealth(context)
              ),
              _buildMenuButton(
                'Biodata Lansia', 
                Icons.assignment_ind, 
                Colors.blue, 
                () => _navigateToBiodataLansia(context)
              ),
              _buildMenuButton(
                'Donasi', 
                Icons.volunteer_activism, 
                Colors.orange, 
                () => _navigateToDonation(context)
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMenuButton(
                'Transaksi', 
                Icons.payment, 
                Colors.purple, 
                () => _navigateToTransactions(context)
              ),
              // Placeholder untuk menyamakan layout
              _buildMenuButton(
                'Riwayat', 
                Icons.history, 
                Colors.teal, 
                () {}
              ),
              _buildMenuButton(
                'Bantuan', 
                Icons.help, 
                Colors.brown, 
                () {}
              ),
              _buildMenuButton(
                'Pengaturan', 
                Icons.settings, 
                Colors.grey, 
                () {}
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
        'icon': Icons.monitor_heart,
      },
      {
        'title': 'Pemeriksaan Rutin',
        'time': 'Hari ini, 08:00',
        'status': 'Selesai',
        'color': Colors.blue,
        'icon': Icons.medical_services,
      },
      {
        'title': 'Aktivitas Senam',
        'time': 'Kemarin, 07:30',
        'status': 'Selesai',
        'color': Colors.orange,
        'icon': Icons.fitness_center,
      },
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Color(0xFF9C6223),
                  fontWeight: FontWeight.w500,
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
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, String status, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}