import 'package:flutter/material.dart';

class JadwalObatScreen extends StatefulWidget {
  const JadwalObatScreen({super.key});

  @override
  State<JadwalObatScreen> createState() => _JadwalObatScreenState();
}

class _JadwalObatScreenState extends State<JadwalObatScreen> {
  List<Map<String, dynamic>> jadwalObat = [
    {
      'nama': 'Obat Hipertensi',
      'dosis': '1x sehari',
      'waktu': 'Pagi',
      'lansia': 'Ibu Rusi',
      'completed': false,
      'lastGiven': null,
    },
    {
      'nama': 'Vitamin D',
      'dosis': '2x sehari',
      'waktu': 'Pagi & Malam',
      'lansia': 'Pak Budi',
      'completed': false,
      'lastGiven': null,
    },
    {
      'nama': 'Obat Diabetes',
      'dosis': '3x sehari',
      'waktu': 'Setelah makan',
      'lansia': 'Ibu Siti',
      'completed': false,
      'lastGiven': null,
    },
  ];

  void _markAsGiven(int index) {
    setState(() {
      jadwalObat[index]['completed'] = true;
      jadwalObat[index]['lastGiven'] = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalObat = jadwalObat.length;
    final sudahDiberikan =
        jadwalObat.where((obat) => obat['completed'] == true).length;
    final belumDiberikan = totalObat - sudahDiberikan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Obat Lansia'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Statistik
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                      'Total Obat', totalObat.toString(), Colors.blue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSummaryCard(
                      'Belum Diberikan', belumDiberikan.toString(), Colors.orange),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSummaryCard(
                      'Sudah Diberikan', sudahDiberikan.toString(), Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Daftar Obat
            Expanded(
              child: ListView.builder(
                itemCount: jadwalObat.length,
                itemBuilder: (context, index) {
                  final obat = jadwalObat[index];
                  return _buildObatCard(obat, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObatCard(Map<String, dynamic> obat, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          Icons.medication,
          color: obat['completed'] ? Colors.green : Colors.purple,
        ),
        title: Text(
          obat['nama'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dosis: ${obat['dosis']}'),
            Text('Waktu: ${obat['waktu']}'),
            Text('Untuk: ${obat['lansia']}'),
            if (obat['lastGiven'] != null)
              Text(
                'Terakhir: ${_formatTime(obat['lastGiven'])}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!obat['completed'])
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => _markAsGiven(index),
                tooltip: 'Tandai sudah diberikan',
              ),
            Icon(
              obat['completed'] ? Icons.check_circle : Icons.pending,
              color: obat['completed'] ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
