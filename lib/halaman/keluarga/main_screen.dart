// screens/keluarga/main_screen.dart
import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/keluarga/biodata_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/health_screen.dart';

class KeluargaMainScreen extends StatefulWidget {
  const KeluargaMainScreen({super.key});

  @override
  State<KeluargaMainScreen> createState() => _KeluargaMainScreenState();
}

class _KeluargaMainScreenState extends State<KeluargaMainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman untuk bottom navigation
  final List<Widget> _pages = [
    const HealthScreen(),     // Halaman 0: Monitoring kesehatan
    const BiodataLansiaScreen(), // Halaman 1: Tambah biodata lansia
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Kesehatan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Tambah Lansia',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF9C6223),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}