import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/halaman/services/biodata_service.dart';

class BiodataLansiaScreen extends StatefulWidget {
  const BiodataLansiaScreen({super.key});

  @override
  State<BiodataLansiaScreen> createState() => _BiodataLansiaScreenState();
}

class _BiodataLansiaScreenState extends State<BiodataLansiaScreen> {
  final BiodataService _biodataService = BiodataService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _umurController = TextEditingController();
  final TextEditingController _golDarahController = TextEditingController();
  final TextEditingController _riwayatController = TextEditingController();
  final TextEditingController _alergiController = TextEditingController();
  final TextEditingController _obatController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _namaAnakController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateTime? _selectedDate;
  String? _jenisKelamin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Biodata Lansia'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Isi Biodata Lansia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField(_namaController, 'Nama Lengkap Lansia', Icons.person),
              const SizedBox(height: 16),
              _buildTextField(_tempatLahirController, 'Tempat Lahir', Icons.location_city),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildTextField(_umurController, 'Umur', Icons.cake, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildDropdown('Jenis Kelamin', _jenisKelamin, ['Laki-laki', 'Perempuan'], (val) {
                setState(() => _jenisKelamin = val);
              }),
              const SizedBox(height: 16),
              _buildTextField(_golDarahController, 'Golongan Darah', Icons.bloodtype),
              const SizedBox(height: 16),
              _buildTextField(_riwayatController, 'Riwayat Penyakit', Icons.medical_services),
              const SizedBox(height: 16),
              _buildTextField(_alergiController, 'Alergi', Icons.warning),
              const SizedBox(height: 16),
              _buildTextField(_obatController, 'Obat Rutin', Icons.medication),
              const SizedBox(height: 16),
              _buildTextField(_statusController, 'Status Lansia', Icons.health_and_safety),
              const SizedBox(height: 20),

              const Text(
                'Data Keluarga Penanggung Jawab',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(_namaAnakController, 'Nama Anak / Penanggung Jawab', Icons.people),
              const SizedBox(height: 16),
              _buildTextField(_alamatController, 'Alamat Lengkap', Icons.home),
              const SizedBox(height: 16),
              _buildTextField(_noHpController, 'Nomor HP Anak', Icons.phone),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Email Anak', Icons.email),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C6223),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('SIMPAN BIODATA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) => (value == null || value.isEmpty) ? '$label wajib diisi' : null,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? '$label wajib dipilih' : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _tanggalLahirController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Tanggal Lahir',
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
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
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      try {
        final data = Datalansia(
          namaLansia: _namaController.text,
          tanggalLahirLansia: (_selectedDate ?? DateTime.now()).toIso8601String(),
          tempatLahirLansia: _tempatLahirController.text,
          umurLansia: int.tryParse(_umurController.text),
          jenisKelaminLansia: _jenisKelamin,
          golDarahLansia: _golDarahController.text,
          riwayatPenyakitLansia: _riwayatController.text,
          alergiLansia: _alergiController.text,
          obatRutinLansia: _obatController.text,
          statusLansia: _statusController.text,
          namaAnak: _namaAnakController.text,
          alamatLengkap: _alamatController.text,
          noHpAnak: _noHpController.text,
          emailAnak: _emailController.text,
        );

        final success = await _biodataService.createDataLansia(data);

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Biodata lansia berhasil disimpan!')),
            );
            Navigator.pop(context, true);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Gagal menyimpan biodata.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Terjadi kesalahan: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua data dengan benar.')),
      );
    }
  }

}
