import 'package:flutter/material.dart';

class JadwalAktivitasScreen extends StatefulWidget {
  const JadwalAktivitasScreen({super.key});

  @override
  State<JadwalAktivitasScreen> createState() => _JadwalAktivitasScreenState();
}

class _JadwalAktivitasScreenState extends State<JadwalAktivitasScreen> {
  List<Map<String, dynamic>> aktivitasList = [
    {
      'waktu': '08:00 - 09:00',
      'judul': 'SENAM PAGI',
      'deskripsi': 'Senam ringan untuk lansia',
      'lokasi': 'Lapangan Utama',
      'peserta': 'Semua penghuni',
      'completed': true,
      'tanggal': DateTime.now(),
    },
    {
      'waktu': '10:00 - 11:00',
      'judul': 'TERAPI FISIK',
      'deskripsi': 'Pijat dan stretching',
      'lokasi': 'Ruang Terapi',
      'peserta': 'Kelompok A',
      'completed': false,
      'tanggal': DateTime.now(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final totalAktivitas = aktivitasList.length;
    final selesai = aktivitasList.where((a) => a['completed'] == true).length;
    final belumSelesai = totalAktivitas - selesai;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Aktivitas Panti'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Center(
              child: Column(
                children: [
                  const Text(
                    'JADWAL AKTIVITAS PANTI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_getHariIni()}, ${_getTanggalHariIni()}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // STATISTIK
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Aktivitas', totalAktivitas.toString(), Colors.blue)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('Selesai', selesai.toString(), Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('Belum Selesai', belumSelesai.toString(), Colors.orange)),
              ],
            ),
            const SizedBox(height: 20),

            // LIST AKTIVITAS
            Expanded(
              child: aktivitasList.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada aktivitas',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: aktivitasList.length,
                      itemBuilder: (context, index) {
                        final aktivitas = aktivitasList[index];
                        return _buildAktivitasCard(aktivitas, index);
                      },
                    ),
            ),

            // TOMBOL TAMBAH
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text(
                  'TAMBAH AKTIVITAS BARU',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C6223),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => _showTambahAktivitasDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAktivitasCard(Map<String, dynamic> aktivitas, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WAKTU DAN CHECKBOX
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  aktivitas['waktu'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    aktivitas['judul'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Checkbox(
                  value: aktivitas['completed'],
                  onChanged: (value) {
                    setState(() {
                      aktivitasList[index]['completed'] = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text('📝 ${aktivitas['deskripsi']}', style: const TextStyle(fontFamily: 'Poppins')),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(aktivitas['lokasi'], style: const TextStyle(fontFamily: 'Poppins')),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.purple),
                const SizedBox(width: 4),
                Text(aktivitas['peserta'], style: const TextStyle(fontFamily: 'Poppins')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTambahAktivitasDialog(BuildContext context) {
    final waktuController = TextEditingController();
    final judulController = TextEditingController();
    final deskripsiController = TextEditingController();
    final lokasiController = TextEditingController();
    final pesertaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Aktivitas Baru', style: TextStyle(fontFamily: 'Poppins')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField('Waktu (contoh: 08:00 - 09:00)', waktuController),
              _buildInputField('Judul Aktivitas', judulController),
              _buildInputField('Deskripsi', deskripsiController),
              _buildInputField('Lokasi', lokasiController),
              _buildInputField('Peserta', pesertaController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            onPressed: () {
              if (waktuController.text.isNotEmpty && judulController.text.isNotEmpty) {
                setState(() {
                  aktivitasList.add({
                    'waktu': waktuController.text,
                    'judul': judulController.text,
                    'deskripsi': deskripsiController.text,
                    'lokasi': lokasiController.text,
                    'peserta': pesertaController.text,
                    'completed': false,
                    'tanggal': DateTime.now(),
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Aktivitas baru berhasil ditambahkan!',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C6223),
            ),
            child: const Text('Tambah', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }

  String _getHariIni() {
    const hari = [
      'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
    ];
    return hari[DateTime.now().weekday % 7]; // biar gak error index
  }

  String _getTanggalHariIni() {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final now = DateTime.now();
    return '${now.day} ${bulan[now.month]} ${now.year}';
  }
}
