import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sahabatsenja_app/services/jadwal_service.dart';
import 'package:sahabatsenja_app/models/jadwal_aktivitas_model.dart';

class JadwalPerawatScreen extends StatefulWidget {
  const JadwalPerawatScreen({super.key});

  @override
  State<JadwalPerawatScreen> createState() => _JadwalPerawatScreenState();
}

class _JadwalPerawatScreenState extends State<JadwalPerawatScreen> {
  List<JadwalAktivitas> _list = [];
  bool _loading = true;
  final JadwalService _service = JadwalService();
  
  // Filter states
  bool _showCompleted = true;
  bool _showPending = true;
  String? _selectedHari;

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchJadwal();
      setState(() => _list = data);
    } catch (e) {
      print('⚠️ Error: $e');
      _showErrorSnackbar('Gagal memuat jadwal');
    } finally {
      setState(() => _loading = false);
    }
  }

  List<JadwalAktivitas> get _filteredList {
    return _list.where((jadwal) {
      // Filter berdasarkan status completed
      if (!_showCompleted && jadwal.completed) return false;
      if (!_showPending && !jadwal.completed) return false;
      
      // Filter berdasarkan hari
      if (_selectedHari != null && jadwal.hari != _selectedHari) return false;
      
      return true;
    }).toList();
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jadwal Aktivitas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown[50]!,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: _loading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Memuat jadwal...',
                      style: TextStyle(
                        color: Colors.brown,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadJadwal,
                color: Colors.brown[700],
                child: _filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(60),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.brown.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                size: 60,
                                color: Colors.brown[300],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Belum ada aktivitas',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[700],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap + untuk menambah aktivitas baru',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.brown[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredList.length,
                        itemBuilder: (context, index) {
                          final a = _filteredList[index];
                          return _buildActivityCard(a, index);
                        },
                      ),
              ),
      ),
      floatingActionButton: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: _loading ? 0 : 1,
        child: FloatingActionButton(
          onPressed: _showTambahDialog,
          child: const Icon(Icons.add, size: 28),
          backgroundColor: Colors.brown[700],
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(JadwalAktivitas a, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: a.completed
                  ? [Colors.green[50]!, Colors.green[100]!]
                  : [Colors.white, Colors.orange[50]!],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showDetail(a),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Status Indicator
                    Container(
                      width: 4,
                      height: 60,
                      decoration: BoxDecoration(
                        color: a.completed ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Time Box
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: a.completed ? Colors.green : Colors.brown[700],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (a.completed ? Colors.green : Colors.brown)!.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatJam(a.jam),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.hari?.substring(0, 3) ?? '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  a.namaAktivitas,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    decoration: a.completed ? TextDecoration.lineThrough : null,
                                    color: a.completed ? Colors.grey : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (a.completed)
                                Icon(
                                  Icons.verified,
                                  color: Colors.green[700],
                                  size: 16,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Hari
                          if (a.hari != null)
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  a.hari!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          
                          // Keterangan
                          if (a.keterangan != null && a.keterangan!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                a.keterangan!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          
                          // Lansia (jika ada)
                          if (a.datalansiaId != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.person, size: 12, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Lansia ID: ${a.datalansiaId}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Action Menu
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onSelected: (value) => _handleMenuAction(value, a),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              const Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              const Text('Hapus'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatJam(String jam) {
    try {
      // Format: "HH:mm" to "HH:mm" or format sesuai locale
      return jam;
    } catch (e) {
      return jam;
    }
  }

  void _handleMenuAction(String action, JadwalAktivitas a) {
    switch (action) {
      case 'edit':
        _showEditDialog(a);
        break;
      case 'delete':
        _showDeleteDialog(a);
        break;
    }
  }

  void _showDeleteDialog(JadwalAktivitas a) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Hapus Jadwal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text('Yakin ingin menghapus "${a.namaAktivitas}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
            ),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _loading = true);
              
              try {
                final success = await _service.hapusJadwal(a.id!);
                if (success) {
                  _showSuccessSnackbar('Jadwal berhasil dihapus');
                  await _loadJadwal();
                } else {
                  _showErrorSnackbar('Gagal menghapus jadwal');
                }
              } catch (e) {
                _showErrorSnackbar('Error: $e');
              } finally {
                setState(() => _loading = false);
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(JadwalAktivitas a) {
    final namaAktivitasController = TextEditingController(text: a.namaAktivitas);
    final keteranganController = TextEditingController(text: a.keterangan);
    final jamController = TextEditingController(text: a.jam);
    String? selectedHari = a.hari;
    
    // Parse jam untuk time picker
    TimeOfDay? selectedTime;
    try {
      if (a.jam.isNotEmpty) {
        final parts = a.jam.split(':');
        if (parts.length == 2) {
          selectedTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    } catch (e) {
      print('Error parsing time: $e');
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Jadwal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaAktivitasController,
                  decoration: InputDecoration(
                    labelText: 'Nama Aktivitas*',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: keteranganController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Keterangan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Hari Dropdown
                DropdownButtonFormField<String>(
                  value: selectedHari,
                  decoration: InputDecoration(
                    labelText: 'Hari',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Senin', child: Text('Senin')),
                    DropdownMenuItem(value: 'Selasa', child: Text('Selasa')),
                    DropdownMenuItem(value: 'Rabu', child: Text('Rabu')),
                    DropdownMenuItem(value: 'Kamis', child: Text('Kamis')),
                    DropdownMenuItem(value: 'Jumat', child: Text('Jumat')),
                    DropdownMenuItem(value: 'Sabtu', child: Text('Sabtu')),
                    DropdownMenuItem(value: 'Minggu', child: Text('Minggu')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedHari = value);
                  },
                ),
                const SizedBox(height: 20),
                
                // Time Picker Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu (HH:mm)*',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                            builder: (context, child) => Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.brown[700]!,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedTime = picked;
                              jamController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedTime != null
                                  ? '${selectedTime!.format(context)}'
                                  : 'Pilih Waktu',
                              style: TextStyle(
                                color: selectedTime != null ? Colors.black87 : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(Icons.access_time, color: Colors.brown[700]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: jamController,
                        decoration: const InputDecoration(
                          hintText: 'Format: HH:mm (contoh: 08:30)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.datetime,
                        onChanged: (value) {
                          // Validasi format HH:mm
                          if (RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
                            final parts = value.split(':');
                            setDialogState(() {
                              selectedTime = TimeOfDay(
                                hour: int.parse(parts[0]),
                                minute: int.parse(parts[1]),
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (namaAktivitasController.text.isEmpty || jamController.text.isEmpty) {
                  _showErrorSnackbar('Harap isi nama aktivitas dan waktu');
                  return;
                }

                if (selectedHari == null) {
                  _showErrorSnackbar('Harap pilih hari');
                  return;
                }

                if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(jamController.text)) {
                  _showErrorSnackbar('Format waktu tidak valid. Gunakan HH:mm');
                  return;
                }

                final updatedJadwal = JadwalAktivitas(
                  id: a.id,
                  namaAktivitas: namaAktivitasController.text,
                  jam: jamController.text,
                  keterangan: keteranganController.text.isNotEmpty ? keteranganController.text : null,
                  hari: selectedHari,
                  status: a.status,
                  completed: a.completed,
                  datalansiaId: a.datalansiaId,
                  userId: a.userId,
                  perawatId: a.perawatId,
                );

                Navigator.pop(context);
                setState(() => _loading = true);

                try {
                  final success = await _service.updateJadwal(updatedJadwal);
                  if (success) {
                    _showSuccessSnackbar('Jadwal berhasil diupdate');
                    await _loadJadwal();
                  } else {
                    _showErrorSnackbar('Gagal mengupdate jadwal');
                  }
                } catch (e) {
                  _showErrorSnackbar('Error: $e');
                } finally {
                  setState(() => _loading = false);
                }
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTambahDialog() {
    final namaAktivitasController = TextEditingController();
    final keteranganController = TextEditingController();
    final jamController = TextEditingController();
    String? selectedHari;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Tambah Jadwal Baru',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaAktivitasController,
                  decoration: InputDecoration(
                    labelText: 'Nama Aktivitas*',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: keteranganController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Keterangan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Hari Dropdown
                DropdownButtonFormField<String>(
                  value: selectedHari,
                  decoration: InputDecoration(
                    labelText: 'Hari*',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Senin', child: Text('Senin')),
                    DropdownMenuItem(value: 'Selasa', child: Text('Selasa')),
                    DropdownMenuItem(value: 'Rabu', child: Text('Rabu')),
                    DropdownMenuItem(value: 'Kamis', child: Text('Kamis')),
                    DropdownMenuItem(value: 'Jumat', child: Text('Jumat')),
                    DropdownMenuItem(value: 'Sabtu', child: Text('Sabtu')),
                    DropdownMenuItem(value: 'Minggu', child: Text('Minggu')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedHari = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hari wajib dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Time Picker Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu (HH:mm)*',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                            builder: (context, child) => Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.brown[700]!,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedTime = picked;
                              jamController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedTime != null
                                  ? '${selectedTime!.format(context)}'
                                  : 'Pilih Waktu',
                              style: TextStyle(
                                color: selectedTime != null ? Colors.black87 : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(Icons.access_time, color: Colors.brown[700]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: jamController,
                        decoration: const InputDecoration(
                          hintText: 'Format: HH:mm (contoh: 08:30)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.datetime,
                        onChanged: (value) {
                          // Validasi format HH:mm
                          if (RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
                            final parts = value.split(':');
                            setDialogState(() {
                              selectedTime = TimeOfDay(
                                hour: int.parse(parts[0]),
                                minute: int.parse(parts[1]),
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (namaAktivitasController.text.isEmpty || jamController.text.isEmpty) {
                  _showErrorSnackbar('Harap isi nama aktivitas dan waktu');
                  return;
                }

                if (selectedHari == null) {
                  _showErrorSnackbar('Harap pilih hari');
                  return;
                }

                if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(jamController.text)) {
                  _showErrorSnackbar('Format waktu tidak valid. Gunakan HH:mm');
                  return;
                }

                final newJadwal = JadwalAktivitas(
                  namaAktivitas: namaAktivitasController.text,
                  jam: jamController.text,
                  keterangan: keteranganController.text.isNotEmpty ? keteranganController.text : null,
                  hari: selectedHari,
                  status: 'pending',
                  completed: false,
                );

                Navigator.pop(context);
                setState(() => _loading = true);

                try {
                  final success = await _service.tambahJadwal(newJadwal);
                  if (success) {
                    _showSuccessSnackbar('Jadwal berhasil ditambahkan');
                    await _loadJadwal();
                  } else {
                    _showErrorSnackbar('Gagal menambahkan jadwal');
                  }
                } catch (e) {
                  _showErrorSnackbar('Error: $e');
                } finally {
                  setState(() => _loading = false);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Filter Jadwal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Filter
                const Text(
                  'Status:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilterChip(
                        label: const Text('Selesai'),
                        selected: _showCompleted,
                        onSelected: (selected) {
                          setDialogState(() => _showCompleted = selected);
                        },
                        selectedColor: Colors.green[100],
                        checkmarkColor: Colors.green[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterChip(
                        label: const Text('Belum Selesai'),
                        selected: _showPending,
                        onSelected: (selected) {
                          setDialogState(() => _showPending = selected);
                        },
                        selectedColor: Colors.orange[100],
                        checkmarkColor: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Hari Filter
                const Text(
                  'Hari:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Semua'),
                      selected: _selectedHari == null,
                      onSelected: (selected) {
                        setDialogState(() => _selectedHari = null);
                      },
                    ),
                    ...hariList.map((hari) => FilterChip(
                          label: Text(hari),
                          selected: _selectedHari == hari,
                          onSelected: (selected) {
                            setDialogState(() => _selectedHari = selected ? hari : null);
                          },
                        )),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  _showCompleted = true;
                  _showPending = true;
                  _selectedHari = null;
                });
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {}); // Refresh UI dengan filter baru
              },
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );
  }

void _showDetail(JadwalAktivitas a) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.brown[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          a.namaAktivitas,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.brown[700]),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditDialog(a);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: a.completed ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          a.completed ? Icons.check_circle : Icons.access_time,
                          size: 14,
                          color: a.completed ? Colors.green[800] : Colors.orange[800],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          a.completed ? 'SELESAI' : 'BELUM SELESAI',
                          style: TextStyle(
                            color: a.completed ? Colors.green[800] : Colors.orange[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Detail Information
                  _buildDetailItem(Icons.access_time, 'Waktu', '${a.hari ?? "-"}, ${a.jam}'),
                  _buildDetailItem(Icons.description, 'Keterangan', a.keterangan ?? '-'),
                  if (a.datalansiaId != null)
                    _buildDetailItem(Icons.person, 'ID Lansia', a.datalansiaId.toString()),
                  _buildDetailItem(Icons.calendar_today, 'Tanggal Dibuat', 
                      a.createdAt != null 
                          ? DateFormat('dd MMM yyyy HH:mm').format(a.createdAt!)
                          : '-'),
                  
                  const Spacer(),
                  
                  // Action Buttons
                  Row(
                    children: [
                      if (!a.completed)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final success = await _service.updateCompleted(a.id!, true);
                              if (success) {
                                // Buat object baru dengan completed = true
                                final updatedIndex = _list.indexWhere((item) => item.id == a.id);
                                if (updatedIndex != -1) {
                                  setState(() {
                                    _list[updatedIndex] = a.copyWith(completed: true, status: 'completed');
                                  });
                                }
                                Navigator.pop(context);
                                _showSuccessSnackbar('Jadwal ditandai selesai');
                              } else {
                                _showErrorSnackbar('Gagal mengupdate status');
                              }
                            },
                            child: const Text(
                              'Tandai Selesai',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeleteDialog(a);
                          },
                          child: const Text(
                            'Hapus',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
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
  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.brown[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.brown[700], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}