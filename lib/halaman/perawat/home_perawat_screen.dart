import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'data_lansia_screen.dart';
import 'kondisi_lansia_screen.dart';
import 'jadwal_aktivitas_screen.dart';
import 'jadwal_obat_screen.dart';
import 'tracking_obat_screen.dart';
import 'chat_detail_screen.dart';

class HomePerawatScreen extends StatefulWidget {
  const HomePerawatScreen({super.key});

  @override
  State<HomePerawatScreen> createState() => _HomePerawatScreenState();
}

class _HomePerawatScreenState extends State<HomePerawatScreen> {
  int _selectedIndex = 0;
  bool _isRefreshing = false;

  /// 🔄 Fungsi untuk refresh halaman
  Future<void> _refreshContent() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1)); // simulasi loading data
    setState(() => _isRefreshing = false);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '🚨 Darurat!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah kamu ingin mengirim peringatan ke keluarga lansia?\nGunakan fitur ini hanya jika lansia dalam kondisi gawat.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('🚨 Peringatan darurat telah dikirim ke keluarga!')),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      _buildChatScreen(),
      const ProfileScreen(showAppBar: false),
    ];

    final titles = ['Dashboard Perawat', 'Chat Keluarga', 'Profil Perawat'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C6223),
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  tooltip: 'Darurat',
                  onPressed: () => _showEmergencyDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  tooltip: 'Notifikasi',
                  onPressed: () {},
                ),
              ]
            : [],
      ),
      body: _isRefreshing
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9C6223)))
          : screens[_selectedIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF9C6223).withOpacity(0.15),
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.chat_outlined), label: 'Chat'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  /// 🧩 DASHBOARD
  Widget _buildDashboard() {
  return RefreshIndicator(
    onRefresh: _refreshContent,
    color: const Color(0xFF9C6223),
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9C6223), Color(0xFFD6A15E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang, Perawat 👋',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'Pantau kondisi lansia dengan penuh perhatian dan kasih 💛',
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // 🔸 Menu Items (vertikal)
        _buildMenuItem(Icons.elderly, 'Data Lansia', Colors.teal, const DataLansiaScreen()),
        _buildMenuItem(Icons.favorite, 'Kondisi Lansia', Colors.pink, const KondisiLansiaScreen()),
        _buildMenuItem(Icons.event_note, 'Jadwal Aktivitas', Colors.orange, const JadwalAktivitasScreen()),
        _buildMenuItem(Icons.local_hospital, 'Jadwal Obat', Colors.purple, const JadwalObatScreen()),
        _buildMenuItem(Icons.medication, 'Tracking Obat', Colors.green, const TrackingObatScreen()),
      ],
    ),
  );
}

Widget _buildMenuItem(IconData icon, String title, Color color, Widget page) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildMenuCard(IconData icon, String title, Color color, Widget page) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  /// 💬 CHAT SCREEN
  Widget _buildChatScreen() {
    final keluargaList = [
      {'nama': 'Keluarga Ibu Rusi', 'relation': 'Anak', 'lastMessage': 'Terima kasih infonya bu...', 'time': '10:30'},
      {'nama': 'Keluarga Pak Budi', 'relation': 'Cucu', 'lastMessage': 'Besok saya jenguk...', 'time': '09:15'},
      {'nama': 'Keluarga Ibu Siti', 'relation': 'Menantu', 'lastMessage': 'Obat sudah sampai?', 'time': 'Kemarin'},
    ];

    return RefreshIndicator(
      onRefresh: _refreshContent,
      color: const Color(0xFF9C6223),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari keluarga...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...keluargaList.map((keluarga) => Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF9C6223),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(keluarga['nama']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${keluarga['relation']} • ${keluarga['lastMessage']}',
                  style: const TextStyle(color: Colors.black54),
                ),
                trailing: Text(
                  keluarga['time']!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(namaKeluarga: keluarga['nama']!),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
