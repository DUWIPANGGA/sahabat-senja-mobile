import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/models/kondisi_model.dart';
import 'package:sahabatsenja_app/services/datalansia_service.dart';
import 'package:sahabatsenja_app/services/kondisi_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KesehatanScreen extends StatefulWidget {
  const KesehatanScreen({super.key});

  @override
  State<KesehatanScreen> createState() => _KesehatanScreenState();
}

class _KesehatanScreenState extends State<KesehatanScreen> {
  final DatalansiaService _datalansiaService = DatalansiaService();
  final KondisiService _kondisiService = KondisiService();

  List<Datalansia> _lansiaTerhubung = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 🔹 Ambil email user dari SharedPreferences
  Future<void> _loadUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userEmail = prefs.getString('user_email');
      debugPrint('📧 User email: $_userEmail');
    } catch (e) {
      debugPrint('❌ Error load email: $e');
    }
  }

  /// 🔹 Ambil data lansia berdasarkan email user yang login
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _loadUserEmail();
      
      if (_userEmail != null && _userEmail!.isNotEmpty) {
        // Ambil data lansia berdasarkan email keluarga
        final dataLansia = await _datalansiaService.getDatalansiaByKeluarga(_userEmail!);
        
        debugPrint('📊 Data lansia ditemukan: ${dataLansia.length} item');
        
        setState(() {
          _lansiaTerhubung = dataLansia;
        });
      } else {
        setState(() {
          _errorMessage = 'Silakan login terlebih dahulu';
        });
        debugPrint('⚠️ User belum login atau email tidak ditemukan');
      }
    } catch (e) {
      debugPrint('❌ Error ambil data lansia: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
      });
    }

    setState(() => _isLoading = false);
  }

  /// 🔹 Refresh data
  Future<void> _refreshData() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kesehatan Lansia'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildErrorState()
              : _lansiaTerhubung.isEmpty
                  ? _buildEmptyState()
                  : _buildLansiaList(),
    );
  }

  Widget _buildLoading() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data kesehatan...'),
          ],
        ),
      );

  Widget _buildErrorState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Terjadi kesalahan',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Data Lansia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Anda belum memiliki data lansia yang terhubung\n\n'
                'Email login Anda: $_userEmail',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh Data'),
            ),
          ],
        ),
      );

// Di file KesehatanScreen.dart - PERBAIKAN FUTUREBUILDER
Widget _buildLansiaList() {
  return RefreshIndicator(
    onRefresh: _refreshData,
    child: ListView.builder(
      itemCount: _lansiaTerhubung.length,
      itemBuilder: (context, index) {
        final lansia = _lansiaTerhubung[index];
        final namaLansia = lansia.namaLansia ?? 'Tanpa Nama';

        return FutureBuilder<KondisiHarian?>(
          future: _kondisiService.getTodayDataWithFallback(namaLansia), // Gunakan fallback
          builder: (context, snapshot) {
            // Debug snapshot state
            print('🔍 Snapshot state: ${snapshot.connectionState}');
            print('🔍 Snapshot hasData: ${snapshot.hasData}');
            print('🔍 Snapshot hasError: ${snapshot.hasError}');
            if (snapshot.hasError) {
              print('🔍 Snapshot error: ${snapshot.error}');
              print('🔍 Snapshot stack: ${snapshot.stackTrace}');
            }
            if (snapshot.hasData) {
              print('🔍 Snapshot data: ${snapshot.data?.toJson()}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard(lansia);
            }

            if (snapshot.hasError) {
              return _buildErrorCard(lansia, snapshot.error.toString());
            }

            // PERBAIKAN: Handle null data dengan lebih baik
            final kondisi = snapshot.data;
            if (kondisi == null || kondisi.id == null) {
              // Jika data null atau tidak valid, tampilkan card tanpa data
              return _buildLansiaCard(lansia, null);
            }
            
            return _buildLansiaCard(lansia, kondisi);
          },
        );
      },
    ),
  );
}

// Tambahkan method untuk debugging API
Future<void> _debugApi() async {
  await _kondisiService.debugEndpoint('kondisi/today/didi/2025-12-05');
  await _kondisiService.debugEndpoint('kondisi');
  await _kondisiService.debugEndpoint('kondisi/hari-ini');
}
  Widget _buildLoadingCard(Datalansia lansia) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, color: Colors.grey[500]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lansia.namaLansia ?? 'Tanpa Nama',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lansia.umurLansia ?? '-'} tahun',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(Datalansia lansia, String error) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red[100],
                  child: Icon(Icons.error, color: Colors.red[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lansia.namaLansia ?? 'Tanpa Nama',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Gagal memuat data kesehatan',
              style: TextStyle(color: Colors.red[700]),
            ),
            Text(
              'Error: ${error.length > 50 ? '${error.substring(0, 50)}...' : error}',
              style: TextStyle(color: Colors.red[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLansiaCard(Datalansia lansia, KondisiHarian? kondisi) {
    final status = kondisi?.status ?? 'Belum Diperiksa';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan informasi lansia
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.person, color: Colors.green[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lansia.namaLansia ?? 'Tanpa Nama',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${lansia.umurLansia ?? '-'} tahun | ${lansia.jenisKelaminLansia ?? '-'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (lansia.alamatLengkap != null && lansia.alamatLengkap!.isNotEmpty)
                        Text(
                          lansia.alamatLengkap!,
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Data kesehatan jika ada
            kondisi != null 
                ? _buildHealthData(kondisi)
                : _buildNoHealthData(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthData(KondisiHarian kondisi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 Kondisi Kesehatan Hari Ini',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 12),

        // Metrics Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _buildMetricItem('🩸', 'Tekanan Darah', kondisi.tekananDarah ?? '-'),
            _buildMetricItem('❤️', 'Nadi', kondisi.nadi != null ? '${kondisi.nadi} BPM' : '-'),
            _buildMetricItem('🍽️', 'Nafsu Makan', kondisi.nafsuMakan ?? '-'),
            _buildMetricItem('💊', 'Status Obat', kondisi.statusObat ?? '-'),
          ],
        ),

        // Catatan jika ada
        if (kondisi.catatan != null && kondisi.catatan!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.note, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 8),
                     Text(
                      'Catatan Perawat',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  kondisi.catatan!,
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Tanggal pemeriksaan
        const SizedBox(height: 12),
        Text(
          'Tanggal: ${kondisi.tanggal ?? '-'}',
          style: TextStyle(color: Colors.grey[600], fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildNoHealthData() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada data kesehatan untuk hari ini',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Perawat belum melakukan pemeriksaan',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String emoji, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[100]!, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                value,
                style:   TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'stabil':
        return Colors.green;
      case 'perlu perhatian':
        return Colors.orange;
      case 'kritis':
        return Colors.red;
      case 'belum diperiksa':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}