import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahabatsenja_app/halaman/perawat/list_chat_perawat_screen.dart';
import 'package:sahabatsenja_app/halaman/perawat/pilih_lansia_jadwal_obat_screen.dart';
import 'package:sahabatsenja_app/providers/chat_provider.dart';
import 'profile_screen.dart';
import 'data_lansia_screen.dart';
import 'kondisi_lansia_screen.dart';
import 'jadwal_perawat_screen.dart';
import 'jadwal_obat_screen.dart';
import 'tracking_obat_screen.dart';
import 'chat_perawat_screen.dart';

class HomePerawatScreen extends StatefulWidget {
  const HomePerawatScreen({super.key});

  @override
  State<HomePerawatScreen> createState() => _HomePerawatScreenState();
}

class _HomePerawatScreenState extends State<HomePerawatScreen> 
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isRefreshing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  // Tambahkan ini untuk polling
  Timer? _appPollingTimer;
  int _unreadCount = 0;

  String _userName = "Bahdanov Semi";
  String _userRole = "Perawat Senior";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
    
    // Start polling untuk unread count
    _startPollingUnreadCount();
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
    if (_appPollingTimer != null) return;
    
    _appPollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      await _refreshUnreadCount();
    });
  }

  Future<void> _refreshUnreadCount() async {
    try {
      final chatProvider = Provider.of<ChatProvider>(
        context,
        listen: false,
      );
      await chatProvider.loadUnreadCounts();
      setState(() {
        _unreadCount = chatProvider.totalUnreadCount;
      });
    } catch (e) {
      print('Error polling unread count: $e');
    }
  }

  void _stopPolling() {
    _appPollingTimer?.cancel();
    _appPollingTimer = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _stopPolling();
    super.dispose();
  }

  Future<void> _refreshContent() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isRefreshing = false);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeOutBack,
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 12),
              Text(
                'Darurat!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: const Text(
            'Apakah kamu ingin mengirim peringatan ke keluarga lansia?\nGunakan fitur ini hanya jika lansia dalam kondisi gawat.',
            style: TextStyle(height: 1.4, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('🚨 Peringatan darurat telah dikirim ke keluarga!'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              icon: const Icon(Icons.send, size: 20),
              label: const Text('Kirim', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      ListChatPerawatScreen(perawatId: 1), // Ganti dengan ID perawat yang sesungguhnya
      const ProfileScreen(showAppBar: false),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isRefreshing
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF9C6223)),
            )
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: screens[_selectedIndex],
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: const Color(0xFF9C6223),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Sahabat Senja',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        // Garis pemisah di bawah AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: Colors.white.withOpacity(0.3), // Garis putih transparan
          ),
        ),
        actions: [
          Tooltip(
            message: 'Darurat',
            child: IconButton(
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              onPressed: () => _showEmergencyDialog(context),
            ),
          ),
          Tooltip(
            message: 'Notifikasi',
            child: IconButton(
              icon: _buildNotificationBadge(),
              onPressed: () {
                // Navigate ke chat screen atau notifikasi screen
                setState(() {
                  _selectedIndex = 1; // Navigate ke chat tab
                });
              },
            ),
          ),
        ],
      );

  Widget _buildNotificationBadge() {
    return Stack(
      children: [
        const Icon(Icons.notifications, color: Colors.white),
        if (_unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
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
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() => BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            // Refresh chat ketika masuk ke tab chat
            _refreshChatData();
          }
          _onItemTapped(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF9C6223),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              smallSize: 8,
              isLabelVisible: _unreadCount > 0,
              child: const Icon(Icons.chat_outlined),
            ),
            activeIcon: Badge(
              smallSize: 8,
              isLabelVisible: _unreadCount > 0,
              child: const Icon(Icons.chat),
            ),
            label: 'Konsultasi',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      );

  Future<void> _refreshChatData() async {
    try {
      final chatProvider = Provider.of<ChatProvider>(
        context,
        listen: false,
      );
      await chatProvider.loadConversations();
      // Update unread count
      setState(() {
        _unreadCount = chatProvider.totalUnreadCount;
      });
    } catch (e) {
      print('Error refreshing chat data: $e');
    }
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _refreshContent,
      color: const Color(0xFF9C6223),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // HEADER DENGAN BACKGROUND GAMBAR
            Container(
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
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Selamat Datang,',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: const Text(
                        'Sahabat Senja 👋',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _userRole,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // KONTEN UTAMA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // JUDUL MENU DENGAN ANIMASI
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Row(
                      children: [
                        Icon(Icons.dashboard, color: Color(0xFF9C6223), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Menu Perawat',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // GRID MENU DENGAN ANIMASI STAGGERED
                  Column(
                    children: [
                      _buildMenuRow(0, [
                        _buildMenuItem(
                          Icons.elderly_outlined,
                          'Data Lansia',
                          const DataLansiaScreen(),
                          0,
                        ),
                        _buildMenuItem(
                          Icons.favorite_outline,
                          'Kondisi Lansia',
                          const KondisiLansiaScreen(),
                          1,
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildMenuRow(1, [
                        _buildMenuItem(
                          Icons.event_note_outlined,
                          'Jadwal Aktivitas',
                          const JadwalPerawatScreen(),
                          2,
                        ),
                        _buildMenuItem(
                          Icons.local_hospital_outlined,
                          'Jadwal Obat',
                          const PilihLansiaJadwalObatScreen(),
                          3,
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildMenuRow(2, [
                        _buildMenuItem(
                          Icons.medication_outlined,
                          'Tracking Obat',
                          const TrackingObatScreen(),
                          4,
                        ),
                        _buildMenuItem(
                          Icons.assignment_outlined,
                          'Laporan',
                          const DataLansiaScreen(),
                          5,
                        ),
                      ]),
                    ],
                  ),

                  const SizedBox(height: 30),
                  
                  // STATISTIK CHAT
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, child) {
                      return _buildChatStatistics(chatProvider);
                    },
                  ),

                  const SizedBox(height: 30),
                  
                  // QUOTE INSPIRASI
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF9C6223).withOpacity(0.1),
                            const Color(0xFF7A4E1C).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF9C6223).withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.health_and_safety,
                            color: Color(0xFF9C6223),
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '"Pelayanan terbaik untuk lansia adalah investasi kemanusiaan yang paling berharga"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '- Sahabat Senja -',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatStatistics(ChatProvider chatProvider) {
    final conversations = chatProvider.conversations;
    final totalConversations = conversations.length;
    final unreadConversations = conversations.where((c) => c.unreadCount > 0).length;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF9C6223).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C6223).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble,
                  color: Color(0xFF9C6223),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Statistik Konsultasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.group,
                'Total Percakapan',
                totalConversations.toString(),
                const Color(0xFF9C6223),
              ),
              _buildStatItem(
                Icons.mark_email_unread,
                'Belum Dibaca',
                unreadConversations.toString(),
                Colors.redAccent,
              ),
              _buildStatItem(
                Icons.timer,
                'Aktif Hari Ini',
                '${conversations.length}',
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (unreadConversations > 0)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 1; // Navigate ke chat tab
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C6223).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF9C6223).withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.message,
                      color: Color(0xFF9C6223),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$unreadConversations pesan belum dibaca',
                      style: const TextStyle(
                        color: Color(0xFF9C6223),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF9C6223),
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMenuRow(int rowIndex, List<Widget> children) {
    return Row(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 0 ? 8 : 0, left: index == 1 ? 8 : 0),
            child: child,
          ),
        );
      }).toList(),
    );
  }

  // WIDGET MENU ITEM DENGAN ANIMASI
  Widget _buildMenuItem(IconData icon, String title, Widget page, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context, 
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              )
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF9C6223).withOpacity(0.15),
                        const Color(0xFF7A4E1C).withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C6223).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF9C6223),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}