import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  // 🔹 Fungsi dipakai LoginScreen
  Future<Map<String, dynamic>?> syncWithLaravel({required String role}) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final userData = {
        'firebase_uid': firebaseUser.uid,
        'name': firebaseUser.displayName,
        'email': firebaseUser.email,
        'profile_photo': firebaseUser.photoURL,
      };

      Map<String, dynamic> response;

      if (role == "keluarga") {
        response = await _apiService.post("login/google", userData);
      } else {
        // perawat
        response = await _apiService.post("login/perawat", {
          'firebase_uid': firebaseUser.uid,
        });
      }

      return response;
    } catch (e) {
      print("❌ syncWithLaravel Error: $e");
      return null;
    }
  }

    
}
