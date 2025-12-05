import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/perawat/manage_obat_screen.dart';
import 'package:sahabatsenja_app/services/jadwal_obat_service.dart';
import 'package:sahabatsenja_app/models/jadwal_obat_model.dart';
import 'package:intl/intl.dart';

class JadwalObatMainScreen extends StatefulWidget {
  final int? datalansiaId; // Parameter opsional: jika null -> semua lansia
  final String? namaLansia; // Parameter opsional

  const JadwalObatMainScreen({
    super.key,
    this.datalansiaId,
    this.namaLansia,
  });

  @override
  State<JadwalObatMainScreen> createState() => _JadwalObatMainScreenState();
}

class _JadwalObatMainScreenState extends State<JadwalObatMainScreen> {
  final JadwalObatService _service = JadwalObatService();
  List<JadwalObat> _obatHariIni = [];
  bool _isLoading = true;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDataHariIni();
  }

  Future<void> _loadDataHariIni() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      if (widget.datalansiaId != null) {
        // Ambil data obat untuk lansia spesifik
        final today = DateFormat('yyyy-MM-dd').format(_selectedDate);
        final data = await _service.getTodayForLansia(widget.datalansiaId!, today);
        setState(() => _obatHariIni = data);
      } else {
        // Ambil semua data obat hari ini (semua lansia)
        final data = await _service.getAktifHariIni();
        setState(() => _obatHariIni = data);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat data: $e');
      _showSnackbar('Gagal memuat data obat hari ini', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsDone(int id) async {
    try {
      final success = await _service.updateSelesai(id, true);
      if (success) {
        _loadDataHariIni();
        _showSnackbar('Obat berhasil ditandai selesai');
      } else {
        _showSnackbar('Gagal update status', isError: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9C6223),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadDataHariIni();
    }
  }

  Widget _buildDateSelector() {
    final today = DateTime.now();
    final isToday = _selectedDate.year == today.year &&
                    _selectedDate.month == today.month &&
                    _selectedDate.day == today.day;

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF8F3EA),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.datalansiaId != null
                      ? 'Obat ${widget.namaLansia ?? "Lansia"}'
                      : 'Jadwal Obat',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isToday ? 'Hari Ini' : DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (widget.datalansiaId != null && widget.namaLansia != null)
                  const SizedBox(height: 4),
                if (widget.datalansiaId != null && widget.namaLansia != null)
                  Text(
                    widget.namaLansia!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 20),
                  color: const Color(0xFF9C6223),
                  onPressed: _selectDate,
                  tooltip: 'Pilih tanggal',
                ),
                if (!isToday)
                  IconButton(
                    icon: const Icon(Icons.today, size: 20),
                    color: const Color(0xFF9C6223),
                    onPressed: () {
                      setState(() => _selectedDate = DateTime.now());
                      _loadDataHariIni();
                    },
                    tooltip: 'Hari ini',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalObat = _obatHariIni.length;
    final obatSelesai = _obatHariIni.where((o) => o.selesai).length;
    final obatBelum = _obatHariIni.where((o) => !o.selesai).length;
    final obatPagi = _obatHariIni.where((o) => o.waktu == 'Pagi').length;
    final obatSiang = _obatHariIni.where((o) => o.waktu == 'Siang').length;
    final obatSore = _obatHariIni.where((o) => o.waktu == 'Sore').length;
    final obatMalam = _obatHariIni.where((o) => o.waktu == 'Malam').length;

    final cardData = [
      if (widget.datalansiaId == null)
        _CardData('Total', totalObat.toString(), Icons.medication, const Color(0xFF2196F3)),
      _CardData('Belum', obatBelum.toString(), Icons.watch_later_outlined, Colors.orange),
      _CardData('Selesai', obatSelesai.toString(), Icons.check_circle, Colors.green),
      _CardData('Pagi', obatPagi.toString(), Icons.wb_sunny, Colors.yellow[700]!),
      _CardData('Siang', obatSiang.toString(), Icons.sunny, Colors.orange),
      _CardData('Sore', obatSore.toString(), Icons.nightlight_round, Colors.deepOrange),
      _CardData('Malam', obatMalam.toString(), Icons.bedtime, Colors.indigo),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Statistik Obat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Horizontal ListView
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cardData.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final data = cardData[index];
                return _buildSummaryCard(data.title, data.value, data.icon, data.color);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
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
            const SizedBox(height: 16),
            Text(
              widget.datalansiaId != null
                  ? 'Tidak ada jadwal obat untuk ${widget.namaLansia ?? "lansia ini"}'
                  : 'Tidak ada jadwal obat hari ini',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMMM yyyy').format(_selectedDate),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            if (widget.datalansiaId != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to manage obat screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageJadwalObatScreen(
                          datalansiaId: widget.datalansiaId!,
                          namaLansia: widget.namaLansia ?? 'Lansia',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C6223),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Jadwal Obat'),
                ),
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
              onPressed: _loadDataHariIni,
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
    final isSelesai = obat.selesai;
    final waktuText = _getWaktuText(obat.waktu);
    final jamMinum = obat.jamMinum;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelesai ? Colors.green[100] : Colors.orange[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelesai ? Icons.check : Icons.medication,
                    color: isSelesai ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obat.namaObat,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelesai ? Colors.grey : Colors.black,
                          decoration: isSelesai ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        waktuText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelesai ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isSelesai ? 'Selesai' : 'Belum',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Detail obat
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('💊 Dosis:', obat.dosis),
                const SizedBox(height: 8),
                if (jamMinum != null && jamMinum.isNotEmpty)
                  Column(
                    children: [
                      _buildDetailRow('🕐 Jam:', jamMinum),
                      const SizedBox(height: 8),
                    ],
                  ),
                _buildDetailRow('📅 Frekuensi:', obat.frekuensi),
                const SizedBox(height: 8),
                if (obat.catatan != null && obat.catatan!.isNotEmpty)
                  _buildDetailRow('📝 Catatan:', obat.catatan!),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action button
            if (!isSelesai)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _markAsDone(obat.id!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Tandai Sudah Diberikan'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _getWaktuText(String waktu) {
    switch (waktu) {
      case 'Pagi': return 'Pagi 🍳';
      case 'Siang': return 'Siang 🍲';
      case 'Sore': return 'Sore ☕';
      case 'Malam': return 'Malam 🌙';
      default: return waktu;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.datalansiaId != null
            ? Text('Obat ${widget.namaLansia ?? "Lansia"}')
            : const Text('Jadwal Obat Hari Ini'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDataHariIni,
            tooltip: 'Refresh',
          ),
          if (widget.datalansiaId != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageJadwalObatScreen(
                      datalansiaId: widget.datalansiaId!,
                      namaLansia: widget.namaLansia ?? 'Lansia',
                    ),
                  ),
                );
              },
              tooltip: 'Tambah Jadwal Obat',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF9C6223)),
            )
          : Column(
              children: [
                _buildDateSelector(),
                _buildSummaryCards(),
                
                // Header list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.datalansiaId != null
                            ? 'Daftar Obat (${_obatHariIni.length})'
                            : 'Obat Hari Ini (${_obatHariIni.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      if (_obatHariIni.isNotEmpty)
                        Text(
                          '${_obatHariIni.where((o) => !o.selesai).length} belum',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                    ],
                  ),
                ),
                
                // List obat
                Expanded(
                  child: _errorMessage.isNotEmpty
                      ? _buildErrorState()
                      : _obatHariIni.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadDataHariIni,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(top: 8, bottom: 20),
                                itemCount: _obatHariIni.length,
                                itemBuilder: (context, index) {
                                  final obat = _obatHariIni[index];
                                  return _buildObatCard(obat);
                                },
                              ),
                            ),
                ),
              ],
            ),
    );
  }
}

// Helper class untuk data card
class _CardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _CardData(this.title, this.value, this.icon, this.color);
}
