import 'package:flutter/material.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final List<Map<String, dynamic>> _healthData = [
    {
      'title': 'Tekanan Darah',
      'value': '120/80 mmHg',
      'status': 'Normal',
      'color': Colors.green,
      'icon': Icons.monitor_heart,
      'lastCheck': 'Hari ini, 08:00',
    },
    {
      'title': 'Detak Jantung',
      'value': '72 bpm',
      'status': 'Normal',
      'color': Colors.green,
      'icon': Icons.favorite,
      'lastCheck': 'Hari ini, 08:00',
    },
    {
      'title': 'Kadar Gula Darah',
      'value': '110 mg/dL',
      'status': 'Normal',
      'color': Colors.green,
      'icon': Icons.bloodtype,
      'lastCheck': 'Kemarin, 07:30',
    },
    {
      'title': 'Berat Badan',
      'value': '65 kg',
      'status': 'Stabil',
      'color': Colors.blue,
      'icon': Icons.monitor_weight,
      'lastCheck': '2 hari lalu',
    },
  ];

  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Obat Hipertensi',
      'dosage': '1x sehari',
      'time': 'Pagi',
      'taken': true,
    },
    {
      'name': 'Vitamin D',
      'dosage': '1x sehari',
      'time': 'Pagi',
      'taken': true,
    },
    {
      'name': 'Obat Diabetes',
      'dosage': '2x sehari',
      'time': 'Pagi & Malam',
      'taken': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kesehatan Lansia'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            _buildHeaderInfo(),
            const SizedBox(height: 24),

            // Monitoring Kesehatan
            _buildHealthMonitoring(),
            const SizedBox(height: 24),

            // Jadwal Obat
            _buildMedicationSchedule(),
            const SizedBox(height: 24),

            // Tips Kesehatan
            _buildHealthTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Card(
      elevation: 2,
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
              child: Icon(Icons.health_and_safety, color: Colors.green[700], size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kondisi Kesehatan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Terakhir diperiksa: Hari ini, 08:00',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Kondisi Stabil',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMonitoring() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monitoring Kesehatan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _healthData.length,
          itemBuilder: (context, index) {
            final data = _healthData[index];
            return _buildHealthCard(data);
          },
        ),
      ],
    );
  }

  Widget _buildHealthCard(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: data['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(data['icon'], color: data['color'], size: 16),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: data['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data['status'],
                    style: TextStyle(
                      color: data['color'],
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data['title'],
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              data['value'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data['lastCheck'],
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jadwal Obat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Lihat Semua',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._medications.map((med) => _buildMedicationItem(med)),
      ],
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> med) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: med['taken'] ? Colors.green[100] : Colors.orange[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            med['taken'] ? Icons.check_circle : Icons.schedule,
            color: med['taken'] ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(med['name']),
        subtitle: Text('${med['dosage']} • ${med['time']}'),
        trailing: Text(
          med['taken'] ? 'Sudah' : 'Belum',
          style: TextStyle(
            color: med['taken'] ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHealthTips() {
    final tips = [
      'Minum air putih minimal 8 gelas per hari',
      'Olahraga ringan 30 menit setiap pagi',
      'Istirahat yang cukup 7-8 jam per hari',
      'Konsumsi makanan bergizi seimbang',
      'Periksa kesehatan rutin setiap bulan',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tips Kesehatan Lansia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...tips.map((tip) => _buildTipItem(tip)),
      ],
    );
  }

  Widget _buildTipItem(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.green[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.green[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}