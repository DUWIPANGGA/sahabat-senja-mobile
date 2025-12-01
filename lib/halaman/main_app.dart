import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahabatsenja_app/halaman/keluarga/chat_list_keluarga_screen.dart'; // Screen baru untuk list chat
import 'package:sahabatsenja_app/halaman/keluarga/home_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/jadwal_keluarga_screen.dart';
import 'package:sahabatsenja_app/halaman/keluarga/profile_screen.dart';
import 'package:sahabatsenja_app/providers/chat_provider.dart';
import 'package:sahabatsenja_app/services/auth_service.dart'; // Jika menggunakan auth service

class MainApp extends StatefulWidget {
  final String namaKeluarga;
  final int userId; // Tambahkan userId untuk chat

  const MainApp({
    super.key, 
    required this.namaKeluarga,
    required this.userId, // User ID keluarga
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  Timer? _pollingTimer;
  int _unreadCount = 0;
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize screens
    _screens = [
      HomeScreen(namaKeluarga: widget.namaKeluarga),
      const JadwalKeluargaScreen(),
      ChatListKeluargaScreen(
        userId: widget.userId,
        namaKeluarga: widget.namaKeluarga,
      ), // Screen untuk list chat dengan perawat
      const ProfileScreen(),
    ];
    
    // Start polling untuk unread count
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    try {
      _chatProvider = Provider.of<ChatProvider>(context, listen: false);
      // Load conversations awal
      await _chatProvider.loadConversations();
      // Start polling
      _startPollingUnreadCount();
      
      // Update unread count
      setState(() {
        _unreadCount = _chatProvider.totalUnreadCount;
      });
    } catch (e) {
      print('Error initializing chat: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App kembali aktif, refresh data
      _refreshUnreadCount();
    } else if (state == AppLifecycleState.paused) {
      // App di background, stop polling
      _stopPolling();
    }
  }

  void _startPollingUnreadCount() {
    if (_pollingTimer != null) return;
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      await _refreshUnreadCount();
    });
  }

  Future<void> _refreshUnreadCount() async {
    try {
      await _chatProvider.loadUnreadCounts();
      setState(() {
        _unreadCount = _chatProvider.totalUnreadCount;
      });
    } catch (e) {
      print('Error polling unread count: $e');
    }
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // Ketika masuk ke tab chat, refresh conversations
      _refreshChatData();
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _refreshChatData() async {
    try {
      await _chatProvider.loadConversations();
      // Update unread count
      setState(() {
        _unreadCount = _chatProvider.totalUnreadCount;
      });
    } catch (e) {
      print('Error refreshing chat data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF9C6223),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          items: [
            BottomNavigationBarItem(
              icon: _currentIndex == 0
                  ? const Icon(Icons.home_rounded)
                  : const Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _currentIndex == 1
                  ? const Icon(Icons.calendar_month_rounded)
                  : const Icon(Icons.calendar_month_outlined),
              label: 'Aktivitas',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: _unreadCount > 0
                    ? Text(
                        _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                        style: const TextStyle(fontSize: 10),
                      )
                    : null,
                isLabelVisible: _unreadCount > 0,
                smallSize: 6,
                child: _currentIndex == 2
                    ? const Icon(Icons.chat_rounded)
                    : const Icon(Icons.chat_outlined),
              ),
              label: 'Konsultasi',
            ),
            BottomNavigationBarItem(
              icon: _currentIndex == 3
                  ? const Icon(Icons.person_rounded)
                  : const Icon(Icons.person_outline),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}