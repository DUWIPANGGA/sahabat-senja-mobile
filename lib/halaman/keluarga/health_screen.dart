// screens/keluarga/health_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/models/kondisi_model.dart';
import 'package:sahabatsenja_app/halaman/services/biodata_service.dart';
import 'package:sahabatsenja_app/halaman/services/kondisi_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final BiodataService _biodataService = BiodataService();
  final KondisiService _kondisiService = KondisiService();

  List<Datalansia> _lansiaTerhubung = [];
  bool _isLoading = true;
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    _currentUserName = user?.displayName;

    if (_currentUserName != null) {
    _lansiaTerhubung =
        await _biodataService.getBiodataByKeluarga(_currentUserName!);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kesehatan Lansia'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? _buildLoading()
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
                'Tambahkan data lansia melalui menu "Tambah Lansia" di bawah',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );

Widget _buildLansiaList() {
  return ListView.builder(
    itemCount: _lansiaTerhubung.length,
    itemBuilder: (context, index) {
      final lansia = _lansiaTerhubung[index];

      return FutureBuilder<KondisiHarian?>(
        future: _kondisiService.getTodayData(lansia.namaLansia),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal memuat data kondisi: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final kondisi = snapshot.data;
          return _buildLansiaCard(lansia, kondisi);
        },
      );
    },
  );
}

  Widget _buildLansiaCard(Datalansia lansia, KondisiHarian? kondisi) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama dan status
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
                        lansia.namaLansia,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${lansia.umurLansia ?? '-'} tahun',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Alamat: ${lansia.alamatLengkap ?? '-'}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(kondisi?.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    kondisi?.status ?? 'Belum Diperiksa',
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

            // Data kesehatan
            if (kondisi != null)
              _buildHealthData(kondisi)
            else
              _buildNoHealthData(),
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
          'Kondisi Kesehatan Hari Ini',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricItem('🩸', 'Tekanan Darah', kondisi.tekananDarah),
            _buildMetricItem('❤️', 'Detak Jantung', '${kondisi.nadi} BPM'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricItem('🍽️', 'Nafsu Makan', kondisi.nafsuMakan),
            _buildMetricItem('💊', 'Status Obat', kondisi.statusObat),
          ],
        ),
        if (kondisi != null && (kondisi.catatan?.isNotEmpty ?? false)) ...[
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
                  kondisi.catatan ?? '',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          Icon(Icons.info, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Belum ada data kesehatan untuk hari ini',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String icon, String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Stabil':
        return Colors.green;
      case 'Perlu Perhatian':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
