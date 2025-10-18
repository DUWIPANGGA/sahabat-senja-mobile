import 'package:flutter/material.dart';
import 'biodata_screen.dart';
import 'transaction_screen.dart';
import 'health_screen.dart';
import 'donation_screen.dart';
import 'notification_screen.dart'; // Import screen notifikasi

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _notificationCount = 3; // Jumlah notifikasi belum dibaca

  void _navigateToBiodata(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BiodataScreen()),
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
    // Reset count notifikasi ketika dibuka
    setState(() {
      _notificationCount = 0;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );
  }

  void _showNotificationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Badge(
                    label: Text(_notificationCount.toString()),
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToNotifications(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Daftar notifikasi cepat
              _buildQuickNotificationItem(
                'Senam pagi dimulai',
                'Sesi senam pagi untuk lansia sudah dimulai',
                Icons.fitness_center,
                Colors.green,
              ),
              _buildQuickNotificationItem(
                'Donasi diterima',
                'Donasi sebesar Rp 500.000 telah diterima',
                Icons.volunteer_activism,
                Colors.orange,
              ),
              _buildQuickNotificationItem(
                'Pengingat obat',
                'Waktunya minum obat untuk Bu Siti',
                Icons.medical_services,
                Colors.blue,
              ),
              
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToNotifications(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Lihat Semua Notifikasi'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickNotificationItem(String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header pakai foto
            _buildHeader(),

            // Menu akses cepat
            _buildQuickMenu(context),

            // Aktivitas terbaru
            _buildRecentActivities(),

            // Donasi section
            _buildDonationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: DecorationImage(
          image: AssetImage("assets/images/logologin.jpeg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Overlay gelap biar teks keliatan
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris atas dengan notifikasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Beranda Keluarga',
                            style: TextStyle(
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
                      // Icon Notifikasi dengan badge
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none, 
                                color: Color(0xFFFFF9F5), size: 28),
                            onPressed: () => _showNotificationMenu(context),
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Penghuni',
                          '25',
                          Icons.people,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Aktivitas',
                          '12',
                          Icons.event,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Donasi',
                          '8',
                          Icons.volunteer_activism,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F5).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.brown, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
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
              _buildMenuButton('Kesehatan', Icons.medical_services, Colors.green, () {
                _navigateToHealth(context);
              }),
              _buildMenuButton('Biodata Lansia', Icons.assignment_ind, Colors.blue, () {
                _navigateToBiodata(context);
              }),
              _buildMenuButton('Donasi', Icons.volunteer_activism, Colors.orange, () {
                _navigateToDonation(context);
              }),
              _buildMenuButton('Transaksi', Icons.payment, Colors.purple, () {
                _navigateToTransactions(context);
              }),
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
        'title': 'Senam Pagi Lansia',
        'time': 'Hari ini, 07:00',
        'status': 'Selesai',
        'color': Colors.green,
      },
      {
        'title': 'Terapi Musik',
        'time': 'Hari ini, 10:00',
        'status': 'Berlangsung',
        'color': Colors.blue,
      },
      {
        'title': 'Kelas Memasak',
        'time': 'Besok, 14:00',
        'status': 'Akan Datang',
        'color': Colors.orange,
      },
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F5),
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
                  color: Colors.brown,
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
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
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

  Widget _buildDonationSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F5),
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
        children: [
          const Text(
            'Bersama berikan senyuman sederhana',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Dukung kegiatan panti jompo dengan berdonasi. Setiap kontribusi Anda berarti bagi para lansia.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _navigateToDonation(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: const Color(0xFFFFF9F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
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
}