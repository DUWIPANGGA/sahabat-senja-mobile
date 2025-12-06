// halaman/keluarga/jadwal_aktivitas_screen.dart
import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/jadwal_aktivitas_model.dart';

import 'package:intl/intl.dart';
import 'package:sahabatsenja_app/services/jadwal_aktifitas_service.dart';

class JadwalAktivitasScreen extends StatefulWidget {
  final int? datalansiaId;

  const JadwalAktivitasScreen({super.key, this.datalansiaId});

  @override
  State<JadwalAktivitasScreen> createState() => _JadwalAktivitasScreenState();
}

class _JadwalAktivitasScreenState extends State<JadwalAktivitasScreen> {
  final JadwalAktivitasService _service = JadwalAktivitasService();
  List<JadwalAktivitas> _jadwal = [];
  List<String> _hariList = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];
  String _selectedHari = '';
  bool _isLoading = true;
  bool _showCompleted = true;
  bool _isAdding = false;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jamController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedHari = _service.getHariIndonesia();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    setState(() => _isLoading = true);

    try {
      List<JadwalAktivitas> jadwal;
      
      if (widget.datalansiaId != null) {
        jadwal = await _service.getJadwalByLansia(widget.datalansiaId!);
      } else {
        jadwal = await _service.getAllJadwal(
          hari: _selectedHari,
        );
      }
      
      jadwal.sort((a, b) => a.jam.compareTo(b.jam));
      
      setState(() {
        _jadwal = jadwal;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading jadwal: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat jadwal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addJadwal() async {
    if (_namaController.text.isEmpty || _jamController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama aktivitas dan jam harus diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAdding = true);

    try {
      final newJadwal = JadwalAktivitas(
        namaAktivitas: _namaController.text,
        jam: _jamController.text,
        keterangan: _keteranganController.text,
        hari: _selectedHari,
        userId: 1, // Akan diisi oleh service
        datalansiaId: widget.datalansiaId,
      );

      await _service.createJadwal(newJadwal);
      
      // Reset form
      _namaController.clear();
      _jamController.clear();
      _keteranganController.clear();
      
      // Reload data
      await _loadJadwal();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error adding jadwal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambah jadwal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isAdding = false);
    }
  }

  Future<void> _updateCompleted(JadwalAktivitas jadwal) async {
    try {
      await _service.updateCompleted(jadwal.id!, !jadwal.completed);
      await _loadJadwal();
    } catch (e) {
      print('❌ Error updating completed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteJadwal(JadwalAktivitas jadwal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text('Yakin ingin menghapus "${jadwal.namaAktivitas}"?'),
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
        await _service.deleteJadwal(jadwal.id!);
        await _loadJadwal();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('❌ Error deleting jadwal: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus jadwal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        centerTitle: true,
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showCompleted ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() => _showCompleted = !_showCompleted);
            },
            tooltip: _showCompleted ? 'Sembunyikan selesai' : 'Tampilkan selesai',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJadwal,
            tooltip: 'Refresh',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Filter hari
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Hari:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _hariList.map((hari) {
                        final isSelected = hari == _selectedHari;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(hari),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedHari = hari;
                              });
                              _loadJadwal();
                            },
                            backgroundColor: Colors.grey[100],
                            selectedColor: const Color(0xFF9C6223),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF9C6223)),
                  )
                : _jadwal.isEmpty
                    ? _buildEmptyState()
                    : _buildJadwalList(),
          ),
        ],
      ),
      
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_outlined,
              color: Colors.grey,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada jadwal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan jadwal aktivitas untuk lansia',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
        ],
      ),
    );
  }

  Widget _buildJadwalList() {
    final filteredJadwal = _showCompleted
        ? _jadwal
        : _jadwal.where((j) => !j.completed).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredJadwal.length,
      itemBuilder: (context, index) {
        final jadwal = filteredJadwal[index];
        return _buildJadwalCard(jadwal);
      },
    );
  }

  Widget _buildJadwalCard(JadwalAktivitas jadwal) {
    return Dismissible(
      key: Key(jadwal.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        await _deleteJadwal(jadwal);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 1,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Checkbox(
            value: jadwal.completed,
            onChanged: (value) => _updateCompleted(jadwal),
            shape: const CircleBorder(),
            activeColor: const Color(0xFF4CAF50),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  jadwal.jam,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  jadwal.namaAktivitas,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: jadwal.completed
                        ? Colors.grey[600]
                        : const Color(0xFF333333),
                    decoration: jadwal.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          subtitle: jadwal.keterangan != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    jadwal.keterangan!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                )
              : null,
          trailing: Icon(
            jadwal.completed ? Icons.check_circle : Icons.circle,
            color: jadwal.completed ? const Color(0xFF4CAF50) : Colors.grey[300],
          ),
        ),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Tambah Jadwal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C6223),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Aktivitas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.text_fields),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _jamController,
                  decoration: InputDecoration(
                    labelText: 'Jam (HH:MM)',
                    hintText: '08:00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _keteranganController,
                  decoration: InputDecoration(
                    labelText: 'Keterangan (opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.note),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Hari:'),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedHari,
                      items: _hariList.map((hari) {
                        return DropdownMenuItem(
                          value: hari,
                          child: Text(hari),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedHari = value!);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: _isAdding ? null : _addJadwal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6223),
                foregroundColor: Colors.white,
              ),
              child: _isAdding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jamController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }
}