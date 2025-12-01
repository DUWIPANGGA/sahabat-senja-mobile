import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/kondisi_model.dart';
import 'package:sahabatsenja_app/services/kondisi_service.dart';
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
  bool _isSubmitting = false;

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
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          child: Icon(
                            Icons.person,
                            color: Colors.orange[800],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lansia.namaLansia,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Umur', '${lansia.umurLansia ?? "-"} tahun'),
                    _buildInfoRow('Kamar', widget.kamar),
                    _buildInfoRow('Gol. Darah', lansia.golDarahLansia ?? "-"),
                    if (lansia.riwayatPenyakitLansia != null && lansia.riwayatPenyakitLansia!.isNotEmpty)
                      _buildInfoRow('Riwayat Penyakit', lansia.riwayatPenyakitLansia!),
                    if (lansia.alergiLansia != null && lansia.alergiLansia!.isNotEmpty)
                      _buildInfoRow('Alergi', lansia.alergiLansia!),
                    _buildInfoRow('Penanggung Jawab', lansia.namaAnak ?? "-"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Form Input Kondisi Harian ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.health_and_safety, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Input Kondisi Harian',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tanggal: ${_formatDate(DateTime.now())}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _tekananDarahController,
                            label: 'Tekanan Darah',
                            hint: 'Contoh: 120/80',
                            icon: Icons.monitor_heart,
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _nadiController,
                            label: 'Denyut Nadi (bpm)',
                            hint: 'Contoh: 72',
                            icon: Icons.favorite,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Nafsu Makan',
                            value: _nafsuMakan,
                            items: ['Sangat Baik', 'Baik', 'Normal', 'Kurang', 'Sangat Kurang'],
                            icon: Icons.restaurant,
                            onChanged: (value) {
                              setState(() => _nafsuMakan = value!);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Status Obat',
                            value: _statusObat,
                            items: ['Sudah', 'Belum', 'Sebagian'],
                            icon: Icons.medication,
                            onChanged: (value) {
                              setState(() => _statusObat = value!);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Status Kondisi',
                            value: _status,
                            items: ['Stabil', 'Perlu Perhatian'],
                            icon: Icons.assessment,
                            onChanged: (value) {
                              setState(() => _status = value!);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _catatanController,
                            label: 'Catatan Tambahan',
                            hint: 'Contoh: Kondisi hari ini membaik...',
                            icon: Icons.note,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: _isSubmitting
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton.icon(
                                    onPressed: _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9C6223),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.save),
                                    label: const Text(
                                      'SIMPAN KONDISI HARIAN',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label wajib diisi';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Validasi data sebelum dikirim
      if (widget.biodata.namaLansia == null || widget.biodata.namaLansia!.isEmpty) {
        throw Exception('Nama lansia tidak valid');
      }

      // Format tanggal ke ISO string
      final now = DateTime.now();
      final isoDate = now.toIso8601String().split('.').first; // Format: YYYY-MM-DDTHH:MM:SS

      // Buat objek kondisi
      final kondisi = KondisiHarian(
        namaLansia: widget.biodata.namaLansia!, // Pastikan tidak null
        tanggal: now,
        tekananDarah: _tekananDarahController.text.trim(),
        nadi: _nadiController.text.trim(),
        nafsuMakan: _nafsuMakan,
        statusObat: _statusObat,
        catatan: _catatanController.text.trim(),
        status: _status,
        datalansiaId: widget.biodata.id,
      );

      debugPrint('📤 Mengirim kondisi ke API...');
      debugPrint('Nama Lansia: ${kondisi.namaLansia}');
      debugPrint('Tanggal: ${kondisi.tanggal}');
      debugPrint('Data JSON: ${kondisi.toJson()}');

      final success = await _kondisiService.addKondisi(kondisi);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('✅ Kondisi harian berhasil disimpan!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Tunggu sebentar sebelum kembali
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          Navigator.pop(context, true); // Kembali dengan refresh flag
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('❌ Gagal menyimpan kondisi. Coba lagi nanti.'),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error submit form: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}