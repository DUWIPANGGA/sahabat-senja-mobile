// widgets/jadwal_aktivitas_dashboard.dart - MODIFIED VERSION
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahabatsenja_app/models/jadwal_aktivitas_model.dart';
import 'package:sahabatsenja_app/services/jadwal_aktifitas_service.dart';

class JadwalAktivitasDashboard extends StatefulWidget {
  final int? datalansiaId;
  final bool showHeader;

  const JadwalAktivitasDashboard({
    super.key, 
    this.datalansiaId,
    this.showHeader = true,
  });

  @override
  State<JadwalAktivitasDashboard> createState() => _JadwalAktivitasDashboardState();
}

class _JadwalAktivitasDashboardState extends State<JadwalAktivitasDashboard> {
  final JadwalAktivitasService _service = JadwalAktivitasService();
  List<JadwalAktivitas> _jadwal = [];
  List<JadwalAktivitas> _filteredJadwal = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Daftar hari untuk filter
  final List<String> _daysList = [
    'Semua',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];
  
  // Hari yang aktif dipilih
  String _selectedDay = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      List<JadwalAktivitas> jadwal;
      
      if (widget.datalansiaId != null) {
        jadwal = await _service.getJadwalByLansia(widget.datalansiaId!);
      } else {
        jadwal = await _service.getJadwalHariIni();
      }
      
      // Urutkan berdasarkan jam
      jadwal.sort((a, b) => a.jam.compareTo(b.jam));
      
