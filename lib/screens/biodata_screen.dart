import 'package:flutter/material.dart';

class BiodataScreen extends StatefulWidget {
  const BiodataScreen({super.key});

  @override
  State<BiodataScreen> createState() => _BiodataScreenState();
}

class _BiodataScreenState extends State<BiodataScreen> {
  int _currentStep = 0;

  // Controllers untuk semua input field
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _umurController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _golonganDarahController = TextEditingController();

  final TextEditingController _riwayatKesehatanController = TextEditingController();
  final TextEditingController _alergiController = TextEditingController();
  final TextEditingController _penyakitController = TextEditingController();
  final TextEditingController _obatController = TextEditingController();

  final TextEditingController _namaAnakController = TextEditingController();
  final TextEditingController _noTelpAnakController = TextEditingController();
  final TextEditingController _alamatAnakController = TextEditingController();
  final TextEditingController _hubunganController = TextEditingController();

  String? _jenisKelamin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text('Biodata Lansia', style: TextStyle(color: Colors.white)),
      ),
      body: Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Colors.brown, // Warna untuk stepper
          ),
        ),
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepCancel: _prevStep,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  if (_currentStep != 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.brown,
                          side: const BorderSide(color: Colors.brown),
                        ),
                        child: const Text('Kembali'),
                      ),
                    ),
                  if (_currentStep != 0) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_currentStep == 2 ? 'Simpan Data' : 'Lanjut'),
                    ),
                  ),
                ],
              ),
            );
          },
          steps: [
            // STEP 1
            Step(
              title: const Text('Data Pribadi'),
              isActive: _currentStep >= 0,
              content: Column(
                children: [
                  _buildTextField(_namaController, 'Nama Lengkap'),
                  _buildTextField(_tempatLahirController, 'Tempat Lahir'),
                  _buildTextField(_tanggalLahirController, 'Tanggal Lahir'),
                  _buildTextField(_umurController, 'Umur'),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                    value: _jenisKelamin,
                    items: const [
                      DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                    ],
                    onChanged: (value) => setState(() => _jenisKelamin = value),
                  ),
                  _buildTextField(_golonganDarahController, 'Golongan Darah'),
                  _buildTextField(_alamatController, 'Alamat'),
                ],
              ),
            ),

            // STEP 2
            Step(
              title: const Text('Kesehatan'),
              isActive: _currentStep >= 1,
              content: Column(
                children: [
                  _buildTextField(_riwayatKesehatanController, 'Riwayat Kesehatan'),
                  _buildTextField(_alergiController, 'Alergi (jika ada)'),
                  _buildTextField(_penyakitController, 'Penyakit Kronis'),
                  _buildTextField(_obatController, 'Obat Rutin yang Dikonsumsi'),
                ],
              ),
            ),

            // STEP 3
            Step(
              title: const Text('Keluarga'),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                  _buildTextField(_namaAnakController, 'Nama Anak'),
                  _buildTextField(_noTelpAnakController, 'Nomor Telepon Anak'),
                  _buildTextField(_alamatAnakController, 'Alamat Anak'),
                  _buildTextField(_hubunganController, 'Hubungan dengan Lansia'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
    } else {
      // Di step terakhir, tombol "Simpan Data" diklik
      _showSubmitDialog(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  void _showSubmitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah semua data sudah benar dan ingin disimpan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog konfirmasi
              _showSuccessDialog(context); // Tampilkan dialog sukses
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            child: const Text('Ya, Simpan'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User harus klik tombol
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Berhasil!'),
          ],
        ),
        content: const Text('Data biodata lansia berhasil disimpan.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog sukses
              Navigator.pop(context); // Kembali ke home screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            child: const Text('Kembali ke Home', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}