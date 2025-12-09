import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService = ApiService();

  // 🔹 Get current Firebase user
  User? get currentUser => _auth.currentUser;

  // 🔹 Get current Firebase token
  Future<String?> getFirebaseToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      print('❌ Get Firebase Token Error: $e');
      return null;
    }
  }

  // 🔹 Fungsi dipakai LoginScreen - TIDAK DIUBAH
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

  // 🔹 Login dengan Email dan Password
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login ke Firebase
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return {
          'success': false,
          'message': 'Login gagal, user tidak ditemukan',
        };
      }

      // 2. Gunakan syncWithLaravel yang sudah ada
      final syncResponse = await syncWithLaravel(role: 'keluarga');

      if (syncResponse != null && 
          (syncResponse['success'] == true || syncResponse['status'] == 'success')) {
        // 3. Simpan data ke SharedPreferences
        await _saveUserData(
          token: syncResponse['token'] ?? syncResponse['access_token'],
          userData: syncResponse['user'] ?? {
            'id': firebaseUser.uid,
            'name': firebaseUser.displayName ?? email.split('@')[0],
            'email': email,
            'role': 'keluarga',
          },
        );

        return {
          'success': true,
          'message': 'Login berhasil',
          'user': syncResponse['user'],
        };
      } else {
        return {
          'success': false,
          'message': syncResponse?['message'] ?? 'Sinkronisasi dengan server gagal',
        };
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login gagal';
      if (e.code == 'user-not-found') {
        message = 'Email tidak ditemukan';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      } else if (e.code == 'user-disabled') {
        message = 'Akun dinonaktifkan';
      } else if (e.code == 'too-many-requests') {
        message = 'Terlalu banyak percobaan, coba lagi nanti';
      }

      return {
        'success': false,
        'message': message,
        'error': e.code,
      };
    } catch (e) {
      print('❌ Login Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // 🔹 Login dengan Google
  Future<Map<String, dynamic>> loginWithGoogle({required String role}) async {
    try {
      // 1. Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Google sign in dibatalkan',
        };
      }

      // 2. Get Google authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return {
          'success': false,
          'message': 'Google login gagal',
        };
      }

      // 5. Gunakan syncWithLaravel yang sudah ada
      final syncResponse = await syncWithLaravel(role: role);

      if (syncResponse != null && 
          (syncResponse['success'] == true || syncResponse['status'] == 'success')) {
        // 6. Simpan data ke SharedPreferences
        await _saveUserData(
          token: syncResponse['token'] ?? syncResponse['access_token'],
          userData: syncResponse['user'] ?? {
            'id': firebaseUser.uid,
            'name': firebaseUser.displayName ?? googleUser.displayName ?? 'User',
            'email': firebaseUser.email ?? googleUser.email,
            'role': role,
            'profile_photo': firebaseUser.photoURL ?? googleUser.photoUrl,
          },
        );

        return {
          'success': true,
          'message': 'Login Google berhasil',
          'user': syncResponse['user'],
        };
      } else {
        return {
          'success': false,
          'message': syncResponse?['message'] ?? 'Login dengan Google gagal',
        };
      }
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': 'Google login gagal: ${e.message}',
        'error': e.code,
      };
    } catch (e) {
      print('❌ Google Login Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // 🔹 Save user data to SharedPreferences
  Future<void> _saveUserData({
    required String? token,
    required Map<String, dynamic>? userData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (token != null && token.isNotEmpty) {
        await prefs.setString('auth_token', token);
        print('✅ Token saved: ${token.substring(0, 20)}...');
      }
      
      if (userData != null) {
        // Extract and save individual fields
        final id = userData['id']?.toString() ?? userData['firebase_uid']?.toString();
        final name = userData['name']?.toString() ?? 'User';
        final email = userData['email']?.toString() ?? '';
        final role = userData['role']?.toString() ?? 'keluarga';
        
        if (id != null) await prefs.setString('user_id', id);
        await prefs.setString('user_name', name);
        await prefs.setString('user_email', email);
        await prefs.setString('user_role', role);
        
        // Optional fields
        if (userData['no_telepon'] != null) {
          await prefs.setString('user_phone', userData['no_telepon'].toString());
        }
        if (userData['alamat'] != null) {
          await prefs.setString('user_address', userData['alamat'].toString());
        }
        if (userData['profile_picture'] != null) {
          await prefs.setString('profile_picture', userData['profile_picture'].toString());
        }
        if (userData['profile_photo'] != null) {
          await prefs.setString('profile_picture', userData['profile_photo'].toString());
        }
        
        // Save the whole user data as JSON for easy access
        await prefs.setString('user_data', jsonEncode(userData));
      }
      
      print('✅ User data saved to SharedPreferences');
    } catch (e) {
      print('❌ Save User Data Error: $e');
    }
  }

  // 🔹 Get saved user data from SharedPreferences
  Future<Map<String, dynamic>> getSavedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to get from JSON first
      final userDataJson = prefs.getString('user_data');
      if (userDataJson != null && userDataJson.isNotEmpty) {
        try {
          final data = jsonDecode(userDataJson);
          if (data is Map<String, dynamic>) {
            return data;
          }
        } catch (e) {
          print('❌ Error parsing user_data JSON: $e');
        }
      }
      
      // Fallback to individual keys
      return {
        'id': prefs.getString('user_id') ?? '',
        'name': prefs.getString('user_name') ?? 'User',
        'email': prefs.getString('user_email') ?? '',
        'role': prefs.getString('user_role') ?? 'keluarga',
        'no_telepon': prefs.getString('user_phone'),
        'alamat': prefs.getString('user_address'),
        'profile_picture': prefs.getString('profile_picture'),
      };
    } catch (e) {
      print('❌ Get Saved User Data Error: $e');
      return {};
    }
  }

  // 🔹 Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      // Check Firebase auth
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return false;
      
      // Check token in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('❌ Check Login Error: $e');
      return false;
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    try {
      // 1. Logout from Firebase
      await _auth.signOut();
      
      // 2. Logout from Google
      await _googleSignIn.signOut();
      
      // 3. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_role');
      await prefs.remove('user_phone');
      await prefs.remove('user_address');
      await prefs.remove('profile_picture');
      await prefs.remove('user_data');
      
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout Error: $e');
    }
  }

  // 🔹 Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    String? phone,
    String? address,
  }) async {
    try {
      // 1. Create Firebase user
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return {
          'success': false,
          'message': 'Registrasi gagal',
        };
      }

      // 2. Update display name in Firebase
      await firebaseUser.updateDisplayName(name);

      // 3. Register to Laravel
      final registerData = {
        'firebase_uid': firebaseUser.uid,
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
        'role': role,
        'no_telepon': phone,
        'alamat': address,
      };

      final response = await _apiService.post('register', registerData, includeAuth: false);

      if (response['success'] == true || response['status'] == 'success') {
        // 4. Save user data
        await _saveUserData(
          token: response['token'] ?? response['access_token'],
          userData: response['user'] ?? registerData,
        );

        return {
          'success': true,
          'message': 'Registrasi berhasil',
          'user': response['user'],
        };
      } else {
        // If Laravel registration fails, delete Firebase user
        await firebaseUser.delete();
        
        return {
          'success': false,
          'message': response['message'] ?? 'Registrasi gagal',
          'errors': response['errors'],
        };
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registrasi gagal';
      if (e.code == 'email-already-in-use') {
        message = 'Email sudah digunakan';
      } else if (e.code == 'weak-password') {
        message = 'Password terlalu lemah';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      }

      return {
        'success': false,
        'message': message,
        'error': e.code,
      };
    } catch (e) {
      print('❌ Register Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // 🔹 Get current token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 🔹 Update user data in SharedPreferences
  Future<void> updateUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update individual fields
      if (userData['name'] != null) {
        await prefs.setString('user_name', userData['name']);
      }
      if (userData['email'] != null) {
        await prefs.setString('user_email', userData['email']);
      }
      if (userData['no_telepon'] != null) {
        await prefs.setString('user_phone', userData['no_telepon']);
      }
      if (userData['alamat'] != null) {
        await prefs.setString('user_address', userData['alamat']);
      }
      if (userData['profile_picture'] != null) {
        await prefs.setString('profile_picture', userData['profile_picture']);
      }
      
      // Update the complete JSON
      final currentData = await getSavedUserData();
      final updatedData = {...currentData, ...userData};
      await prefs.setString('user_data', jsonEncode(updatedData));
      
      print('✅ User data updated in SharedPreferences');
    } catch (e) {
      print('❌ Update User Data Error: $e');
    }
  }

  // 🔹 Clear error messages
  void clearError() {
    // Implement if needed
  }
}