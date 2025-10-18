import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sahabatsenja_app/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase berhasil diinisialisasi.');
  } catch (e) {
    debugPrint('Firebase sudah diinisialisasi sebelumnya: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahabat Senja',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Ganti ini ke SplashScreen() kalau kamu pakai splash dulu sebelum login
      home: const SplashScreen(), 
    );
  }
}
