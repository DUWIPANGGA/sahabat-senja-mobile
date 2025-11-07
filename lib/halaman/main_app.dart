import 'package:flutter/material.dart';
import '../halaman/keluarga/home_screen.dart';
import '../halaman/keluarga/activity_screen.dart';
import '../halaman/keluarga/consultation_screen.dart';
import '../halaman/keluarga/profile_screen.dart';

class MainApp extends StatefulWidget {
  final String namaKeluarga; // Tambahkan parameter

  const MainApp({super.key, required this.namaKeluarga});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  late final List<Widget> _screens; // Gunakan late final

  @override
  void initState() {
    super.initState();
    // Inisialisasi screens di initState agar bisa menggunakan widget.namaKeluarga
    _screens = [
      HomeScreen(namaKeluarga: widget.namaKeluarga), // Berikan parameter
      const ActivityScreen(),
      const ConsultationScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Aktivitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Konsultasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        selectedItemColor: const Color(0xFF9C6223), // Warna coklat app
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}