import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/services/jadwal_obat_service.dart';
import 'package:sahabatsenja_app/models/jadwal_obat_model.dart';
import 'package:intl/intl.dart';

class ManageJadwalObatScreen extends StatefulWidget {
  final int datalansiaId;
  final String namaLansia;

  const ManageJadwalObatScreen({
    super.key, 
    required this.datalansiaId,
    required this.namaLansia,
  });

  @override
  State<ManageJadwalObatScreen> createState() => _ManageJadwalObatScreenState();
}

class _ManageJadwalObatScreenState extends State<ManageJadwalObatScreen> {
  final JadwalObatService _service = JadwalObatService();
  List<JadwalObat> _jadwalObat = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Filter
  String _filterWaktu = 'Semua';
  String _filterStatus = 'Semua';
  String _searchQuery = '';
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaObatController = TextEditingController();
  final TextEditingController _dosisController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _jamMinumController = TextEditingController();
  String? _waktuSelected = 'Pagi';
  String? _frekuensiSelected = 'Setiap Hari';
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  bool _isSubmitting = false;
  bool _isEditMode = false;
  int? _editingId;

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
      
      // Filter berdasarkan status
      if (_filterStatus == 'Aktif' && item.selesai) {
        return false;
      }
      if (_filterStatus == 'Selesai' && !item.selesai) {
        return false;
      }
      
