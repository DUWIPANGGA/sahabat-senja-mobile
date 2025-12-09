import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sahabatsenja_app/models/user_profile_model.dart';
import 'package:sahabatsenja_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService {
  final ApiService _apiService = ApiService();

  // 🔹 Get user profile dari API
  Future<Map<String, dynamic>> getProfileFromApi() async {
    try {
      return await _apiService.get('profile');
    } catch (e) {
      print('❌ Get Profile from API Error: $e');
      return {
        'success': false,
        'message': 'Gagal mengambil profile dari server: $e',
      };
    }
  }

  // 🔹 Update profile ke API
  Future<Map<String, dynamic>> updateProfileToApi({
    String? name,
    String? email,
    String? noTelepon,
    String? alamat,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (noTelepon != null) data['no_telepon'] = noTelepon;
      if (alamat != null) data['alamat'] = alamat;
      
      return await _apiService.put('profile/update', data);
    } catch (e) {
      print('❌ Update Profile to API Error: $e');
      return {
        'success': false,
        'message': 'Gagal memperbarui profile: $e',
      };
    }
  }

  // 🔹 Change password di API
  Future<Map<String, dynamic>> changePasswordToApi({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final data = {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      };
      
      return await _apiService.put('profile/password', data);
    } catch (e) {
      print('❌ Change Password Error: $e');
      return {
        'success': false,
        'message': 'Gagal mengganti password: $e',
      };
    }
  }

  // 🔹 Upload profile picture (Multipart)
  Future<Map<String, dynamic>> uploadProfilePictureToApi(File imageFile) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/profile/picture');
      
      // Get token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan',
        };
      }
      
      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      
      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_picture',
          imageFile.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
      
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Upload Profile Picture Error: $e');
      return {
        'success': false,
        'message': 'Gagal mengupload foto profil: $e',
      };
    }
  }

  // 🔹 Remove profile picture di API
  Future<Map<String, dynamic>> removeProfilePictureFromApi() async {
    try {
      return await _apiService.delete('profile/picture');
    } catch (e) {
      print('❌ Remove Profile Picture Error: $e');
      return {
        'success': false,
        'message': 'Gagal menghapus foto profil: $e',
      };
    }
  }

  // 🔹 Get profile dari SharedPreferences
  Future<UserProfile?> getProfileFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to get from JSON first
      final userDataJson = prefs.getString('user_data');
      if (userDataJson != null && userDataJson.isNotEmpty) {
        try {
          final data = jsonDecode(userDataJson);
          if (data is Map<String, dynamic>) {
            return UserProfile.fromJson(data);
          }
        } catch (e) {
          print('❌ Error parsing user_data JSON: $e');
        }
      }
      
      // Fallback to individual keys
      final id = prefs.getString('user_id');
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      final role = prefs.getString('user_role');
      
      if (id == null || name == null || email == null || role == null) {
        return null;
      }
      
      return UserProfile(
        id: id,
        name: name,
        email: email,
        role: role,
        noTelepon: prefs.getString('user_phone'),
        alamat: prefs.getString('user_address'),
        profilePicture: prefs.getString('profile_picture'),
        firebaseUid: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('❌ Get Profile from Storage Error: $e');
      return null;
    }
  }

  // 🔹 Save profile to SharedPreferences
  Future<void> saveProfileToStorage(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save individual fields
      await prefs.setString('user_id', profile.id);
      await prefs.setString('user_name', profile.name);
      await prefs.setString('user_email', profile.email);
      await prefs.setString('user_role', profile.role);
      
      if (profile.noTelepon != null) {
        await prefs.setString('user_phone', profile.noTelepon!);
      }
      
      if (profile.alamat != null) {
        await prefs.setString('user_address', profile.alamat!);
      }
      
      if (profile.profilePicture != null) {
        await prefs.setString('profile_picture', profile.profilePicture!);
      }
      
      // Save as JSON
      await prefs.setString('user_data', jsonEncode(profile.toJson()));
      
      print('✅ Profile saved to storage');
    } catch (e) {
      print('❌ Save Profile to Storage Error: $e');
    }
  }

  // 🔹 Update specific fields in storage
  Future<void> updateProfileInStorage(Map<String, dynamic> updates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update individual fields
      if (updates['name'] != null) {
        await prefs.setString('user_name', updates['name']);
      }
      if (updates['email'] != null) {
        await prefs.setString('user_email', updates['email']);
      }
      if (updates['no_telepon'] != null) {
        await prefs.setString('user_phone', updates['no_telepon']);
      }
      if (updates['alamat'] != null) {
        await prefs.setString('user_address', updates['alamat']);
      }
      if (updates['profile_picture'] != null) {
        await prefs.setString('profile_picture', updates['profile_picture']);
      }
      
      // Update JSON
      final currentJson = prefs.getString('user_data');
      if (currentJson != null) {
        try {
          final currentData = jsonDecode(currentJson);
          final updatedData = {...currentData, ...updates};
          await prefs.setString('user_data', jsonEncode(updatedData));
        } catch (e) {
          print('❌ Error updating user_data JSON: $e');
        }
      }
      
      print('✅ Profile updated in storage');
    } catch (e) {
      print('❌ Update Profile in Storage Error: $e');
    }
  }

  // 🔹 Parse API response to UserProfile
  UserProfile? parseApiResponse(Map<String, dynamic> response) {
    try {
      if (response['success'] == true || response['status'] == 'success') {
        if (response['data'] != null) {
          return UserProfile.fromJson(response['data']);
        } else if (response.containsKey('id')) {
          return UserProfile.fromJson(response);
        } else if (response['user'] != null) {
          return UserProfile.fromJson(response['user']);
        }
      }
      return null;
    } catch (e) {
      print('❌ Parse API Response Error: $e');
      return null;
    }
  }

  // 🔹 Check if API response is successful
  bool isResponseSuccess(Map<String, dynamic> response) {
    return response['success'] == true || 
           response['status'] == 'success';
  }

  // 🔹 Get error message from response
  String getResponseMessage(Map<String, dynamic> response) {
    return response['message']?.toString() ?? 
           (response['success'] == true ? 'Berhasil' : 'Terjadi kesalahan');
  }

  // 🔹 Get validation errors from response
  Map<String, List<String>>? getValidationErrors(Map<String, dynamic> response) {
    if (response['errors'] != null && response['errors'] is Map) {
      final errors = Map<String, dynamic>.from(response['errors']);
      final validationErrors = <String, List<String>>{};
      
      errors.forEach((key, value) {
        if (value is List) {
          validationErrors[key] = List<String>.from(value);
        } else {
          validationErrors[key] = [value.toString()];
        }
      });
      
      return validationErrors.isNotEmpty ? validationErrors : null;
    }
    return null;
  }

  // 🔹 Get complete profile (try API first, then storage)
  Future<UserProfile?> getCompleteProfile() async {
    try {
      // Try to get from API first
      final apiResponse = await getProfileFromApi();
      
      if (isResponseSuccess(apiResponse)) {
        final profile = parseApiResponse(apiResponse);
        if (profile != null) {
          await saveProfileToStorage(profile);
          return profile;
        }
      }
      
      // Fallback to storage
      return await getProfileFromStorage();
    } catch (e) {
      print('❌ Get Complete Profile Error: $e');
      return await getProfileFromStorage();
    }
  }
}