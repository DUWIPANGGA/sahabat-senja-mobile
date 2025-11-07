import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Color mainColor = const Color(0xFF9C6223);
  final Color backgroundColor = const Color(0xFFF8F4F0);
  final ImagePicker _imagePicker = ImagePicker();

  File? _profileImage;
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _auth.currentUser;
    _nameController.text = user?.displayName ?? '';
    _phoneController.text = user?.phoneNumber ?? '';
    _emailController.text = user?.email ?? '';
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Ubah Foto Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainColor)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOptionButton(icon: Icons.photo_library, label: 'Galeri', onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }),
                _buildImageOptionButton(icon: Icons.camera_alt, label: 'Kamera', onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Batal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 75);
      if (image != null) {
        setState(() => _profileImage = File(image.path));
      }
    } catch (e) {
      _showSnack('Gagal memilih gambar: $e');
    }
  }

  Future<void> _saveProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());
        setState(() => _isEditing = false);
        _showSnack('Profile berhasil diperbarui', isError: false);
      }
    } catch (e) {
      _showSnack('Gagal memperbarui profile: $e');
    }
  }

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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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

  Widget _buildImageOptionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(color: mainColor.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: mainColor)),
            child: Icon(icon, color: mainColor, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: mainColor, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showSnack(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profil' : 'Profil Saya'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isEditing) {
              setState(() {
                _isEditing = false;
                _loadUserData();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // FOTO PROFIL
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: mainColor, width: 3)),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : (user?.photoURL != null
                            ? Image.network(user!.photoURL!, fit: BoxFit.cover)
                            : Container(color: mainColor.withOpacity(0.1), child: Icon(Icons.person, size: 50, color: mainColor))),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showImagePickerDialog,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: mainColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (!_isEditing)
              TextButton(
                onPressed: () => setState(() => _isEditing = true),
                style: TextButton.styleFrom(foregroundColor: mainColor),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.edit, size: 16), SizedBox(width: 4), Text('Edit Profil')]),
              ),

            const SizedBox(height: 20),

            // INFORMASI PROFIL
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: mainColor.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                    child: Text('Informasi Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainColor)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _buildProfileField(label: 'Nama Lengkap', value: _nameController.text, icon: Icons.person_outline, isEditing: _isEditing, controller: _nameController),
                        _buildDivider(),
                        _buildProfileField(label: 'Email', value: _emailController.text, icon: Icons.email_outlined, isEditing: false, controller: _emailController),
                        _buildDivider(),
                        _buildProfileField(label: 'Nomor Telepon', value: _phoneController.text, icon: Icons.phone_outlined, isEditing: _isEditing, controller: _phoneController),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // TOMBOL SIMPAN / BATAL
            if (_isEditing) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: mainColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _saveProfile,
                  child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: mainColor)),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _loadUserData();
                    });
                  },
                  child: Text('Batal', style: TextStyle(color: mainColor, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // MENU LAINNYA
            if (!_isEditing)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildMenuButton(icon: Icons.settings_outlined, label: 'Pengaturan', onTap: () {}),
                    _buildDivider(),
                    _buildMenuButton(icon: Icons.help_outline, label: 'Bantuan & Dukungan', onTap: () {}),
                    _buildDivider(),
                    _buildMenuButton(icon: Icons.privacy_tip_outlined, label: 'Kebijakan Privasi', onTap: () {}),
                    _buildDivider(),
                    _buildMenuButton(icon: Icons.logout, label: 'Keluar dari Aplikasi', onTap: _showLogoutDialog, isLogout: true),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({required String label, required String value, required IconData icon, required bool isEditing, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: mainColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 6),
                isEditing && controller != null
                    ? TextFormField(
                        controller: controller,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: mainColor)),
                        ),
                      )
                    : Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({required IconData icon, required String label, required VoidCallback onTap, bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : mainColor, size: 24),
      title: Text(label, style: TextStyle(color: isLogout ? Colors.red : Colors.black87, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isLogout ? Colors.red : Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildDivider() => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 1, color: Colors.grey[300]));

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