      // Filter berdasarkan pencarian
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!item.namaObat.toLowerCase().contains(query) &&
            !item.dosis.toLowerCase().contains(query) &&
            !(item.catatan?.toLowerCase() ?? '').contains(query)) {
          return false;
        }
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

  void _resetForm() {
    _namaObatController.clear();
    _dosisController.clear();
    _deskripsiController.clear();
    _catatanController.clear();
    _jamMinumController.clear();
    _waktuSelected = 'Pagi';
    _frekuensiSelected = 'Setiap Hari';
    _tanggalMulai = null;
    _tanggalSelesai = null;
    _isEditMode = false;
    _editingId = null;
    _formKey.currentState?.reset();
  }

  void _showAddEditDialog({JadwalObat? obat}) {
    if (obat != null) {
      _isEditMode = true;
      _editingId = obat.id;
      _namaObatController.text = obat.namaObat;
      _dosisController.text = obat.dosis;
      _deskripsiController.text = obat.deskripsi ?? '';
      _catatanController.text = obat.catatan ?? '';
      _jamMinumController.text = obat.jamMinum ?? '';
      _waktuSelected = obat.waktu;
      _frekuensiSelected = obat.frekuensi ?? 'Setiap Hari';
      _tanggalMulai = obat.tanggalMulai;
      _tanggalSelesai = obat.tanggalSelesai;
    } else {
      _resetForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildObatForm(obat: obat),
    );
  }

  Future<void> _saveObat() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalMulai == null) {
      _showSnackbar('Harap pilih tanggal mulai', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final jadwalObat = JadwalObat(
        id: _editingId,
        datalansiaId: widget.datalansiaId,
        namaObat: _namaObatController.text,
        dosis: _dosisController.text,
        waktu: _waktuSelected!,
        frekuensi: _frekuensiSelected!,
        tanggalMulai: _tanggalMulai!,
        tanggalSelesai: _tanggalSelesai,
        deskripsi: _deskripsiController.text.isNotEmpty ? _deskripsiController.text : null,
        catatan: _catatanController.text.isNotEmpty ? _catatanController.text : null,
        jamMinum: _jamMinumController.text.isNotEmpty ? _jamMinumController.text : null,
        selesai: false,
      );

      bool success;
      if (_isEditMode) {
        success = await _service.updateJadwalObat(jadwalObat);
      } else {
        success = await _service.createJadwalObat(jadwalObat);
      }
      
      if (success) {
        Navigator.pop(context);
        _resetForm();
        _loadData();
        _showSnackbar('Jadwal obat berhasil ${_isEditMode ? 'diperbarui' : 'ditambahkan'}');
      } else {
        _showSnackbar('Gagal menyimpan jadwal obat', isError: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _toggleStatus(int id, bool currentStatus) async {
    try {
      final success = await _service.updateStatus(id, !currentStatus);
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
      }
    }
  }

  Widget _buildObatForm({JadwalObat? obat}) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C6223),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isEditMode ? 'Edit Jadwal Obat' : 'Tambah Jadwal Obat',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _namaObatController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Obat*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medication),
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
                        hintText: 'Contoh: 1 tablet, 5ml',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.precision_manufacturing),
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
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _waktuSelected,
                      decoration: const InputDecoration(
                        labelText: 'Waktu Minum*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Pagi', child: Text('Pagi (06:00 - 10:00)')),
                        DropdownMenuItem(value: 'Siang', child: Text('Siang (11:00 - 14:00)')),
                        DropdownMenuItem(value: 'Sore', child: Text('Sore (15:00 - 18:00)')),
                        DropdownMenuItem(value: 'Malam', child: Text('Malam (19:00 - 22:00)')),
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
                    TextFormField(
                      controller: _jamMinumController,
                      decoration: const InputDecoration(
                        labelText: 'Jam Minum (HH:mm)',
                        hintText: 'Contoh: 08:00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _frekuensiSelected,
                      decoration: const InputDecoration(
                        labelText: 'Frekuensi*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.repeat),
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
                    // Tanggal Mulai
                    InkWell(
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
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: _tanggalMulai == null ? Colors.grey : const Color(0xFF9C6223),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _tanggalMulai != null
                                    ? 'Mulai: ${DateFormat('dd/MM/yyyy').format(_tanggalMulai!)}'
                                    : 'Pilih Tanggal Mulai*',
                                style: TextStyle(
                                  color: _tanggalMulai == null ? Colors.grey : Colors.black,
                                ),
                              ),
                            ),
                            if (_tanggalMulai != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () => setState(() => _tanggalMulai = null),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tanggal Selesai (opsional)
                    InkWell(
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
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: _tanggalSelesai == null ? Colors.grey : const Color(0xFF9C6223),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _tanggalSelesai != null
                                    ? 'Selesai: ${DateFormat('dd/MM/yyyy').format(_tanggalSelesai!)}'
                                    : 'Pilih Tanggal Selesai (opsional)',
                                style: TextStyle(
                                  color: _tanggalSelesai == null ? Colors.grey : Colors.black,
                                ),
                              ),
                            ),
                            if (_tanggalSelesai != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () => setState(() => _tanggalSelesai = null),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _catatanController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6223),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isSubmitting ? null : _saveObat,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      _isEditMode ? 'Update Jadwal Obat' : 'Simpan Jadwal Obat',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Cari nama obat atau dosis...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF9C6223)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),
          
          // Filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Filter waktu
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Semua'),
                    selected: _filterWaktu == 'Semua',
                    onSelected: (selected) => setState(() => _filterWaktu = 'Semua'),
                  ),
                  FilterChip(
                    label: const Text('Pagi'),
                    selected: _filterWaktu == 'Pagi',
                    onSelected: (selected) => setState(() => _filterWaktu = 'Pagi'),
                    selectedColor: Colors.blue[100],
                  ),
                  FilterChip(
                    label: const Text('Siang'),
                    selected: _filterWaktu == 'Siang',
                    onSelected: (selected) => setState(() => _filterWaktu = 'Siang'),
                    selectedColor: Colors.green[100],
                  ),
                  FilterChip(
                    label: const Text('Sore'),
                    selected: _filterWaktu == 'Sore',
                    onSelected: (selected) => setState(() => _filterWaktu = 'Sore'),
                    selectedColor: Colors.orange[100],
                  ),
                  FilterChip(
                    label: const Text('Malam'),
                    selected: _filterWaktu == 'Malam',
                    onSelected: (selected) => setState(() => _filterWaktu = 'Malam'),
                    selectedColor: Colors.purple[100],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Filter status
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Semua Status'),
                    selected: _filterStatus == 'Semua',
                    onSelected: (selected) => setState(() => _filterStatus = 'Semua'),
                  ),
                  FilterChip(
                    label: const Text('Aktif'),
                    selected: _filterStatus == 'Aktif',
                    onSelected: (selected) => setState(() => _filterStatus = 'Aktif'),
                    selectedColor: Colors.green[100],
                    checkmarkColor: Colors.green,
                  ),
                  FilterChip(
                    label: const Text('Selesai'),
                    selected: _filterStatus == 'Selesai',
                    onSelected: (selected) => setState(() => _filterStatus = 'Selesai'),
                    selectedColor: Colors.grey[300],
                    checkmarkColor: Colors.grey[700],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_liquid,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6223),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Jadwal Obat'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6223),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObatCard(JadwalObat obat) {
    final isAktif = !obat.selesai && 
        (obat.tanggalSelesai == null || 
         obat.tanggalSelesai!.isAfter(DateTime.now()));
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showAddEditDialog(obat: obat),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 8,
                height: 60,
                decoration: BoxDecoration(
                  color: obat.selesai 
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
                            obat.namaObat,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: obat.selesai 
                                  ? TextDecoration.lineThrough 
                                  : null,
                              color: obat.selesai ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: obat.selesai 
                                ? Colors.grey 
                                : isAktif 
                                    ? Colors.green[100] 
                                    : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            obat.selesai ? 'Selesai' : isAktif ? 'Aktif' : 'Belum Dimulai',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: obat.selesai 
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
                      '${obat.dosis}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${obat.waktu}${obat.jamMinum != null ? ' (${obat.jamMinum})' : ''} • ${obat.frekuensi ?? "Setiap Hari"}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(obat.tanggalMulai)}${obat.tanggalSelesai != null ? ' - ${DateFormat('dd/MM/yyyy').format(obat.tanggalSelesai!)}' : ''}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showAddEditDialog(obat: obat);
                  } else if (value == 'toggle') {
                    _toggleStatus(obat.id!, obat.selesai);
                  } else if (value == 'delete') {
                    _deleteObat(obat.id!);
                  } else if (value == 'jam') {
                    _showJamMinumDialog(obat);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: const [
                        Icon(Icons.edit, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'jam',
                    child: Row(
                      children: const [
                        Icon(Icons.schedule, size: 16, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Ubah Jam'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          obat.selesai ? Icons.refresh : Icons.check,
                          size: 16,
                          color: obat.selesai ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(obat.selesai ? 'Aktifkan' : 'Tandai Selesai'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: const [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJamMinumDialog(JadwalObat obat) {
    final controller = TextEditingController(text: obat.jamMinum ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Jam Minum'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Jam Minum (HH:mm)',
            hintText: 'Contoh: 08:00',
          ),
          keyboardType: TextInputType.datetime,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C6223),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _updateJamMinum(obat.id!, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Jadwal Obat - ${widget.namaLansia}'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Tambah Jadwal Obat',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF9C6223).withOpacity(0.1),
                  const Color(0xFF9C6223).withOpacity(0.05),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C6223).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF9C6223).withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Color(0xFF9C6223),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.namaLansia,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_jadwalObat.length} jadwal obat • ${_jadwalObat.where((o) => !o.selesai).length} aktif',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _buildFilterSection(),
          
          // List header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Jadwal Obat (${_filteredList.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5D4037),
                  ),
                ),
                if (_filteredList.isNotEmpty)
                  Text(
                    '${_filteredList.where((o) => !o.selesai).length} aktif',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                    ),
                  ),
              ],
            ),
          ),

          // Data list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF9C6223)))
                : _errorMessage.isNotEmpty
                    ? _buildErrorState()
                    : _jadwalObat.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: _filteredList.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 60,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Tidak ditemukan jadwal obat',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (_searchQuery.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              'Kata kunci: "$_searchQuery"',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 20),
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
}