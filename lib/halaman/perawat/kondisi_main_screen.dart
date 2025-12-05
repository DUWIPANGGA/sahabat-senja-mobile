import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/perawat/kondisi_detail_screen.dart';
import '../../services/datalansia_service.dart';
import '../../services/kondisi_service.dart';
import '../../models/datalansia_model.dart';
import '../../models/kondisi_model.dart';

class KondisiMainScreen extends StatefulWidget {
  const KondisiMainScreen({super.key});

  @override
  State<KondisiMainScreen> createState() => _KondisiMainScreenState();
}

class _KondisiMainScreenState extends State<KondisiMainScreen> {
  final DatalansiaService _datalansiaService = DatalansiaService();
  final KondisiService _kondisiService = KondisiService();

  List<Datalansia> _semuaLansia = [];
  Map<String, KondisiHarian?> _latestKondisi = {};
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load semua data lansia
      final lansiaList = await _datalansiaService.getDatalansia();
      
      // Load latest kondisi untuk setiap lansia
      final latestKondisiMap = <String, KondisiHarian?>{};
      
      for (final lansia in lansiaList) {
        final nama = lansia.namaLansia ?? 'Tanpa Nama';
        try {
          final kondisi = await _kondisiService.getTodayData(nama);
          latestKondisiMap[nama] = kondisi;
        } catch (e) {
          latestKondisiMap[nama] = null;
        }
      }