      setState(() {
        _jadwal = jadwal;
        _filteredJadwal = _applyDayFilter(jadwal, _selectedDay);
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading jadwal: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  // Fungsi untuk filter berdasarkan hari
  List<JadwalAktivitas> _applyDayFilter(List<JadwalAktivitas> jadwal, String day) {
    if (day == 'Semua') {
      return jadwal;
    }
    return jadwal.where((item) => item.hari == day).toList();
  }

  // Fungsi untuk mengubah filter hari
  void _onDaySelected(String day) {
    setState(() {
      _selectedDay = day;
      _filteredJadwal = _applyDayFilter(_jadwal, day);
    });
  }

  String _formatTime(String time) {
    try {
      final parsedTime = DateFormat('HH:mm').parse(time);
      return DateFormat('HH:mm').format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  // Fungsi untuk menampilkan detail jadwal
  void _showJadwalDetail(JadwalAktivitas jadwal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9C6223).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule_outlined,
                color: Color(0xFF9C6223),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Detail Jadwal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Informasi Waktu
              _buildDetailItem(
                icon: Icons.access_time,
                title: 'Waktu',
                value: _formatTime(jadwal.jam),
                iconColor: Colors.blue,
              ),
              
              const SizedBox(height: 16),
              
              // Informasi Aktivitas
              _buildDetailItem(
                icon: Icons.assignment_outlined,
                title: 'Aktivitas',
                value: jadwal.namaAktivitas,
                iconColor: const Color(0xFF9C6223),
              ),
              
              const SizedBox(height: 16),
              
              // Informasi Hari
              if (jadwal.hari != null && jadwal.hari!.isNotEmpty)
                Column(
                  children: [
                    _buildDetailItem(
                      icon: Icons.calendar_today_outlined,
                      title: 'Hari',
                      value: jadwal.hari!,
                      iconColor: Colors.purple,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              
              // Informasi Status
              _buildDetailItem(
                icon: jadwal.completed ? Icons.check_circle : Icons.pending,
                title: 'Status',
                value: jadwal.completed ? 'Selesai' : 'Belum Dikerjakan',
                iconColor: jadwal.completed ? Colors.green : Colors.orange,
              ),
              
              const SizedBox(height: 16),
              
              // Keterangan (jika ada)
              if (jadwal.keterangan != null && jadwal.keterangan!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keterangan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        jadwal.keterangan!,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 8),
              
              // Informasi tambahan
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Status hanya dapat diubah oleh perawat melalui aplikasi web',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
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
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9C6223),
            ),
            child: const Text('TUTUP'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHeader) ...[
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C6223).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.schedule_outlined,
                        color: Color(0xFF9C6223),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Jadwal Aktivitas Lansia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  color: Colors.grey[600],
                  onPressed: _loadJadwal,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Filter Hari (Hanya ditampilkan jika ada jadwal)
          if (!_isLoading && !_hasError && _jadwal.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter berdasarkan hari:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _daysList.length,
                    itemBuilder: (context, index) {
                      final day = _daysList[index];
                      final isSelected = _selectedDay == day;
                      
                      return Container(
                        margin: EdgeInsets.only(
                          right: index < _daysList.length - 1 ? 8 : 0,
                        ),
                        child: FilterChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (selected) => _onDaySelected(day),
                          backgroundColor: Colors.grey[100],
                          selectedColor: const Color(0xFF9C6223).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected 
                                ? const Color(0xFF9C6223) 
                                : Colors.grey[700],
                            fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                          checkmarkColor: const Color(0xFF9C6223),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected 
                                  ? const Color(0xFF9C6223) 
                                  : Colors.grey[300]!,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          
          // Content
          if (_isLoading)
            _buildLoading()
          else if (_hasError)
            _buildError()
          else if (_jadwal.isEmpty)
            _buildEmptyState()
          else if (_filteredJadwal.isEmpty)
            _buildNoFilteredResults()
          else
            _buildJadwalList(),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: const Column(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF9C6223),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Memuat jadwal...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat jadwal',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadJadwal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C6223),
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_outlined,
              color: Colors.grey,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada jadwal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jadwal aktivitas akan muncul di sini',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoFilteredResults() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.filter_alt_outlined,
              color: Colors.grey,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada jadwal untuk $_selectedDay',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba pilih hari lain atau lihat jadwal "Semua"',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _onDaySelected('Semua'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C6223),
              foregroundColor: Colors.white,
              minimumSize: const Size(140, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Lihat Semua Jadwal'),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalList() {
    final filteredCompletedCount = _filteredJadwal.where((j) => j.completed).length;
    final filteredTotalCount = _filteredJadwal.length;
    final progress = filteredTotalCount > 0 
        ? filteredCompletedCount / filteredTotalCount 
        : 0;

    return Column(
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress $_selectedDay',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress.toDouble(),
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF4CAF50),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Total',
                    filteredTotalCount.toString(),
                    Icons.list_alt_outlined,
                    Colors.blue,
                  ),
                  _buildSummaryItem(
                    'Selesai',
                    filteredCompletedCount.toString(),
                    Icons.check_circle_outlined,
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    'Belum',
                    (filteredTotalCount - filteredCompletedCount).toString(),
                    Icons.pending_outlined,
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Title for list
        Text(
          'Daftar Aktivitas ($filteredTotalCount item)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // List of activities
        Column(
          children: _filteredJadwal
              .map((jadwal) => _buildJadwalItem(jadwal))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildJadwalItem(JadwalAktivitas jadwal) {
    final isCompleted = jadwal.completed;
    final time = _formatTime(jadwal.jam);
    final title = jadwal.namaAktivitas;
    final keterangan = jadwal.keterangan;
    final hari = jadwal.hari;

    return InkWell(
      onTap: () => _showJadwalDetail(jadwal),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFFE8F5E8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted 
                ? const Color(0xFF4CAF50).withOpacity(0.2) 
                : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with time and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Time badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status badge dengan hover effect
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? const Color(0xFF4CAF50).withOpacity(0.1) 
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? const Color(0xFF4CAF50) 
                              : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isCompleted ? 'Selesai' : 'Belum',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCompleted 
                              ? const Color(0xFF4CAF50) 
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Activity title dengan icon
            Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 16,
                  color: isCompleted ? Colors.grey : const Color(0xFF9C6223),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? Colors.grey[600] : const Color(0xFF333333),
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                // Icon untuk menunjukkan bahwa bisa diklik
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ],
            ),
            
            // Day info (if available)
            if (hari != null && hari.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hari,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            
            // Description (if available)
            if (keterangan != null && keterangan.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        keterangan,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Footer dengan instruksi klik
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 6),
                Text(
                  'Klik untuk melihat detail',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}