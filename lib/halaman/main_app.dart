import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/keluarga/chat_keluarga_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/home_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/jadwal_keluarga_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/profile_screen.dart';

class MainApp extends StatefulWidget {
  final String namaKeluarga; // diteruskan dari login / shared prefs

  const MainApp({super.key, required this.namaKeluarga});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // NOTE: datalansiaId dan namaPerawat hanya contoh. Ganti dengan data real.
    _screens = [
      HomeScreen(namaKeluarga: widget.namaKeluarga),
      const JadwalKeluargaScreen(),
      // Contoh: datalansiaId = 1, namaPerawat = 'Perawat A' — ganti sesuai data nyata
      ChatKeluargaScreen(
        datalansiaId: 1,
        namaPerawat: 'Perawat A',
        namaKeluarga: widget.namaKeluarga,
      ),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Aktivitas'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Konsultasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        selectedItemColor: const Color(0xFF9C6223),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