      if (mounted) {
        setState(() {
          _semuaLansia = lansiaList;
          _latestKondisi = latestKondisiMap;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getStatus(KondisiHarian? kondisi) {
    if (kondisi == null) return 'Belum Diperiksa';
    if (kondisi.status != null && kondisi.status!.isNotEmpty) {
      return kondisi.status!;
    }
    
    // Default logic
    if (kondisi.nadi != null && kondisi.nadi!.isNotEmpty) {
      final nadi = int.tryParse(kondisi.nadi ?? '0') ?? 0;
      if (nadi >= 60 && nadi <= 100) return 'Stabil';
      return 'Perlu Perhatian';
    }
    
    return 'Stabil';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'stabil':
      case 'baik':
        return Colors.green;
      case 'perlu perhatian':
      case 'sedang':
        return Colors.orange;
      case 'kritis':
      case 'buruk':
        return Colors.red;
      case 'belum diperiksa':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'stabil':
      case 'baik':
        return Icons.check_circle;
      case 'perlu perhatian':
      case 'sedang':
        return Icons.warning;
      case 'kritis':
      case 'buruk':
        return Icons.error;
      case 'belum diperiksa':
        return Icons.help_outline;
      default:
        return Icons.health_and_safety;
    }
  }

  List<Datalansia> get _filteredLansia {
    var filtered = _semuaLansia;

    // Filter berdasarkan pencarian
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((lansia) {
        final nama = lansia.namaLansia?.toLowerCase() ?? '';
        final alamat = lansia.alamatLengkap?.toLowerCase() ?? '';
        return nama.contains(_searchQuery.toLowerCase()) ||
               alamat.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter berdasarkan status
    if (_filterStatus != 'Semua') {
      filtered = filtered.where((lansia) {
        final kondisi = _latestKondisi[lansia.namaLansia ?? ''];
        final status = _getStatus(kondisi);
        return status == _filterStatus;
      }).toList();
    }

    // Sort by nama
    filtered.sort((a, b) => (a.namaLansia ?? '').compareTo(b.namaLansia ?? ''));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredLansia = _filteredLansia;
    
    // Hitung statistik
    final totalLansia = _semuaLansia.length;
    final totalDiperiksa = _semuaLansia.where((l) => 
      _latestKondisi[l.namaLansia ?? ''] != null).length;
    final totalStabil = _semuaLansia.where((l) => 
      _getStatus(_latestKondisi[l.namaLansia ?? '']) == 'Stabil').length;
    final totalPerluPerhatian = _semuaLansia.where((l) => 
      _getStatus(_latestKondisi[l.namaLansia ?? '']) == 'Perlu Perhatian').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Lansia'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildError()
              : _buildContent(filteredLansia, totalLansia, totalDiperiksa, totalStabil, totalPerluPerhatian),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF9C6223).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9C6223)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Memuat data lansia...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6223),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildContent(
  List<Datalansia> lansiaList,
  int totalLansia,
  int totalDiperiksa,
  int totalStabil,
  int totalPerluPerhatian,
) {
  return Column(
    children: [
      // Header dengan statistik
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F3EA),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Search bar
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
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama atau alamat lansia...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9C6223)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Stabil', 'Perlu Perhatian', 'Belum Diperiksa'].map((status) {
                  final isSelected = _filterStatus == status;
                  final color = _getStatusColor(status);
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _filterStatus = selected ? status : 'Semua');
                      },
                      backgroundColor: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
                      selectedColor: color.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? color : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      showCheckmark: false,
                      avatar: Icon(
                        _getStatusIcon(status),
                        color: color,
                        size: 16,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),

      // Statistik cards dengan scroll horizontal
      Container(
        height: 110, // Fixed height untuk statistik cards
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: 16), // Padding kiri
              _buildStatCard(
                'Total Lansia',
                totalLansia.toString(),
                Icons.people,
                const Color(0xFF2196F3),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Sudah Diperiksa',
                totalDiperiksa.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Belum Diperiksa',
                (totalLansia - totalDiperiksa).toString(),
                Icons.help_outline,
                Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Stabil',
                totalStabil.toString(),
                Icons.health_and_safety,
                const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Perlu Perhatian',
                totalPerluPerhatian.toString(),
                Icons.warning,
                const Color(0xFFFF9800),
              ),
              const SizedBox(width: 16), // Padding kanan
            ],
          ),
        ),
      ),

      // List header
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Lansia (${lansiaList.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4037),
              ),
            ),
            if (lansiaList.isNotEmpty)
              Text(
                'Terakhir Diperiksa',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),

      // List of lansia
      Expanded(
        child: lansiaList.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lansiaList.length,
                itemBuilder: (context, index) {
                  final lansia = lansiaList[index];
                  final kondisi = _latestKondisi[lansia.namaLansia ?? ''];
                  final status = _getStatus(kondisi);
                  final statusColor = _getStatusColor(status);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildLansiaCard(lansia, kondisi, status, statusColor),
                  );
                },
              ),
      ),
    ],
  );
}
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
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
              Icons.search_off,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ditemukan lansia dengan kata kunci "$_searchQuery"'
                  : 'Belum ada data lansia',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            if (_searchQuery.isNotEmpty || _filterStatus != 'Semua')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _filterStatus = 'Semua';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C6223),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset Pencarian'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLansiaCard(Datalansia lansia, KondisiHarian? kondisi, String status, Color statusColor) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KondisiDetailScreen(
                lansia: lansia,
                latestKondisi: kondisi,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar lansia
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C6223).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF9C6223).withOpacity(0.3), width: 1),
                ),
                child: Icon(
                  lansia.jenisKelaminLansia == 'Laki-laki' ? Icons.male : Icons.female,
                  color: const Color(0xFF9C6223),
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              
              // Informasi lansia
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lansia.namaLansia ?? 'Tanpa Nama',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lansia.umurLansia ?? '-'} tahun • ${lansia.jenisKelaminLansia ?? '-'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (lansia.alamatLengkap != null && lansia.alamatLengkap!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                lansia.alamatLengkap!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Status dan info pemeriksaan
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          color: statusColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (kondisi != null)
                    Text(
                      '${_formatDate(kondisi.tanggal)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    )
                  else
                    Text(
                      'Belum diperiksa',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Hari ini';
    if (dateOnly == yesterday) return 'Kemarin';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}