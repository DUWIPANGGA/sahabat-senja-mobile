import 'package:flutter/material.dart';

class LaporanHarianScreen extends StatelessWidget {
  const LaporanHarianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final laporanList = [
      {'tanggal': '15 Nov 2023', 'lansia': 'Ibu Rusi', 'status': 'Selesai', 'catatan': 'Kondisi stabil'},
      {'tanggal': '15 Nov 2023', 'lansia': 'Pak Budi', 'status': 'Selesai', 'catatan': 'Perlu perhatian khusus'},
      {'tanggal': '14 Nov 2023', 'lansia': 'Ibu Siti', 'status': 'Selesai', 'catatan': 'Makan lancar'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Harian'), backgroundColor: const Color(0xFF9C6223)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.calendar_today), label: const Text('Pilih Tanggal'), onPressed: () {})),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.download), label: const Text('Export PDF'), onPressed: () {})),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: laporanList.length,
                itemBuilder: (context, index) {
                  final laporan = laporanList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.assignment, color: Colors.blue),
                      title: Text('Laporan ${laporan['lansia']}'),
                      subtitle: Text('Tanggal: ${laporan['tanggal']} - ${laporan['catatan']}'),
                      trailing: Chip(label: Text(laporan['status']!), backgroundColor: laporan['status'] == 'Selesai' ? Colors.green : Colors.orange),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}