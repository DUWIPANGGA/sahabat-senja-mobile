import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/kondisi_model.dart';
import 'package:sahabatsenja_app/halaman/services/kondisi_service.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';

class DetailLansiaScreen extends StatefulWidget {
  final Datalansia biodata;
  final String kamar;

  const DetailLansiaScreen({
    super.key,
    required this.biodata,
    required this.kamar,
  });

  @override
  State<DetailLansiaScreen> createState() => _DetailLansiaScreenState();
}

class _DetailLansiaScreenState extends State<DetailLansiaScreen> {
  final KondisiService _kondisiService = KondisiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tekananDarahController = TextEditingController();
  final TextEditingController _nadiController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  String _nafsuMakan = 'Baik';
  String _statusObat = 'Sudah';
  String _status = 'Stabil';

  @override
  void dispose() {
    _tekananDarahController.dispose();
    _nadiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lansia = widget.biodata;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail ${lansia.namaLansia}'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Info Biodata ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lansia.namaLansia,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Usia: ${lansia.umurLansia ?? "-"} tahun'),
                    Text('Kamar: ${widget.kamar}'),
                    Text('Gol. Darah: ${lansia.golDarahLansia ?? "-"}'),
                    Text('Riwayat Penyakit: ${lansia.riwayatPenyakitLansia ?? "-"}'),
                    Text('Alergi: ${lansia.alergiLansia ?? "-"}'),
                    Text('Penanggung Jawab: ${lansia.namaAnak ?? "-"}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Form Input Kondisi Harian ---
            const Text(
              'Input Kondisi Harian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                      _tekananDarahController, 'Tekanan Darah', '120/80'),
                  const SizedBox(height: 16),
                  _buildTextField(_nadiController, 'Denyut Nadi (bpm)', '72',
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildDropdown('Nafsu Makan', _nafsuMakan, [
                    'Sangat Baik',
                    'Baik',
                    'Normal',
                    'Kurang',
                    'Sangat Kurang'
                  ], (value) {
                    setState(() => _nafsuMakan = value!);
                  }),
                  const SizedBox(height: 16),
                  _buildDropdown('Status Obat', _statusObat,
                      ['Sudah', 'Belum', 'Sebagian'], (value) {
                    setState(() => _statusObat = value!);
                  }),
                  const SizedBox(height: 16),
                  _buildDropdown(
                      'Status Kondisi', _status, ['Stabil', 'Perlu Perhatian'],
                      (value) {
                    setState(() => _status = value!);
                  }),
                  const SizedBox(height: 16),
                  _buildTextField(_catatanController, 'Catatan Tambahan',
                      'Kondisi hari ini...'),
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
                      child: const Text('SIMPAN KONDISI HARIAN'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String hint, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label wajib dipilih';
        }
        return null;
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final kondisi = KondisiHarian(
          idLansia: widget.biodata.id!,
          tekananDarah: _tekananDarahController.text,
          nadi: int.tryParse(_nadiController.text) ?? 0,
          nafsuMakan: _nafsuMakan,
          statusObat: _statusObat,
          catatan: _catatanController.text,
          status: _status,
          tanggal: DateTime.now(),
        );

        final success = await _kondisiService.addKondisi(kondisi);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Kondisi harian berhasil disimpan!'),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Gagal menyimpan kondisi. Coba lagi nanti.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }
}
