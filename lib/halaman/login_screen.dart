import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahabatsenja_app/halaman/perawat/home_perawat_screen.dart';
import 'main_app.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Color mainColor = const Color(0xFF9C6223);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ✅ LOGIN DENGAN EMAIL & PASSWORD
  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = userCredential.user;
      if (user == null) {
        _showSnack('Gagal login, user tidak ditemukan.');
        return;
      }

      print('🔍 Cek Firestore apakah user perawat...');
      final query = await _firestore
          .collection('users')
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final role = (data['role'] ?? '').toString().toLowerCase();

        print('🧾 Ditemukan user di Firestore: $data');
        if (role == 'perawat') {
          print('✅ Role PERAWAT ditemukan → ke HomePerawatScreen');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePerawatScreen()),
            );
            return;
          }
        }
      }

      // Default ke keluarga kalau tidak ditemukan di Firestore
      print('⚠️ Tidak ada data di Firestore → ke MainApp (keluarga)');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const MainApp(
                    namaKeluarga: '',
                  )),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Terjadi kesalahan saat login';
      if (e.code == 'user-not-found') msg = 'Email tidak ditemukan';
      if (e.code == 'wrong-password') msg = 'Kata sandi salah';
      if (e.code == 'invalid-email') msg = 'Format email tidak valid';
      if (e.code == 'user-disabled') msg = 'Akun ini dinonaktifkan';
      _showSnack(msg);
    } catch (e) {
      _showSnack('Gagal login: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ LOGIN DENGAN GOOGLE
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const MainApp(
                    namaKeluarga: '',
                  )),
        );
      }
    } catch (e) {
      _showSnack('Gagal login dengan Google: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ RESET PASSWORD
  void _showForgotPasswordDialog() {
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
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Masukkan Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: _handleForgotPassword,
            child: const Text('Kirim Link Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      _showSnack('Masukkan email untuk reset kata sandi');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      _showDialog(
        'Email Reset Terkirim',
        'Kami telah mengirim link reset kata sandi ke ${_emailController.text.trim()}. Silakan cek email Anda.',
      );
    } catch (e) {
      _showSnack('Gagal mengirim email reset: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Navigasi ke Register
  void _navigateToRegister() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  // ✅ Utilitas UI
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Email harus diisi';
    if (!value.contains('@') || !value.contains('.'))
      return 'Format email tidak valid';
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
                                horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'PENDAFTARAN',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Image.asset('assets/images/logo_login.png',
                  width: 130, height: 130),
              const SizedBox(height: 12),
              const Text('Sahabat Senja',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                          'Email', _emailController, false, _emailValidator),
                      const SizedBox(height: 20),
                      _buildTextField('Kata Sandi', _passwordController, true,
                          _passwordValidator),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _showForgotPasswordDialog,
                          child: Text('Lupa Kata Sandi?',
                              style: TextStyle(color: mainColor)),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _handleEmailLogin,
                                child: const Text('Masuk',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum punya akun?',
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _navigateToRegister,
                            child: Text('Daftar di sini',
                                style: TextStyle(
                                    color: mainColor,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('atau')),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _handleGoogleLogin,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/google.png',
                                width: 24, height: 24),
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

  Widget _buildTextField(String label, TextEditingController controller,
      bool isPassword, String? Function(String?)? validator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
