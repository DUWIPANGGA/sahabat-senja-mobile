import 'package:flutter/material.dart';

class TrackingObatScreen extends StatefulWidget {
  const TrackingObatScreen({super.key});

  @override
  State<TrackingObatScreen> createState() => _TrackingObatScreenState();
}

class _TrackingObatScreenState extends State<TrackingObatScreen> {
  List<Map<String, dynamic>> trackingData = [
    {
      'obat': 'Obat Hipertensi',
      'lansia': 'Ibu Rusi',
      'waktu': '08:00',
      'status': 'Sudah',
      'tanggal': DateTime.now(),
      'completed': true,
    },
    {
      'obat': 'Vitamin D',
      'lansia': 'Pak Budi',
      'waktu': '10:00',
      'status': 'Belum',
      'tanggal': DateTime.now(),
      'completed': false,
    },
    {
      'obat': 'Obat Diabetes',
      'lansia': 'Ibu Siti',
      'waktu': '12:00',
      'status': 'Sudah',
      'tanggal': DateTime.now(),
      'completed': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final totalObat = trackingData.length;
    final sudahDiberikan =
        trackingData.where((data) => data['completed'] == true).length;
    final belumDiberikan = totalObat - sudahDiberikan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Obat Lansia'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Statistik
            Card(
              color: const Color(0xFF9C6223),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTrackingStat('Total', totalObat.toString()),
                    _buildTrackingStat('Sudah', sudahDiberikan.toString()),
                    _buildTrackingStat('Belum', belumDiberikan.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Filter Chips
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: const Text('Semua'),
                    selected: true,
                    onSelected: (bool value) {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilterChip(
                    label: const Text('Sudah'),
                    selected: false,
                    onSelected: (bool value) {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilterChip(
                    label: const Text('Belum'),
                    selected: false,
                    onSelected: (bool value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Daftar Tracking
            Expanded(
              child: trackingData.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medication, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada data tracking',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: trackingData.length,
                      itemBuilder: (context, index) {
                        final data = trackingData[index];
                        return _buildTrackingCard(data);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildTrackingCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          Icons.medication,
          color: data['completed'] ? Colors.green : Colors.red,
        ),
        title: Text(data['obat']),
        subtitle: Text(
          '${data['lansia']} - ${data['waktu']} - ${_formatDate(data['tanggal'])}',
        ),
        trailing: Chip(
          label: Text(
            data['status'],
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: data['completed'] ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
