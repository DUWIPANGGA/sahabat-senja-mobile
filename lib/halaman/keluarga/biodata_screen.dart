import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/services/datalansia_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiodataLansiaScreen extends StatefulWidget {
  const BiodataLansiaScreen({super.key});

  @override
  State<BiodataLansiaScreen> createState() => _BiodataLansiaScreenState();
}

class _BiodataLansiaScreenState extends State<BiodataLansiaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingList = false;
  bool _isFormVisible = false;
  String? _userEmail;
  String? _userName;
  List<Datalansia> _lansiaList = [];
  Datalansia? _selectedLansia; // Untuk mode edit

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _umurController = TextEditingController();
  final TextEditingController _golDarahController = TextEditingController();
  final TextEditingController _riwayatController = TextEditingController();
  final TextEditingController _alergiController = TextEditingController();
  final TextEditingController _obatController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();

  DateTime? _selectedDate;
  String? _jenisKelamin;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLansiaList();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userEmail = prefs.getString('user_email');
      _userName = prefs.getString('user_name');
      
      print('👤 User data loaded:');
      print('  Email: $_userEmail');
      print('  Name: $_userName');
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  Future<void> _loadLansiaList() async {
    setState(() => _isLoadingList = true);
    try {
      if (_userEmail != null && _userEmail!.isNotEmpty) {
        final data = await DatalansiaService().getDatalansiaByKeluarga(_userEmail!);
        setState(() {
          _lansiaList = data;
        });
        print('📋 Loaded ${data.length} lansia');
      }
    } catch (e) {
      print('❌ Error loading lansia list: $e');
    } finally {
      setState(() => _isLoadingList = false);
    }
  }

  void _calculateAge() {
    if (_selectedDate != null) {
      final now = DateTime.now();
      final age = now.year - _selectedDate!.year;
      final hasBirthdayPassed = now.month > _selectedDate!.month || 
          (now.month == _selectedDate!.month && now.day >= _selectedDate!.day);
      final calculatedAge = hasBirthdayPassed ? age : age - 1;
      
      _umurController.text = calculatedAge.toString();
    }
  }

  void _showForm({Datalansia? lansia}) {
    _clearForm();
    
    if (lansia != null) {
      _selectedLansia = lansia;
      
      // Isi form dengan data lansia
      _namaController.text = lansia.namaLansia ?? '';
      _tempatLahirController.text = lansia.tempatLahirLansia ?? '';
      _golDarahController.text = lansia.golDarahLansia ?? '';
      _riwayatController.text = lansia.riwayatPenyakitLansia ?? '';
      _alergiController.text = lansia.alergiLansia ?? '';
      _obatController.text = lansia.obatRutinLansia ?? '';
      _noHpController.text = lansia.noHpAnak ?? '';
      _alamatController.text = lansia.alamatLengkap ?? '';
      _jenisKelamin = lansia.jenisKelaminLansia;
      
      // Tanggal lahir
      if (lansia.tanggalLahirLansia != null) {
        final dateParts = lansia.tanggalLahirLansia!.split('-');
        if (dateParts.length == 3) {
          final year = int.tryParse(dateParts[0]);
          final month = int.tryParse(dateParts[1]);
          final day = int.tryParse(dateParts[2]);
          
          if (year != null && month != null && day != null) {
            _selectedDate = DateTime(year, month, day);
            _tanggalLahirController.text = '$day/$month/$year';
            _calculateAge();
          }
        }
      }
    }
    
    setState(() => _isFormVisible = true);
  }

  void _clearForm() {
    _selectedLansia = null;
    _selectedDate = null;
    _jenisKelamin = null;
    
    _namaController.clear();
    _tempatLahirController.clear();
    _tanggalLahirController.clear();
    _umurController.clear();
    _golDarahController.clear();
    _riwayatController.clear();
    _alergiController.clear();
    _obatController.clear();
    _noHpController.clear();
    _alamatController.clear();
    
    _formKey.currentState?.reset();
  }

  void _hideForm() {
    _clearForm();
    setState(() => _isFormVisible = false);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _isLoading = true);
      
      try {
        if (_userEmail == null) {
          throw Exception('User email tidak ditemukan. Silakan login ulang.');
        }

        // Buat objek Datalansia dengan data dari form
        final datalansia = Datalansia(
          id: _selectedLansia?.id,
          namaLansia: _namaController.text,
          tanggalLahirLansia:
              "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
          tempatLahirLansia: _tempatLahirController.text,
          umurLansia: int.tryParse(_umurController.text),
          jenisKelaminLansia: _jenisKelamin,
          golDarahLansia: _golDarahController.text,
          riwayatPenyakitLansia: _riwayatController.text,
          alergiLansia: _alergiController.text,
          obatRutinLansia: _obatController.text,
          alamatLengkap: _alamatController.text,
          namaAnak: _userName ?? 'Tidak diketahui',
          noHpAnak: _noHpController.text,
          emailAnak: _userEmail!,
        );

        print('📤 Data yang akan dikirim:');
        print(datalansia.toJson());

        bool success;
        if (_selectedLansia != null) {
          // Update mode
          await DatalansiaService().updateDatalansia(_selectedLansia!.id!, datalansia);
          success = true;
        } else {
          // Create mode
          await DatalansiaService().createDatalansia(datalansia);
          success = true;
        }

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Biodata ${datalansia.namaLansia} berhasil ${_selectedLansia != null ? 'diperbarui' : 'disimpan'}!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Refresh list dan reset form
          await _loadLansiaList();
          _hideForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Terjadi kesalahan: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        print('❌ Error submit form: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      String errorMessage = 'Harap isi semua data dengan benar.';
      
      if (_selectedDate == null) {
        errorMessage = 'Tanggal lahir harus diisi.';
      } else if (_jenisKelamin == null) {
        errorMessage = 'Jenis kelamin harus dipilih.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ $errorMessage'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteLansia(Datalansia lansia) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus data ${lansia.namaLansia}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await DatalansiaService().deleteDatalansia(lansia.id!);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Data ${lansia.namaLansia} berhasil dihapus!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          await _loadLansiaList();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menghapus: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isFormVisible ? 'Form Biodata Lansia' : 'Daftar Lansia'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isFormVisible)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadLansiaList,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFF9F5),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: _isFormVisible 
                  ? _buildFormContent()
                  : _buildListContent(),
            ),
            
            // Loading overlay
            if (_isLoading || _isLoadingList)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C6223)),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _isFormVisible ? null : FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(),
            const SizedBox(height: 24),
            
            // Data Lansia Section
            _buildSectionHeader('Data Lansia'),
            const SizedBox(height: 16),
            
            _buildTextField(_namaController, 'Nama Lengkap Lansia', Icons.person_outlined),
            const SizedBox(height: 16),
            
            _buildTextField(_tempatLahirController, 'Tempat Lahir', Icons.location_city_outlined),
            const SizedBox(height: 16),
            
            _buildDateField(),
            const SizedBox(height: 16),
            
            _buildTextField(_umurController, 'Umur', Icons.cake_outlined, 
              keyboardType: TextInputType.number, readOnly: true),
            const SizedBox(height: 16),
            
            _buildDropdown('Jenis Kelamin', _jenisKelamin, ['Laki-laki', 'Perempuan'], (val) {
              setState(() => _jenisKelamin = val);
            }),
            const SizedBox(height: 16),
            
            _buildTextField(_golDarahController, 'Golongan Darah', Icons.bloodtype_outlined),
            const SizedBox(height: 16),
            
            _buildExpandableTextField(_riwayatController, 'Riwayat Penyakit', Icons.medical_services_outlined),
            const SizedBox(height: 16),
            
            _buildExpandableTextField(_alergiController, 'Alergi', Icons.warning_outlined),
            const SizedBox(height: 16),

            _buildTextField(_noHpController, 'Nomor HP Anak', Icons.phone_outlined,
              keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            
            _buildExpandableTextField(_obatController, 'Obat Rutin', Icons.medication_outlined),
            const SizedBox(height: 24),

            // Data Keluarga Section (Info only - tidak bisa diubah)
            _buildSectionHeader('Data Keluarga Penanggung Jawab'),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReadOnlyField('Nama Penanggung Jawab', _userName ?? 'Belum terdeteksi'),
                  const SizedBox(height: 12),
                  _buildReadOnlyField('Email Penanggung Jawab', _userEmail ?? 'Belum terdeteksi'),
                  const SizedBox(height: 12),
                  Text(
                    '📌 Data keluarga diambil otomatis dari akun Anda',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildExpandableTextField(_alamatController, 'Alamat Tempat Tinggal Lansia', Icons.home_outlined),
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _hideForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF9C6223)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'BATAL',
                      style: TextStyle(
                        color: Color(0xFF9C6223),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C6223),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_selectedLansia != null ? Icons.edit : Icons.save_alt_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _selectedLansia != null ? 'UPDATE' : 'SIMPAN',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoadingList) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C6223)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF9C6223).withOpacity(0.1),
                  const Color(0xFF9C6223).withOpacity(0.05),
              ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF9C6223).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C6223).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.group, color: Color(0xFF9C6223), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Daftar Lansia Terhubung',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C6223),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _lansiaList.isEmpty 
                    ? 'Belum ada data lansia yang terhubung dengan akun Anda'
                    : 'Total ${_lansiaList.length} lansia terhubung',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // List of Lansia
          if (_lansiaList.isEmpty)
            _buildEmptyState()
          else
            ..._lansiaList.map((lansia) => _buildLansiaCard(lansia)).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum Ada Data Lansia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tambahkan data lansia terlebih dahulu untuk memantau kesehatan mereka',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showForm(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C6223),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 18),
                SizedBox(width: 8),
                Text('Tambah Lansia'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLansiaCard(Datalansia lansia) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C6223).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    lansia.jenisKelaminLansia == 'Laki-laki' 
                      ? Icons.male 
                      : Icons.female,
                    color: const Color(0xFF9C6223),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lansia.namaLansia ?? 'Tanpa Nama',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lansia.umurLansia ?? '-'} tahun • ${lansia.jenisKelaminLansia ?? '-'} • ${lansia.golDarahLansia ?? '-'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      if (lansia.alamatLengkap != null && lansia.alamatLengkap!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            lansia.alamatLengkap!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Additional Info
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (lansia.riwayatPenyakitLansia != null && lansia.riwayatPenyakitLansia!.isNotEmpty)
                  Chip(
                    label: Text(lansia.riwayatPenyakitLansia!),
                    backgroundColor: Colors.blue[50],
                    labelStyle: const TextStyle(fontSize: 11),
                  ),
                if (lansia.alergiLansia != null && lansia.alergiLansia!.isNotEmpty)
                  Chip(
                    label: Text(lansia.alergiLansia!),
                    backgroundColor: Colors.orange[50],
                    labelStyle: const TextStyle(fontSize: 11),
                  ),
                if (lansia.obatRutinLansia != null && lansia.obatRutinLansia!.isNotEmpty)
                  Chip(
                    label: Text(lansia.obatRutinLansia!),
                    backgroundColor: Colors.green[50],
                    labelStyle: const TextStyle(fontSize: 11),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showForm(lansia: lansia),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF9C6223)),
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _deleteLansia(lansia),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9C6223).withOpacity(0.1),
            const Color(0xFF9C6223).withOpacity(0.05),
        ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9C6223).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C6223).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _selectedLansia != null ? Icons.edit : Icons.person_add_alt_1,
                  color: const Color(0xFF9C6223),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedLansia != null ? 'Edit Data Lansia' : 'Tambah Data Lansia',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C6223),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selectedLansia != null
              ? 'Perbarui data lansia ${_selectedLansia?.namaLansia}'
              : 'Data lansia akan otomatis terhubung dengan akun Anda sebagai penanggung jawab',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFF9C6223).withOpacity(0.3), width: 2),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF9C6223),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF9C6223)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9C6223), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) => (value == null || value.isEmpty) ? '$label wajib diisi' : null,
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableTextField(
    TextEditingController controller, 
    String label, 
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      maxLines: 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF9C6223)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9C6223), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) => (value == null || value.isEmpty) ? '$label wajib diisi' : null,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.transgender, color: Color(0xFF9C6223)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9C6223), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
      items: items.map((e) => DropdownMenuItem(
        value: e,
        child: Text(e, style: const TextStyle(color: Colors.black87)),
      )).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? '$label wajib dipilih' : null,
      style: const TextStyle(color: Colors.black87),
      dropdownColor: Colors.white,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _tanggalLahirController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Tanggal Lahir',
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF9C6223)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9C6223), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          icon: const Icon(Icons.event, color: Color(0xFF9C6223)),
          onPressed: () => _selectDate(context),
        ),
      ),
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Tanggal lahir wajib diisi';
        return null;
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 60)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9C6223),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text = '${picked.day}/${picked.month}/${picked.year}';
        _calculateAge();
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _umurController.dispose();
    _golDarahController.dispose();
    _riwayatController.dispose();
    _alergiController.dispose();
    _obatController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }
}