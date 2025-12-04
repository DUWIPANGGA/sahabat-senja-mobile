import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sahabatsenja_app/services/tracking_obat_service.dart';
import 'package:sahabatsenja_app/models/tracking_obat_model.dart';

class TrackingObatScreen extends StatefulWidget {
  const TrackingObatScreen({super.key});

  @override
  State<TrackingObatScreen> createState() => _TrackingObatScreenState();
}

class _TrackingObatScreenState extends State<TrackingObatScreen> {
  final TrackingObatService _service = TrackingObatService();
  List<TrackingObat> _trackingData = [];
  List<TrackingObat> _filteredData = [];
  bool _isLoading = true;
  bool _isInitializing = true;
  String _errorMessage = '';
  
  // Filter states
  String _filterStatus = 'Semua';
  DateTime _selectedDate = DateTime.now();
  bool _showTerlambat = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize date formatting untuk locale Indonesia
      await initializeDateFormatting('id_ID', null);
      
      setState(() => _isInitializing = false);
      
      // Load data tracking
      await _loadTrackingData();
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Gagal inisialisasi aplikasi: $e';
      });
    }
  }

  Future<void> _loadTrackingData() async {
    if (_isInitializing) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _service.fetchHariIni();
      setState(() {
        _trackingData = data;
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data tracking: $e';
      });
      _showSnackbar('Gagal memuat data tracking', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredData = _trackingData.where((tracking) {
        // Filter berdasarkan status
        if (_filterStatus == 'Sudah' && !tracking.sudahDiberikan) return false;
        if (_filterStatus == 'Belum' && tracking.sudahDiberikan) return false;
        
        // Filter terlambat (belum diberikan dan sudah lewat waktu)
        if (_showTerlambat) {
          final now = DateTime.now();
          final trackingTime = tracking.waktu;
          final isTerlambat = _isTerlambat(trackingTime, now);
          if (!isTerlambat || tracking.sudahDiberikan) return false;
        }
        
        return true;
      }).toList();
    });
  }

  bool _isTerlambat(String waktu, DateTime now) {
    final waktuMapping = {
      'Pagi': 9,    // Jam 9 pagi
      'Siang': 13,  // Jam 1 siang
      'Sore': 17,   // Jam 5 sore
      'Malam': 21,  // Jam 9 malam
    };
    
    final targetHour = waktuMapping[waktu] ?? 12;
    return now.hour > targetHour;
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  Future<void> _updateStatus(TrackingObat tracking, bool sudahDiberikan) async {
    final jamPemberian = sudahDiberikan 
        ? DateFormat('HH:mm').format(DateTime.now())
        : null;
    
    final success = await _service.updateStatus(
      tracking.id!, 
      sudahDiberikan,
      jamPemberian: jamPemberian,
    );
    
    if (success) {
      await _loadTrackingData();
      _showSnackbar('Status berhasil diupdate');
    } else {
      _showSnackbar('Gagal update status', isError: true);
    }
  }

  Future<void> _updateCatatan(TrackingObat tracking) async {
    final catatanController = TextEditingController(text: tracking.catatan ?? '');
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Catatan'),
        content: TextField(
          controller: catatanController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Masukkan catatan...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (catatanController.text.isNotEmpty) {
                final success = await _service.updateCatatan(
                  tracking.id!, 
                  catatanController.text,
                );
                
                if (success) {
                  await _loadTrackingData();
                  Navigator.pop(context);
                  _showSnackbar('Catatan berhasil disimpan');
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateTrackingHariIni() async {
    setState(() => _isLoading = true);
    
    final success = await _service.generateTrackingHariIni();
    
    if (success) {
      await _loadTrackingData();
      _showSnackbar('Tracking hari ini berhasil digenerate');
    } else {
      _showSnackbar('Gagal generate tracking', isError: true);
    }
    
    setState(() => _isLoading = false);
  }

  // Statistik
  int get _totalObat => _trackingData.length;
  int get _sudahDiberikan => _trackingData.where((t) => t.sudahDiberikan).length;
  int get _belumDiberikan => _totalObat - _sudahDiberikan;
  int get _terlambat => _trackingData
      .where((t) => !t.sudahDiberikan && _isTerlambat(t.waktu, DateTime.now()))
      .length;

  String _formatDateLong(DateTime date) {
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      // Fallback manual
      final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  String _formatTime(String? time) {
    if (time == null) return '-';
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        return '$hour:$minute';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      // Load data untuk tanggal yang dipilih
      setState(() => _isLoading = true);
      try {
        final data = await _service.fetchByTanggal(picked);
        setState(() {
          _trackingData = data;
          _applyFilters();
        });
      } catch (e) {
        _showSnackbar('Gagal memuat data untuk tanggal tersebut', isError: true);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading jika masih initializing
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tracking Obat Lansia'),
          backgroundColor: const Color(0xFF9C6223),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menyiapkan aplikasi...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Obat Lansia'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrackingData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add_alarm),
            onPressed: _generateTrackingHariIni,
            tooltip: 'Generate Tracking Hari Ini',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Header dengan tanggal
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateLong(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _selectDate,
              ),
            ],
          ),
        ),

        // Statistik
        _buildStatisticsCard(),

        // Filter
        _buildFilterSection(),

        // Daftar Tracking
        Expanded(
          child: _buildTrackingList(),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF9C6223),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', _totalObat.toString(), Colors.white),
            _buildStatItem('Sudah', _sudahDiberikan.toString(), Colors.green[300]!),
            _buildStatItem('Belum', _belumDiberikan.toString(), Colors.orange[300]!),
            _buildStatItem('Terlambat', _terlambat.toString(), Colors.red[300]!),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip('Semua', _filterStatus == 'Semua', () {
                      setState(() {
                        _filterStatus = 'Semua';
                        _showTerlambat = false;
                        _applyFilters();
                      });
                    }),
                    _buildFilterChip('Sudah', _filterStatus == 'Sudah', () {
                      setState(() {
                        _filterStatus = 'Sudah';
                        _showTerlambat = false;
                        _applyFilters();
                      });
                    }),
                    _buildFilterChip('Belum', _filterStatus == 'Belum', () {
                      setState(() {
                        _filterStatus = 'Belum';
                        _showTerlambat = false;
                        _applyFilters();
                      });
                    }),
                    _buildFilterChip(
                      'Terlambat',
                      _showTerlambat,
                      () {
                        setState(() {
                          _showTerlambat = !_showTerlambat;
                          if (_showTerlambat) {
                            _filterStatus = 'Belum';
                          }
                          _applyFilters();
                        });
                      },
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap,
      {Color? color}) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) => onTap(),
      selectedColor: color ?? const Color(0xFF9C6223),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildTrackingList() {
    if (_errorMessage.isNotEmpty) {
      return Center(
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
                onPressed: _loadTrackingData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada data tracking',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            if (_filterStatus != 'Semua' || _showTerlambat)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Coba ubah filter atau pilih tanggal lain',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrackingData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredData.length,
        itemBuilder: (context, index) {
          final tracking = _filteredData[index];
          return _buildTrackingCard(tracking);
        },
      ),
    );
  }

  Widget _buildTrackingCard(TrackingObat tracking) {
    final isTerlambat = !tracking.sudahDiberikan && 
        _isTerlambat(tracking.waktu, DateTime.now());
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: tracking.sudahDiberikan
                ? Colors.green[100]
                : isTerlambat
                    ? Colors.red[100]
                    : Colors.orange[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            tracking.sudahDiberikan
                ? Icons.check_circle
                : isTerlambat
                    ? Icons.warning
                    : Icons.access_time,
            color: tracking.sudahDiberikan
                ? Colors.green
                : isTerlambat
                    ? Colors.red
                    : Colors.orange,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tracking.namaObat,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: tracking.sudahDiberikan
                    ? TextDecoration.lineThrough
                    : null,
                color: tracking.sudahDiberikan
                    ? Colors.grey
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '💊 ${tracking.dosis} • ⏰ ${tracking.waktu}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (tracking.jamPemberian != null)
              Text(
                'Diberikan: ${_formatTime(tracking.jamPemberian)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        subtitle: tracking.catatan != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '📝 ${tracking.catatan!}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.note_add,
                color: tracking.catatan != null ? Colors.blue : Colors.grey,
              ),
              onPressed: () => _updateCatatan(tracking),
              tooltip: 'Catatan',
            ),
            Switch(
              value: tracking.sudahDiberikan,
              onChanged: (value) => _updateStatus(tracking, value),
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}