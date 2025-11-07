// screens/keluarga/detail_health_screen.dart
import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/models/kondisi_model.dart';
import 'package:sahabatsenja_app/halaman/services/kondisi_service.dart';

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

  @override
  void initState() {
    super.initState();
    _kondisiHariIni = _kondisiService.getTodayData(widget.lansia.namaLansia);
    _riwayatKondisi = _kondisiService.fetchRiwayatByNama(widget.lansia.namaLansia);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kesehatan ${widget.lansia.namaLansia}'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('Belum ada kondisi hari ini');
                } else {
                  return _buildKondisiTerkini(snapshot.data!);
                }
              },
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<KondisiHarian>>(
              future: _riwayatKondisi,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Belum ada riwayat kesehatan');
                } else {
                  return _buildRiwayatKesehatan(snapshot.data!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLansiaInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.green[700], size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lansia.namaLansia,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('${widget.lansia.umurLansia} tahun'),
                  Text('Riwayat: ${widget.lansia.riwayatPenyakitLansia ?? '-'}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKondisiTerkini(KondisiHarian kondisi) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kondisi Hari Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCard('🩸', 'Tekanan Darah', kondisi.tekananDarah),
                _buildMetricCard('❤️', 'Nadi', '${kondisi.nadi} bpm'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCard('🍽️', 'Nafsu Makan', kondisi.nafsuMakan),
                _buildMetricCard('💊', 'Status Obat', kondisi.statusObat),
              ],
            ),
            if ((kondisi.catatan ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
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
                    Text(kondisi.catatan ?? ''),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String emoji, String title, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatKesehatan(List<KondisiHarian> riwayat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat 7 Hari Terakhir',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: riwayat.take(7).map(_buildRiwayatItem).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatItem(KondisiHarian kondisi) {
  final parsedDate = kondisi.tanggal; 

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(kondisi.status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              kondisi.status,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(parsedDate),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text('${kondisi.tekananDarah} • ${kondisi.nadi} bpm'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    return status == 'Stabil' ? Colors.green : Colors.orange;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
