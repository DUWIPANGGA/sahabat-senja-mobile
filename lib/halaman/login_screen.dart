import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sahabatsenja_app/halaman/keluarga/home_screen.dart';
import 'package:sahabatsenja_app/halaman/perawat/home_perawat_screen.dart';
import 'package:sahabatsenja_app/services/api_service.dart';
import 'package:sahabatsenja_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Color mainColor = const Color(0xFF9C6223);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ✅ LOGIN DENGAN EMAIL & PASSWORD KE API LARAVEL
  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      print('📡 Mengirim request login ke API...');
      print('📧 Email: ${_emailController.text.trim()}');
      
      final response = await _apiService.post('auth/login', {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });

      print('📥 Response API: $response');
      
      if (response['status'] == 'success') {
        final user = response['data']['user'];
        final token = response['data']['token'];
        
        // Simpan semua data user ke shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', user['role']);
        await prefs.setString('user_name', user['name']);
        await prefs.setString('user_email', user['email']);
        
        // SIMPAN USER ID untuk chat
await prefs.setInt('user_id', int.parse(user['id'].toString()));
        await prefs.setString('user_phone', user['phone'] ?? '');
        await prefs.setString('user_address', user['address'] ?? '');
        await prefs.setString('user_avatar', user['avatar_url'] ?? '');

        print('✅ Login berhasil. Role: ${user['role']}, ID: ${user['id']}');
        print('🔑 Token: ${token.substring(0, 20)}...');
        
        // Navigasi berdasarkan role
        if (mounted) {
          if (user['role'] == 'perawat') {
            print('🚀 Navigasi ke HomePerawatScreen');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePerawatScreen()),
            );
          } else if (user['role'] == 'keluarga') {
            print('🚀 Navigasi ke HomeScreen untuk keluarga');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(
                  namaKeluarga: user['name'] ?? '',
                ),
              ),
            );
          } else {
            // Role lainnya
            print('⚠️ Role tidak dikenal: ${user['role']}');
            _showSnack('Role tidak dikenali. Hubungi administrator.');
          }
        }
      } else {
        print('❌ Login gagal: ${response['message']}');
        _showSnack(response['message'] ?? 'Login gagal');
      }
    } catch (e) {
      print('❌ Login error: $e');
      print('❌ Stack trace: ${e.toString()}');
      _showSnack('Gagal login. Periksa koneksi internet Anda.');
    } finally {
      setState(() => _isLoading = false);
      print('🔄 Loading dihentikan');
    }
  }

  // ✅ LOGIN DENGAN GOOGLE (TETAP PAKAI FIREBASE TAPI SYNC KE LARAVEL)
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      // 1. Login dengan Google via Firebase
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        // 2. Sync dengan Laravel sebagai keluarga
        final authService = AuthService();
        final response = await authService.syncWithLaravel(role: 'keluarga');
        
        if (response != null && response['status'] == 'success') {
          final user = response['data']['user'];
          final token = response['data']['token'];
          
          // Simpan semua data user ke shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('user_role', user['role'] ?? 'keluarga');
          await prefs.setString('user_name', user['name'] ?? firebaseUser.displayName ?? '');
          await prefs.setString('user_email', user['email'] ?? firebaseUser.email ?? '');
          await prefs.setInt('user_id', user['id'] ?? 0);
          await prefs.setString('user_phone', user['phone'] ?? '');
          await prefs.setString('user_address', user['address'] ?? '');
          await prefs.setString('user_avatar', user['avatar_url'] ?? firebaseUser.photoURL ?? '');

          print('✅ Google login berhasil. ID: ${user['id']}');
          
          // Navigasi ke MainApp untuk keluarga
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(
                  namaKeluarga: user['name'] ?? firebaseUser.displayName ?? '',
                ),
              ),
            );
          }
        } else {
          _showSnack('Gagal sinkronisasi dengan server');
        }
      }
    } catch (e) {
      print('❌ Google login error: $e');
      _showSnack('Gagal login dengan Google');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ RESET PASSWORD (VIA API LARAVEL)
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Lupa Kata Sandi?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan email Anda untuk mereset kata sandi:'),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Masukkan Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () => _handleForgotPassword(emailController.text),
            child: const Text('Kirim Link Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleForgotPassword(String email) async {
    if (email.isEmpty) {
      _showSnack('Masukkan email untuk reset kata sandi');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Endpoint forgot-password di Laravel
      final response = await _apiService.post('auth/forgot-password', {
        'email': email.trim(),
      }, includeAuth: false);
      
      if (response['status'] == 'success') {
        _showDialog(
          'Email Reset Terkirim',
          'Kami telah mengirim link reset kata sandi ke $email. Silakan cek email Anda.',
        );
      } else {
        _showSnack(response['message'] ?? 'Gagal mengirim email reset');
      }
    } catch (e) {
      _showSnack('Gagal mengirim email reset: $e');
    } finally {
      Navigator.pop(context); // Tutup dialog forgot password
      setState(() => _isLoading = false);
    }
  }

Future<void> _checkAutoLogin() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');
    final role = prefs.getString('user_role');
    final name = prefs.getString('user_name');
    
    // 🔥 PERBAIKAN USER ID
    dynamic rawUserId = prefs.get('user_id');
    int? userId = (rawUserId is int) ? rawUserId : int.tryParse(rawUserId.toString());

    
  } catch (e) {
    print('❌ Auto-login error: $e');
  }
}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoLogin();
    });
  }

  // ✅ Navigasi ke Register
  void _navigateToRegister() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  // ✅ Utilitas UI
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Email harus diisi';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Kata sandi harus diisi';
    if (value.length < 6) return 'Kata sandi minimal 6 karakter';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Bagian atas dengan gambar dan tombol pendaftaran
              ClipPath(
                clipper: BottomCurveClipper(),
                child: Container(
                  width: double.infinity,
                  height: 260,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/login.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Halo, TEMAN!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Daftarkan diri anda dan mulai gunakan\nlayanan kami segera',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _navigateToRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'PENDAFTARAN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Logo dan form login
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/logo_login.png',
                width: 130,
                height: 130,
              ),
              const SizedBox(height: 12),
              const Text(
                'Sahabat Senja',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 35),
              
              // Form login
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        'Email',
                        _emailController,
                        false,
                        _emailValidator,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Kata Sandi',
                        _passwordController,
                        true,
                        _passwordValidator,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _showForgotPasswordDialog,
                          child: Text(
                            'Lupa Kata Sandi?',
                            style: TextStyle(color: mainColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Tombol Login
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _handleEmailLogin,
                                child: const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                      
                      // Link ke register
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun?',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _navigateToRegister,
                            child: Text(
                              'Daftar di sini',
                              style: TextStyle(
                                color: mainColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Divider "atau"
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('atau'),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      
                      // Tombol Google
                      const SizedBox(height: 24),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _handleGoogleLogin,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text('Masuk dengan Google'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isPassword,
    String? Function(String?)? validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}