// halaman/keluarga/jadwal_aktivitas_screen.dart - READ-ONLY VERSION
import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/jadwal_aktivitas_model.dart';
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
    'Semua',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];
  String _selectedHari = 'Semua';
  bool _isLoading = true;
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    setState(() => _isLoading = true);

    try {
      List<JadwalAktivitas> jadwal;
      
      if (widget.datalansiaId != null) {
        jadwal = await _service.getJadwalByLansia(widget.datalansiaId!);
      } else {
        jadwal = await _service.getAllJadwal();
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

  // Filter jadwal berdasarkan hari yang dipilih
  List<JadwalAktivitas> _getFilteredJadwal() {
    List<JadwalAktivitas> filteredByDay = _jadwal;
    
    // Filter berdasarkan hari
    if (_selectedHari != 'Semua') {
      filteredByDay = _jadwal.where((j) => j.hari == _selectedHari).toList();
    }
    
    // Filter berdasarkan status completed
    if (!_showCompleted) {
      filteredByDay = filteredByDay.where((j) => !j.completed).toList();
    }
    
    return filteredByDay;
  }

  // Fungsi untuk menampilkan detail jadwal (READ-ONLY)
  void _showJadwalDetail(JadwalAktivitas jadwal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan drag indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
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
                        'Detail Jadwal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Activity Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: jadwal.completed 
                          ? const Color(0xFFE8F5E8) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: jadwal.completed 
                            ? const Color(0xFF4CAF50).withOpacity(0.2) 
                            : Colors.grey[200]!,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Activity title
                        Text(
                          jadwal.namaAktivitas,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: jadwal.completed 
                                ? Colors.grey[600] 
                                : const Color(0xFF333333),
                            decoration: jadwal.completed 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Detail Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _buildDetailCell(
                              icon: Icons.access_time,
                              title: 'Jam',
                              value: jadwal.jam,
                              color: Colors.blue,
                            ),
                            _buildDetailCell(
                              icon: Icons.calendar_today,
                              title: 'Hari',
                              value: jadwal.hari ?? '-',
                              color: Colors.purple,
                            ),
                            _buildDetailCell(
                              icon: jadwal.completed 
                                  ? Icons.check_circle 
                                  : Icons.pending,
                              title: 'Status',
                              value: jadwal.completed ? 'Selesai' : 'Belum Dikerjakan',
                              color: jadwal.completed ? Colors.green : Colors.orange,
                            ),
                            if (widget.datalansiaId != null)
                              _buildDetailCell(
                                icon: Icons.person_outline,
                                title: 'Lansia ID',
                                value: widget.datalansiaId.toString(),
                                color: Colors.teal,
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Keterangan jika ada
                        if (jadwal.keterangan != null && jadwal.keterangan!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              const SizedBox(height: 12),
                              const Text(
                                'Keterangan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                jadwal.keterangan!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Informasi Read-Only
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Halaman ini hanya untuk melihat jadwal. Perubahan status hanya dapat dilakukan oleh perawat.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCell({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredJadwal = _getFilteredJadwal();
    final totalItems = filteredJadwal.length;
    final completedCount = filteredJadwal.where((j) => j.completed).length;

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
            child: Column(
              children: [
                // Statistics Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      'Total',
                      totalItems.toString(),
                      Colors.blue,
                      Icons.list_alt,
                    ),
                    _buildStatCard(
                      'Selesai',
                      completedCount.toString(),
                      Colors.green,
                      Icons.check_circle,
                    ),
                    _buildStatCard(
                      'Belum',
                      (totalItems - completedCount).toString(),
                      Colors.orange,
                      Icons.pending,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Filter:',
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
                              child: FilterChip(
                                label: Text(hari),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedHari = hari;
                                  });
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: const Color(0xFF9C6223).withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: isSelected 
                                      ? const Color(0xFF9C6223) 
                                      : Colors.grey[800],
                                  fontWeight: FontWeight.w500,
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
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF9C6223)),
                  )
                : filteredJadwal.isEmpty
                    ? _buildEmptyState()
                    : _buildJadwalList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
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
          Text(
            _selectedHari == 'Semua'
                ? 'Belum ada jadwal aktivitas'
                : 'Tidak ada jadwal untuk $_selectedHari',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jadwal akan muncul di sini setelah ditambahkan oleh perawat',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalList() {
    final filteredJadwal = _getFilteredJadwal();

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
    return InkWell(
      onTap: () => _showJadwalDetail(jadwal),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time and day
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
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
                        const SizedBox(width: 4),
                        Text(
                          jadwal.jam,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                        if (jadwal.hari != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            jadwal.hari!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: jadwal.completed
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
                            color: jadwal.completed
                                ? const Color(0xFF4CAF50)
                                : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          jadwal.completed ? 'Selesai' : 'Belum Dikerjakan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: jadwal.completed
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
              
              // Activity title dengan icon read-only
              Row(
                children: [
                  // Icon status read-only (bukan checkbox)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: jadwal.completed 
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      jadwal.completed 
                          ? Icons.check_circle_outline 
                          : Icons.pending_outlined,
                      size: 16,
                      color: jadwal.completed ? Colors.green : Colors.orange,
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
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              
              // Keterangan jika ada
              if (jadwal.keterangan != null && jadwal.keterangan!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 36),
                  child: Text(
                    jadwal.keterangan!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              // Footer hint
              const Padding(
                padding: EdgeInsets.only(top: 12, left: 36),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Klik untuk melihat detail',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}