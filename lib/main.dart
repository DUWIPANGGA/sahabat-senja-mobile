import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan ini
import 'package:provider/provider.dart';
import 'package:sahabatsenja_app/firebase_options.dart';
import 'package:sahabatsenja_app/halaman/login_screen.dart';
import 'package:sahabatsenja_app/providers/chat_provider.dart';
import 'package:sahabatsenja_app/providers/notification_provider.dart';
import 'package:sahabatsenja_app/providers/user_profile_provider.dart' show ProfileProvider, UserProfileProvider;

void main() async {
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

  // Inisialisasi date format untuk Indonesia
  try {
    await initializeDateFormatting('id_ID', null);
    debugPrint('Locale data berhasil diinisialisasi untuk Indonesia.');
  } catch (e) {
    debugPrint('Gagal menginisialisasi locale data: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
          lazy: false,
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9C6223)),
        fontFamily: 'Poppins',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF9C6223),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9C6223),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}