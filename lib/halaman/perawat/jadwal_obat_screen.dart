import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/services/jadwal_obat_service.dart';
import 'package:sahabatsenja_app/models/jadwal_obat_model.dart';
import 'package:intl/intl.dart';

class JadwalObatScreen extends StatefulWidget {
  final int datalansiaId;
  final String namaLansia;

  const JadwalObatScreen({
    super.key, 
    required this.datalansiaId,
    required this.namaLansia,
  });

  @override
  State<JadwalObatScreen> createState() => _JadwalObatScreenState();
}

class _JadwalObatScreenState extends State<JadwalObatScreen> {
  final JadwalObatService _service = JadwalObatService();
  List<JadwalObat> _jadwalObat = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Filter
  String _filterWaktu = 'Semua';
  bool _showSelesai = false;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaObatController = TextEditingController();
  final TextEditingController _dosisController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  String? _waktuSelected = 'Pagi';
  String? _frekuensiSelected = 'Setiap Hari';
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  String? _jamMinumController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final data = await _service.getByLansia(widget.datalansiaId);
      setState(() => _jadwalObat = data);
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat data: $e');
      _showSnackbar('Gagal memuat data obat', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<JadwalObat> get _filteredList {
    return _jadwalObat.where((item) {
      // Filter berdasarkan waktu
      if (_filterWaktu != 'Semua' && item.waktu != _filterWaktu) {
        return false;
      }
      
      // Filter berdasarkan status selesai
      if (!_showSelesai && item.selesai) {
        return false;
      }
      
      return true;
    }).toList();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _tambahObat() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalMulai == null) {
      _showSnackbar('Harap pilih tanggal mulai', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final jadwalObat = JadwalObat(
        datalansiaId: widget.datalansiaId,
        namaObat: _namaObatController.text,
        dosis: _dosisController.text,
        waktu: _waktuSelected!,
        frekuensi: _frekuensiSelected!,
        tanggalMulai: _tanggalMulai!,
        tanggalSelesai: _tanggalSelesai,
        deskripsi: _deskripsiController.text.isNotEmpty ? _deskripsiController.text : null,
        catatan: _catatanController.text.isNotEmpty ? _catatanController.text : null,
        jamMinum: _jamMinumController,
      );

      final success = await _service.createJadwalObat(jadwalObat);
      
      if (success) {
        Navigator.pop(context);
        _resetForm();
        _loadData();
        _showSnackbar('Jadwal obat berhasil ditambahkan');
      } else {
        _showSnackbar('Gagal menambah jadwal obat', isError: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _namaObatController.clear();
    _dosisController.clear();
    _deskripsiController.clear();
    _catatanController.clear();
    _waktuSelected = 'Pagi';
    _frekuensiSelected = 'Setiap Hari';
    _tanggalMulai = null;
    _tanggalSelesai = null;
    _jamMinumController = null;
  }

  Future<void> _updateStatus(int id, bool selesai) async {
    try {
      final success = await _service.updateStatus(id, selesai);
      if (success) {
        _loadData();
        _showSnackbar('Status berhasil diupdate');
      } else {
        _showSnackbar('Gagal update status', isError: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    }
  }

  Future<void> _deleteObat(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal Obat'),
        content: const Text('Apakah Anda yakin ingin menghapus jadwal obat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final success = await _service.deleteJadwalObat(id);
        if (success) {
          _loadData();
          _showSnackbar('Jadwal obat berhasil dihapus');
        } else {
          _showSnackbar('Gagal menghapus jadwal obat', isError: true);
        }
      } catch (e) {
        _showSnackbar('Error: $e', isError: true);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateJamMinum(int id, String jam) async {
    try {
      final success = await _service.updateJamMinum(id, jam);
      if (success) {
        _loadData();
        _showSnackbar('Jam minum berhasil diupdate');
      } else {
        _showSnackbar('Gagal update jam minum', isError: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    }
  }

  void _showEditDialog(JadwalObat jadwalObat) {
    _namaObatController.text = jadwalObat.namaObat;
    _dosisController.text = jadwalObat.dosis;
    _deskripsiController.text = jadwalObat.deskripsi ?? '';
    _catatanController.text = jadwalObat.catatan ?? '';
    _waktuSelected = jadwalObat.waktu;
    _frekuensiSelected = jadwalObat.frekuensi;
    _tanggalMulai = jadwalObat.tanggalMulai;
    _tanggalSelesai = jadwalObat.tanggalSelesai;
    _jamMinumController = jadwalObat.jamMinum;

    showDialog(
      context: context,
      builder: (context) => _buildObatDialog(
        title: 'Edit Jadwal Obat',
        onSave: () async {
          if (!_formKey.currentState!.validate()) return;
          
          final updatedObat = jadwalObat.copyWith(
            namaObat: _namaObatController.text,
            dosis: _dosisController.text,
            deskripsi: _deskripsiController.text.isNotEmpty ? _deskripsiController.text : null,
            catatan: _catatanController.text.isNotEmpty ? _catatanController.text : null,
            waktu: _waktuSelected!,
            frekuensi: _frekuensiSelected!,
            tanggalMulai: _tanggalMulai!,
            tanggalSelesai: _tanggalSelesai,
            jamMinum: _jamMinumController,
          );

          setState(() => _isSubmitting = true);
          try {
            final success = await _service.updateJadwalObat(updatedObat);
            if (success) {
              Navigator.pop(context);
              _resetForm();
              _loadData();
              _showSnackbar('Jadwal obat berhasil diperbarui');
            } else {
              _showSnackbar('Gagal memperbarui jadwal obat', isError: true);
            }
          } catch (e) {
            _showSnackbar('Error: $e', isError: true);
          } finally {
            setState(() => _isSubmitting = false);
          }
        },
      ),
    );
  }

  Widget _buildObatDialog({required String title, required VoidCallback onSave}) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _namaObatController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Obat*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama obat wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dosisController,
                    decoration: const InputDecoration(
                      labelText: 'Dosis*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Dosis wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _deskripsiController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi (opsional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _waktuSelected,
                    decoration: const InputDecoration(
                      labelText: 'Waktu Minum*',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Pagi', child: Text('Pagi')),
                      DropdownMenuItem(value: 'Siang', child: Text('Siang')),
                      DropdownMenuItem(value: 'Sore', child: Text('Sore')),
                      DropdownMenuItem(value: 'Malam', child: Text('Malam')),
                      DropdownMenuItem(value: 'Sesuai Kebutuhan', child: Text('Sesuai Kebutuhan')),
                    ],
                    onChanged: (value) => setState(() => _waktuSelected = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Waktu minum wajib dipilih';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _frekuensiSelected,
                    decoration: const InputDecoration(
                      labelText: 'Frekuensi*',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Setiap Hari', child: Text('Setiap Hari')),
                      DropdownMenuItem(value: 'Setiap 2 Hari', child: Text('Setiap 2 Hari')),
                      DropdownMenuItem(value: 'Mingguan', child: Text('Mingguan')),
                      DropdownMenuItem(value: 'Bulanan', child: Text('Bulanan')),
                      DropdownMenuItem(value: 'Sesuai Kebutuhan', child: Text('Sesuai Kebutuhan')),
                    ],
                    onChanged: (value) => setState(() => _frekuensiSelected = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Frekuensi wajib dipilih';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: TextEditingController(
                      text: _jamMinumController ?? '00:00',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Jam Minum (HH:mm)',
                      hintText: 'Contoh: 08:00',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _jamMinumController = value,
                  ),
                  const SizedBox(height: 12),
                  // Tanggal Mulai
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _tanggalMulai != null
                          ? 'Mulai: ${DateFormat('dd/MM/yyyy').format(_tanggalMulai!)}'
                          : 'Pilih Tanggal Mulai*',
                    ),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _tanggalMulai = picked);
                      }
                    },
                  ),
                  // Tanggal Selesai (opsional)
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _tanggalSelesai != null
                          ? 'Selesai: ${DateFormat('dd/MM/yyyy').format(_tanggalSelesai!)}'
                          : 'Pilih Tanggal Selesai (opsional)',
                    ),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _tanggalMulai ?? DateTime.now(),
                        firstDate: _tanggalMulai ?? DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _tanggalSelesai = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _catatanController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6223),
              ),
              onPressed: _isSubmitting ? null : onSave,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDetail(JadwalObat obat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    obat.namaObat,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditDialog(obat);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailItem('💊 Dosis', obat.dosis),
            _buildDetailItem('⏰ Waktu', obat.waktu),
            _buildDetailItem('📅 Frekuensi', obat.frekuensi),
            if (obat.jamMinum != null) _buildDetailItem('🕐 Jam Minum', obat.jamMinum!),
            _buildDetailItem('📅 Tanggal Mulai', DateFormat('dd/MM/yyyy').format(obat.tanggalMulai)),
            if (obat.tanggalSelesai != null)
              _buildDetailItem('📅 Tanggal Selesai', DateFormat('dd/MM/yyyy').format(obat.tanggalSelesai!)),
            if (obat.deskripsi != null && obat.deskripsi!.isNotEmpty)
              _buildDetailItem('📝 Deskripsi', obat.deskripsi!),
            if (obat.catatan != null && obat.catatan!.isNotEmpty)
              _buildDetailItem('🗒️ Catatan', obat.catatan!),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: obat.selesai ? Colors.grey : Colors.blue,
                    ),
                    onPressed: () => _updateStatus(obat.id!, !obat.selesai),
                    child: Text(
                      obat.selesai ? 'Tandai Belum Selesai' : 'Tandai Selesai',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteObat(obat.id!);
                    },
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Obat - ${widget.namaLansia}'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9C6223),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => _buildObatDialog(
            title: 'Tambah Jadwal Obat',
            onSave: _tambahObat,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _filterWaktu,
                        decoration: const InputDecoration(
                          labelText: 'Filter Waktu',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                          DropdownMenuItem(value: 'Pagi', child: Text('Pagi')),
                          DropdownMenuItem(value: 'Siang', child: Text('Siang')),
                          DropdownMenuItem(value: 'Sore', child: Text('Sore')),
                          DropdownMenuItem(value: 'Malam', child: Text('Malam')),
                        ],
                        onChanged: (value) {
                          setState(() => _filterWaktu = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('Selesai'),
                      selected: _showSelesai,
                      onSelected: (selected) {
                        setState(() => _showSelesai = selected);
                      },
                      selectedColor: Colors.green[100],
                      checkmarkColor: Colors.green[700],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${_filteredList.length} jadwal obat',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Data list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.medication,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Belum ada jadwal obat',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.namaLansia,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredList.length,
                              itemBuilder: (context, index) {
                                final item = _filteredList[index];
                                return _buildObatCard(item);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildObatCard(JadwalObat item) {
    final isAktif = !item.selesai && 
        (item.tanggalSelesai == null || 
         item.tanggalSelesai!.isAfter(DateTime.now()));
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetail(item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 8,
                height: 60,
                decoration: BoxDecoration(
                  color: item.selesai 
                      ? Colors.grey 
                      : isAktif 
                          ? Colors.green 
                          : Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.namaObat,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: item.selesai 
                                  ? TextDecoration.lineThrough 
                                  : null,
                              color: item.selesai ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.selesai 
                                ? Colors.grey 
                                : isAktif 
                                    ? Colors.green[100] 
                                    : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.selesai ? 'Selesai' : isAktif ? 'Aktif' : 'Belum Dimulai',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item.selesai 
                                  ? Colors.grey[700] 
                                  : isAktif 
                                      ? Colors.green[700] 
                                      : Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.dosis}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.waktu} • ${item.frekuensi}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(item.tanggalMulai)}${item.tanggalSelesai != null ? ' - ${DateFormat('dd/MM/yyyy').format(item.tanggalSelesai!)}' : ''}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Checkbox(
                    value: item.selesai,
                    onChanged: (value) => _updateStatus(item.id!, value!),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: () => _deleteObat(item.id!),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}