import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sahabatsenja_app/models/user_profile_model.dart';
import 'package:sahabatsenja_app/services/auth_service.dart';
import 'package:sahabatsenja_app/services/profile_service.dart';

class UserProfileProvider with ChangeNotifier {
  final UserProfileService _profileService = UserProfileService();
  final AuthService _authService = AuthService();
  
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  Map<String, List<String>>? _validationErrors;
  
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  Map<String, List<String>>? get validationErrors => _validationErrors;
  
  // Clear messages
  void _clearMessages() {
    _error = null;
    _successMessage = null;
    _validationErrors = null;
  }
  
  // Load profile dari API atau storage
  Future<void> loadProfile() async {
    _isLoading = true;
    _clearMessages();
    notifyListeners();
    
    try {
      final profile = await _profileService.getCompleteProfile();
      
      if (profile != null) {
        _userProfile = profile;
        _successMessage = 'Profile berhasil dimuat';
      } else {
        _error = 'Tidak dapat memuat profile';
      }
    } catch (e) {
      _error = 'Gagal memuat profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? noTelepon,
    String? alamat,
  }) async {
    _isLoading = true;
    _clearMessages();
    notifyListeners();
    
    try {
      final response = await _profileService.updateProfileToApi(
        name: name,
        email: email,
        noTelepon: noTelepon,
        alamat: alamat,
      );
      
      if (_profileService.isResponseSuccess(response)) {
        // Update local profile
        if (_userProfile != null) {
          _userProfile = _userProfile!.copyWith(
            name: name ?? _userProfile!.name,
            email: email ?? _userProfile!.email,
            noTelepon: noTelepon ?? _userProfile!.noTelepon,
            alamat: alamat ?? _userProfile!.alamat,
            updatedAt: DateTime.now(),
          );
        }
        
        // Update storage
        await _profileService.updateProfileInStorage({
          'name': name,
          'email': email,
          'no_telepon': noTelepon,
          'alamat': alamat,
        });
        
        // Update AuthService storage
        await _authService.updateUserData({
          'name': name,
          'email': email,
          'no_telepon': noTelepon,
          'alamat': alamat,
        });
        
        _successMessage = _profileService.getResponseMessage(response);
        return true;
      } else {
        _error = _profileService.getResponseMessage(response);
        _validationErrors = _profileService.getValidationErrors(response);
        return false;
      }
    } catch (e) {
      _error = 'Gagal memperbarui profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _clearMessages();
    notifyListeners();
    
    try {
      final response = await _profileService.changePasswordToApi(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      if (_profileService.isResponseSuccess(response)) {
        _successMessage = _profileService.getResponseMessage(response);
        return true;
      } else {
        _error = _profileService.getResponseMessage(response);
        _validationErrors = _profileService.getValidationErrors(response);
        return false;
      }
    } catch (e) {
      _error = 'Gagal mengganti password: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Upload profile picture
  Future<bool> uploadProfilePicture(File imageFile) async {
    _isLoading = true;
    _clearMessages();
    notifyListeners();
    
    try {
      final response = await _profileService.uploadProfilePictureToApi(imageFile);
      
      if (_profileService.isResponseSuccess(response)) {
        final profile = _profileService.parseApiResponse(response);
        if (profile != null) {
          _userProfile = profile;
          
          // Update storage
          await _profileService.saveProfileToStorage(profile);
          await _authService.updateUserData({
            'profile_picture': profile.profilePicture,
          });
        }
        
        _successMessage = _profileService.getResponseMessage(response);
        return true;
      } else {
        _error = _profileService.getResponseMessage(response);
        _validationErrors = _profileService.getValidationErrors(response);
        return false;
      }
    } catch (e) {
      _error = 'Gagal mengupload foto profil: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Remove profile picture
  Future<bool> removeProfilePicture() async {
    _isLoading = true;
    _clearMessages();
    notifyListeners();
    
    try {
      final response = await _profileService.removeProfilePictureFromApi();
      
      if (_profileService.isResponseSuccess(response)) {
        // Update local profile
        if (_userProfile != null) {
          _userProfile = _userProfile!.copyWith(
            profilePicture: null,
            updatedAt: DateTime.now(),
          );
        }
        
        // Update storage
        await _profileService.updateProfileInStorage({
          'profile_picture': null,
        });
        
        // Update AuthService storage
        await _authService.updateUserData({
          'profile_picture': null,
        });
        
        _successMessage = _profileService.getResponseMessage(response);
        return true;
      } else {
        _error = _profileService.getResponseMessage(response);
        return false;
      }
    } catch (e) {
      _error = 'Gagal menghapus foto profil: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    _validationErrors = null;
    notifyListeners();
  }
  
  // Clear success message
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }
  
  // Clear validation errors for specific field
  void clearFieldError(String field) {
    _validationErrors?.remove(field);
    notifyListeners();
  }
  
  // Initialize profile dari storage (cepat, tanpa API call)
  Future<void> initializeFromStorage() async {
    final profile = await _profileService.getProfileFromStorage();
    if (profile != null) {
      _userProfile = profile;
      notifyListeners();
    }
  }
}