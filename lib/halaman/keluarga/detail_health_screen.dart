// screens/keluarga/detail_health_screen.dart
import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/models/kondisi_model.dart';
import 'package:sahabatsenja_app/services/kondisi_service.dart';

class DetailHealthScreen extends StatefulWidget {
  final Datalansia lansia;

  const DetailHealthScreen({super.key, required this.lansia});

  @override
  State<DetailHealthScreen> createState() => _DetailHealthScreenState();
}

class _DetailHealthScreenState extends State<DetailHealthScreen> {
  final KondisiService _kondisiService = KondisiService();
  late Future<KondisiHarian?> _kondisiHariIni;
  late Future<List<KondisiHarian>> _riwayatKondisi;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _kondisiHariIni = _kondisiService.getTodayData(widget.lansia.namaLansia ?? '');
      _riwayatKondisi = _kondisiService.fetchRiwayatByNama(widget.lansia.namaLansia ?? '');
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    _loadData();
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kesehatan ${widget.lansia.namaLansia}'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLansiaInfo(),
              const SizedBox(height: 24),
              FutureBuilder<KondisiHarian?>(
                future: _kondisiHariIni,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingSection('Memuat kondisi hari ini...');
                  } else if (snapshot.hasError) {
                    return _buildErrorSection('Gagal memuat kondisi: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return _buildEmptySection(
                      'Belum ada data kondisi hari ini',
                      Icons.info_outline,
                    );
                  } else {
                    return _buildKondisiTerkini(snapshot.data!);
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Riwayat Kesehatan'),
              FutureBuilder<List<KondisiHarian>>(
                future: _riwayatKondisi,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingSection('Memuat riwayat...');
                  } else if (snapshot.hasError) {
                    return _buildErrorSection('Gagal memuat riwayat: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptySection(
                      'Belum ada riwayat kesehatan',
                      Icons.history,
                    );
                  } else {
                    return _buildRiwayatKesehatan(snapshot.data!);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLansiaInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF9C6223).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF9C6223),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person,
                color: const Color(0xFF9C6223),
                size: 36,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lansia.namaLansia ?? 'Nama tidak tersedia',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.lansia.umurLansia ?? '?'} tahun',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Riwayat: ${widget.lansia.riwayatPenyakitLansia ?? 'Tidak ada'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF9C6223),
        ),
      ),
    );
  }

  Widget _buildKondisiTerkini(KondisiHarian kondisi) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.today, color: Color(0xFF9C6223)),
                SizedBox(width: 8),
                Text(
                  'Kondisi Hari Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tanggal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tanggal: ${_formatDate(kondisi.tanggal)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Grid metrics
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildMetricCard(
                  Icons.favorite,
                  'Detak Jantung',
                  '${kondisi.nadi} bpm',
                  kondisi.nadi == null || kondisi.nadi == ''
                      ? Colors.grey
                      : _getHeartRateColor(int.tryParse(kondisi.nadi ?? '0') ?? 0),
                ),
                _buildMetricCard(
                  Icons.monitor_heart,
                  'Tekanan Darah',
                  kondisi.tekananDarah ?? '-',
                  _getBloodPressureColor(kondisi.tekananDarah ?? ''),
                ),
                _buildMetricCard(
                  Icons.restaurant,
                  'Nafsu Makan',
                  kondisi.nafsuMakan ?? '-',
                  _getAppetiteColor(kondisi.nafsuMakan ?? ''),
                ),
                _buildMetricCard(
                  Icons.medication,
                  'Kepatuhan Obat',
                  kondisi.statusObat ?? '-',
                  _getMedicationColor(kondisi.statusObat ?? ''),
                ),
              ],
            ),
            // Status kesehatan
            if (kondisi.status != null && kondisi.status!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(kondisi.status!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(kondisi.status!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(kondisi.status!),
                        color: _getStatusColor(kondisi.status!),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Kesehatan: ${kondisi.status!}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(kondisi.status!),
                              ),
                            ),
                            if (kondisi.catatan != null && kondisi.catatan!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  kondisi.catatan!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
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
            // Catatan perawat
            if (kondisi.catatan != null && kondisi.catatan!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catatan Perawat:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kondisi.catatan!,
                        style: const TextStyle(fontSize: 14),
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

  Widget _buildMetricCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatKesehatan(List<KondisiHarian> riwayat) {
    return Column(
      children: riwayat.map((kondisi) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(kondisi.status ?? 'Stabil').withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _getStatusIcon(kondisi.status ?? 'Stabil'),
                color: _getStatusColor(kondisi.status ?? 'Stabil'),
              ),
            ),
            title: Text(
              _formatDate(kondisi.tanggal),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Detak: ${kondisi.nadi} bpm • TD: ${kondisi.tekananDarah}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (kondisi.catatan != null && kondisi.catatan!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      kondisi.catatan!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(kondisi.status ?? 'Stabil'),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                kondisi.status ?? 'Stabil',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              _showKondisiDetail(kondisi);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingSection(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF9C6223),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'stabil':
        return Colors.green;
      case 'baik':
        return Colors.green;
      case 'sedang':
        return Colors.orange;
      case 'kurang baik':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'stabil':
        return Icons.check_circle;
      case 'baik':
        return Icons.thumb_up;
      case 'sedang':
        return Icons.warning;
      case 'kurang baik':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getHeartRateColor(int bpm) {
    if (bpm < 60) return Colors.orange;
    if (bpm > 100) return Colors.red;
    return Colors.green;
  }

  Color _getBloodPressureColor(String bp) {
    if (bp.contains('/')) {
      final parts = bp.split('/');
      if (parts.length == 2) {
        final systolic = int.tryParse(parts[0].trim()) ?? 0;
        if (systolic > 140) return Colors.red;
        if (systolic < 90) return Colors.orange;
      }
    }
    return Colors.green;
  }

  Color _getAppetiteColor(String appetite) {
    switch (appetite.toLowerCase()) {
      case 'baik':
        return Colors.green;
      case 'sedang':
        return Colors.orange;
      case 'kurang':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getMedicationColor(String medication) {
    switch (medication.toLowerCase()) {
      case 'teratur':
        return Colors.green;
      case 'lupa sekali':
        return Colors.orange;
      case 'tidak teratur':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final inputDate = DateTime(date.year, date.month, date.day);

    if (inputDate == today) {
      return 'Hari ini';
    } else if (inputDate == yesterday) {
      return 'Kemarin';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showKondisiDetail(KondisiHarian kondisi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Kondisi'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: const Text('Tanggal'),
                subtitle: Text(_formatDate(kondisi.tanggal)),
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('Detak Jantung'),
                subtitle: Text('${kondisi.nadi} bpm'),
              ),
              ListTile(
                leading: const Icon(Icons.monitor_heart, color: Colors.purple),
                title: const Text('Tekanan Darah'),
                subtitle: Text(kondisi.tekananDarah ?? '-'),
              ),
              ListTile(
                leading: const Icon(Icons.restaurant, color: Colors.green),
                title: const Text('Nafsu Makan'),
                subtitle: Text(kondisi.nafsuMakan ?? '-'),
              ),
              ListTile(
                leading: const Icon(Icons.medication, color: Colors.orange),
                title: const Text('Status Obat'),
                subtitle: Text(kondisi.statusObat ?? '-'),
              ),
              if (kondisi.catatan != null && kondisi.catatan!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.note, color: Colors.brown),
                  title: const Text('Catatan'),
                  subtitle: Text(kondisi.catatan!),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}