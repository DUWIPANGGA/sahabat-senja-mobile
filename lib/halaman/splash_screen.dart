import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahabatsenja_app/halaman/keluarga/home_screen.dart';
import 'package:sahabatsenja_app/halaman/login_screen.dart';
import 'package:sahabatsenja_app/halaman/perawat/home_perawat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// 🔹 Cek apakah user sudah login di local storage
  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Durasi splash screen

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cek apakah ada token dan user data
      final token = prefs.getString('auth_token');
      final userRole = prefs.getString('user_role');
      final userName = prefs.getString('user_name');
      final userEmail = prefs.getString('user_email');
      
      debugPrint('🔍 Checking login status...');
      debugPrint('📱 Token: ${token != null ? "✅ Ada" : "❌ Tidak ada"}');
      debugPrint('👤 Role: $userRole');
      debugPrint('👤 Name: $userName');
      debugPrint('📧 Email: $userEmail');

      if (token != null && userRole != null && userName != null && userEmail != null) {
        // Token ada, navigasi ke halaman sesuai role
        debugPrint('🚀 User sudah login, mengarahkan ke halaman utama...');
        
        if (mounted) {
          _navigateToHomeScreen(userRole, userName);
        }
      } else {
        // Tidak ada data login, arahkan ke LoginScreen
        debugPrint('🔒 User belum login, mengarahkan ke login...');
        if (mounted) {
          _navigateToLogin();
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      // Jika error, tetap arahkan ke login
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  /// 🔹 Validasi token dengan API (optional)
  Future<bool> _validateToken(String token) async {
    try {
      // TODO: Implement token validation with API
      // Contoh: Kirim request ke endpoint /auth/validate dengan token
      // Jika response 200 OK, return true
      
      // Untuk sekarang, anggap token masih valid jika ada
      return token.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Token validation error: $e');
      return false;
    }
  }

  /// 🔹 Navigasi ke halaman sesuai role
  void _navigateToHomeScreen(String role, String userName) {
    Widget targetScreen;
    
    if (role == 'admin') {
      targetScreen = const HomePerawatScreen();
    } else {
      targetScreen = HomeScreen(namaKeluarga: userName);
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  /// 🔹 Navigasi ke LoginScreen
  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO ASSET
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset(
                    'assets/images/logo_login.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // NAMA APLIKASI
                const Text(
                  'Sahabat Senja',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),

                // TAGLINE
                const Text(
                  'Menjaga kesehatanmu, menjaga aktivitasmu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 60),

                // LOADING INDICATOR
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C6223)),
                ),
                const SizedBox(height: 20),

                // CHECKING LOGIN STATUS TEXT
                FutureBuilder<SharedPreferences>(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return _buildStatusText();
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 40),

                // VERSION
                const Text(
                  'Version 1.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Widget untuk menampilkan status checking login
  Widget _buildStatusText() {
    return StreamBuilder<String>(
      stream: _simulateCheckingProcess(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            snapshot.data!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontFamily: 'Poppins',
            ),
          );
        }
        return const Text(
          'Memulai aplikasi...',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontFamily: 'Poppins',
          ),
        );
      },
    );
  }

  /// 🔹 Stream untuk simulasi proses checking
  Stream<String> _simulateCheckingProcess() async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield 'Memeriksa status login...';
    await Future.delayed(const Duration(milliseconds: 800));
    yield 'Menyiapkan aplikasi...';
    await Future.delayed(const Duration(milliseconds: 700));
    yield 'Hampir selesai...';
  }
}