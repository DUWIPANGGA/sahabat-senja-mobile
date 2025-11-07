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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚨 Darurat!'),
        content: const Text(
          'Apakah kamu ingin mengirim peringatan ke keluarga lansia?\n'
          'Gunakan fitur ini hanya jika lansia dalam kondisi gawat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Peringatan darurat telah dikirim ke keluarga!')),
              );
            },
            child: const Text('Kirim'),
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
      const ProfileScreen(showAppBar: false), // AppBar dihapus di sini
    ];

    final titles = [
      'Dashboard Perawat',
      'Chat Keluarga',
      'Profil Perawat',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C6223),
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
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
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF9C6223),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF9C6223),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, Perawat!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Pantau kondisi lansia dengan penuh perhatian dan kasih 💛',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  icon: Icons.elderly,
                  title: 'Data Lansia',
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DataLansiaScreen()),
                  ),
                ),
                _buildMenuCard(
                  icon: Icons.favorite,
                  title: 'Kondisi Lansia',
                  color: Colors.pink,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const KondisiLansiaScreen()),
                  ),
                ),
                _buildMenuCard(
                  icon: Icons.event_note,
                  title: 'Jadwal Aktivitas',
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JadwalAktivitasScreen()),
                  ),
                ),
                _buildMenuCard(
                  icon: Icons.local_hospital,
                  title: 'Jadwal Obat',
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JadwalObatScreen()),
                  ),
                ),
                _buildMenuCard(
                  icon: Icons.medication,
                  title: 'Tracking Obat',
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrackingObatScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatScreen() {
    final keluargaList = [
      {'nama': 'Keluarga Ibu Rusi', 'relation': 'Anak', 'lastMessage': 'Terima kasih infonya bu...', 'time': '10:30'},
      {'nama': 'Keluarga Pak Budi', 'relation': 'Cucu', 'lastMessage': 'Besok saya jenguk...', 'time': '09:15'},
      {'nama': 'Keluarga Ibu Siti', 'relation': 'Menantu', 'lastMessage': 'Obat sudah sampai?', 'time': 'Kemarin'},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari keluarga...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: keluargaList.length,
            itemBuilder: (context, index) {
              final keluarga = keluargaList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF9C6223),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(keluarga['nama']!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(keluarga['relation']!),
                      Text(keluarga['lastMessage']!, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  trailing: Text(keluarga['time']!, style: const TextStyle(color: Colors.grey)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(namaKeluarga: keluarga['nama']!),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
