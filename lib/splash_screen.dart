import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sahabatsenja_app/halaman/login_screen.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Color mainColor = const Color(0xFF9C6223);
  final ImagePicker _imagePicker = ImagePicker();

  File? _profileImage;
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _auth.currentUser;
    _nameController.text = user?.displayName ?? 'Nurul Alfiyah';
    _phoneController.text = user?.phoneNumber ?? '';
  }

  // 🔹 PILIH GAMBAR DARI GALERI
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnack('Gagal memilih gambar: $e');
    }
  }

  // 🔹 AMBIL FOTO DARI KAMERA
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (photo != null) {
        setState(() {
          _profileImage = File(photo.path);
        });
      }
    } catch (e) {
      _showSnack('Gagal mengambil foto: $e');
    }
  }

  // 🔹 SIMPAN PERUBAHAN PROFILE
  Future<void> _saveProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(_nameController.text.trim());



        setState(() {
          _isEditing = false;
        });

        _showSnack('Profile berhasil diperbarui');
      }
    } catch (e) {
      _showSnack('Gagal memperbarui profile: $e');
    }
  }

  // 🔹 FUNGSI LOGOUT
  Future<void> _logout() async {
    try {
      await _auth.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showSnack('Gagal logout: $e');
    }
  }

  // 🔹 DIALOG KONFIRMASI LOGOUT
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🔹 DIALOG PILIH FOTO
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Foto Profil'),
        content: const Text('Pilih sumber foto:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage();
            },
            child: const Text('Galeri'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _takePhoto();
            },
            child: const Text('Kamera'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Edit Profil',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔹 FOTO PROFIL
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: mainColor, width: 3),
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : user?.photoURL != null
                            ? Image.network(user!.photoURL!, fit: BoxFit.cover)
                            : Container(
                                color: mainColor.withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: mainColor,
                                ),
                              ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: mainColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                        onPressed: _showImagePickerDialog,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 INFORMASI PROFIL
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildEditableField(
                      label: 'Nama Lengkap',
                      controller: _nameController,
                      icon: Icons.person,
                      isEditing: _isEditing,
                    ),
                    _buildDivider(),
                    _buildInfoField(
                      label: 'Email',
                      value: user?.email ?? 'nurulalfiyah500@gmail.com',
                      icon: Icons.email,
                    ),
                    _buildDivider(),
                    _buildEditableField(
                      label: 'Nomor Telepon',
                      controller: _phoneController,
                      icon: Icons.phone,
                      isEditing: _isEditing,
                    ),
                    _buildDivider(),
                    _buildInfoField(
                      label: 'Status',
                      value: 'Bergabung 0 hari yang lalu',
                      icon: Icons.calendar_today,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 TOMBOL SIMPAN / BATAL (SAAT EDIT)
            if (_isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _loadUserData(); // Reset changes
                        });
                      },
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveProfile,
                      child: const Text(
                        'Simpan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // 🔹 TOMBOL LOGOUT
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('Keluar dari Aplikasi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(
      {required String label, required String value, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: mainColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: mainColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 4),
                isEditing
                    ? TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                      )
                    : Text(controller.text,
                        style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[300]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
