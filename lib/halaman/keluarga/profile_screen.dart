import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sahabatsenja_app/models/user_profile_model.dart';
import 'package:sahabatsenja_app/providers/user_profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isEditMode = false;
  bool _isLoading = false;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
      _loadUserData();
    });
  }

  void _loadProfile() async {
    setState(() => _isLoading = true);
    
    // Initialize dari storage dulu (cepat)
    await Provider.of<UserProfileProvider>(context, listen: false).initializeFromStorage();
    
    // Kemudian load dari API
    await Provider.of<UserProfileProvider>(context, listen: false).loadProfile();
    
    setState(() => _isLoading = false);
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userData = {
        'name': prefs.getString('user_name') ?? 'User',
        'email': prefs.getString('user_email') ?? '',
        'role': prefs.getString('user_role') ?? 'keluarga',
        'phone': prefs.getString('user_phone'),
        'address': prefs.getString('user_address'),
        'profile_picture': prefs.getString('profile_picture'),
      };
    });
    
    // Initialize controllers
    _nameController.text = _userData['name'];
    _emailController.text = _userData['email'];
    _phoneController.text = _userData['phone'] ?? '';
    _addressController.text = _userData['address'] ?? '';
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      final success = await provider.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        noTelepon: _phoneController.text,
        alamat: _addressController.text,
      );
      
      if (success && mounted) {
        // Update shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _nameController.text);
        await prefs.setString('user_email', _emailController.text);
        if (_phoneController.text.isNotEmpty) {
          await prefs.setString('user_phone', _phoneController.text);
        }
        if (_addressController.text.isNotEmpty) {
          await prefs.setString('user_address', _addressController.text);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile berhasil diperbarui'),
            backgroundColor: const Color(0xFF9C6223),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Keluar dari edit mode
        _toggleEditMode();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Gagal memperbarui profile'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() => _isLoading = true);
      
      final file = File(pickedFile.path);
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      final success = await provider.uploadProfilePicture(file);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diupload'),
            backgroundColor: Color(0xFF9C6223),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Reload profile
        _loadProfile();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Gagal mengupload foto profil'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Profile Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _toggleEditMode,
              tooltip: 'Edit Profile',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, provider, child) {
          if (_isLoading) {
            return _buildLoading();
          }
          
          final profile = provider.userProfile;
          final currentUser = profile != null 
              ? _createUserProfileFromProvider(profile)
              : _createUserProfileFromStorage();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan foto profil
                _buildProfileHeader(currentUser),
                
                const SizedBox(height: 24),
                
                // Form profile (read-only atau editable)
                _buildProfileForm(currentUser, provider),
                
                // Action buttons
                if (_isEditMode)
                  _buildActionButtons(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF9C6223)),
          const SizedBox(height: 16),
          Text(
            'Memuat profile...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _createUserProfileFromProvider(UserProfile profile) {
    return {
      'name': profile.name,
      'email': profile.email,
      'role': profile.role,
      'phone': profile.noTelepon,
      'address': profile.alamat,
      'profile_picture': profile.profilePictureUrl ?? _userData['profile_picture'],
      'role_name': profile.roleName,
    };
  }

  Map<String, dynamic> _createUserProfileFromStorage() {
    String roleName = 'User';
    switch (_userData['role']) {
      case 'admin':
        roleName = 'Administrator';
        break;
      case 'perawat':
        roleName = 'Perawat';
        break;
      case 'keluarga':
        roleName = 'Keluarga Lansia';
        break;
    }
    
    return {
      'name': _userData['name'],
      'email': _userData['email'],
      'role': _userData['role'],
      'phone': _userData['phone'],
      'address': _userData['address'],
      'profile_picture': _userData['profile_picture'],
      'role_name': roleName,
    };
  }

  Widget _buildProfileHeader(Map<String, dynamic> currentUser) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(width: double.infinity,
          child: Column(
            children: [
              // Foto profil
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF9C6223).withOpacity(0.1),
                    backgroundImage: currentUser['profile_picture'] != null
                        ? NetworkImage(currentUser['profile_picture']!)
                        : null,
                    child: currentUser['profile_picture'] == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF9C6223),
                          )
                        : null,
                  ),
                  if (!_isEditMode)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C6223),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Nama dan role
              Text(
                currentUser['name'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 4),
              
              Text(
                currentUser['role_name'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                currentUser['email'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileForm(Map<String, dynamic> currentUser, UserProfileProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Informasi Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isEditMode)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        // Reset controllers ke nilai semula
                        _nameController.text = currentUser['name'];
                        _emailController.text = currentUser['email'];
                        _phoneController.text = currentUser['phone'] ?? '';
                        _addressController.text = currentUser['address'] ?? '';
                        
                        // Clear errors
                        provider.clearError();
                        
                        // Keluar dari edit mode
                        _toggleEditMode();
                      },
                      tooltip: 'Batal',
                    ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              Text(
                _isEditMode ? 'Edit informasi profile Anda' : 'Detail profile Anda',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Name
              _buildFormField(
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                controller: _nameController,
                isEditable: _isEditMode,
                errorText: provider.validationErrors?['name']?.first,
                validator: (value) {
                  if (_isEditMode && (value == null || value.isEmpty)) {
                    return 'Nama harus diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Email
              _buildFormField(
                label: 'Email',
                icon: Icons.email_outlined,
                controller: _emailController,
                isEditable: _isEditMode,
                keyboardType: TextInputType.emailAddress,
                errorText: provider.validationErrors?['email']?.first,
                validator: (value) {
                  if (_isEditMode) {
                    if (value == null || value.isEmpty) {
                      return 'Email harus diisi';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Email tidak valid';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Phone
              _buildFormField(
                label: 'Nomor Telepon',
                icon: Icons.phone_outlined,
                controller: _phoneController,
                isEditable: _isEditMode,
                keyboardType: TextInputType.phone,
                errorText: provider.validationErrors?['no_telepon']?.first,
              ),
              
              const SizedBox(height: 16),
              
              // Address
              _buildFormField(
                label: 'Alamat',
                icon: Icons.location_on_outlined,
                controller: _addressController,
                isEditable: _isEditMode,
                maxLines: 3,
                errorText: provider.validationErrors?['alamat']?.first,
              ),
              
              // Role (read-only)
              const SizedBox(height: 16),
              _buildReadOnlyField(
                label: 'Role',
                icon: Icons.badge_outlined,
                value: currentUser['role_name'],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditable,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? errorText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: isEditable,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF9C6223)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: isEditable ? Colors.grey[50] : Colors.grey[100],
        errorText: errorText,
        suffixIcon: !isEditable ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey) : null,
      ),
      style: TextStyle(
        color: isEditable ? Colors.black87 : Colors.grey[700],
      ),
      validator: validator,
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required IconData icon,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9C6223), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildActionButtons(UserProfileProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6223),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: _toggleEditMode,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}