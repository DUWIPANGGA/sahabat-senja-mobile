// Pastikan main.dart Anda seperti INI:

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahabatsenja_app/firebase_options.dart';
import 'package:sahabatsenja_app/halaman/login_screen.dart';
import 'package:sahabatsenja_app/providers/chat_provider.dart';

void main() async{
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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
          lazy: false, // ⬅️ PASTIKAN lazy: false untuk immediate creation
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahabat Senja',
      theme: ThemeData(
        primaryColor: const Color(0xFF9C6223),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}