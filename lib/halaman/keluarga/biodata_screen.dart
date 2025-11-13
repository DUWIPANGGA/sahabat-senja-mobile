import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import '../services/datalansia_service.dart';

class BiodataLansiaScreen extends StatefulWidget {
  const BiodataLansiaScreen({super.key});

  @override
  State<BiodataLansiaScreen> createState() => _BiodataLansiaScreenState();
}

class _BiodataLansiaScreenState extends State<BiodataLansiaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _umurController = TextEditingController();
  final TextEditingController _golDarahController = TextEditingController();
  final TextEditingController _riwayatController = TextEditingController();
  final TextEditingController _alergiController = TextEditingController();
  final TextEditingController _obatController = TextEditingController();
  final TextEditingController _namaAnakController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateTime? _selectedDate;
  String? _jenisKelamin;

  void _calculateAge() {
    if (_selectedDate != null) {
      final now = DateTime.now();
      final age = now.year - _selectedDate!.year;
      // Adjust if birthday hasn't occurred this year yet
      final hasBirthdayPassed = now.month > _selectedDate!.month || 
          (now.month == _selectedDate!.month && now.day >= _selectedDate!.day);
      final calculatedAge = hasBirthdayPassed ? age : age - 1;
      
      _umurController.text = calculatedAge.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Biodata Lansia'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFFFF9F5),
        child: SingleChildScrollView(
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
                
                // Field dengan tinggi sama tapi bisa expand ketika diklik
                _buildExpandableTextField(_riwayatController, 'Riwayat Penyakit', Icons.medical_services_outlined),
                const SizedBox(height: 16),
                
                _buildExpandableTextField(_alergiController, 'Alergi', Icons.warning_outlined),
                const SizedBox(height: 16),
                
                _buildExpandableTextField(_obatController, 'Obat Rutin', Icons.medication_outlined),
                const SizedBox(height: 24),

                // Data Keluarga Section
                _buildSectionHeader('Data Keluarga Penanggung Jawab'),
                const SizedBox(height: 16),
                
                _buildTextField(_namaAnakController, 'Nama Anak / Penanggung Jawab', Icons.people_outlined),
                const SizedBox(height: 16),
                
                _buildExpandableTextField(_alamatController, 'Alamat Lengkap', Icons.home_outlined),
                const SizedBox(height: 16),
                
                _buildTextField(_noHpController, 'Nomor HP Anak', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                
                _buildTextField(_emailController, 'Email Anak', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 30),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
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
                child: const Icon(Icons.person_add_alt_1, color: Color(0xFF9C6223), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Isi Biodata Lansia',
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
          const Text(
            'Lengkapi data lansia dengan informasi yang akurat untuk pemantauan kesehatan yang lebih baik',
            style: TextStyle(
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

  // Widget khusus untuk field yang butuh multiple lines tapi tetap konsisten tinggi awalnya
  Widget _buildExpandableTextField(
    TextEditingController controller, 
    String label, 
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      maxLines: 1, // Awalnya 1 line, akan expand ketika diklik
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
      onTap: () {
        // Ketika field diklik, biarkan user mengetik multiple lines
        setState(() {
          // Tidak perlu set maxLines di sini, biarkan naturally expand
        });
      },
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9C6223),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_alt_outlined, size: 20),
            SizedBox(width: 8),
            Text(
              'SIMPAN BIODATA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      try {
        final datalansia = Datalansia(
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
          namaAnak: _namaAnakController.text,
          alamatLengkap: _alamatController.text,
          noHpAnak: _noHpController.text,
          emailAnak: _emailController.text,
        );

        final created = await DatalansiaService.createDatalansia(datalansia);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Biodata ${created.namaLansia} berhasil disimpan!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap isi semua data dengan benar.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}