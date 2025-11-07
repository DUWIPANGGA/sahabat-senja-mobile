// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();
  
  // Login dengan Google, lalu sync ke Laravel
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // 1. Login dengan Firebase Google Auth
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = 
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;
      
      // 2. Sync user data ke Laravel backend
      final userData = {
        'firebase_uid': firebaseUser.uid,
        'name': firebaseUser.displayName,
        'email': firebaseUser.email,
        'phone_number': firebaseUser.phoneNumber,
        'profile_photo': firebaseUser.photoURL,
        'role': 'keluarga', // Default role
      };
      
      final laravelResponse = await _apiService.post('users/sync', userData);
      
      return {
        'firebase_user': firebaseUser,
        'laravel_user': laravelResponse['data'],
        'token': await firebaseUser.getIdToken(),
      };
      
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }
  
  // Logout
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
  
  // Check if user exists in Laravel
  Future<bool> checkUserExists(String firebaseUid) async {
    try {
      final response = await _apiService.get('users/check/$firebaseUid');
      return response['exists'] ?? false;
    } catch (e) {
      return false;
    }
  }
}