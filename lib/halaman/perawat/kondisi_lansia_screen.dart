import 'package:flutter/material.dart';
import '../services/kondisi_service.dart';
import 'package:sahabatsenja_app/models/kondisi_model.dart';

class KondisiLansiaScreen extends StatefulWidget {
  const KondisiLansiaScreen({super.key});

  @override
  State<KondisiLansiaScreen> createState() => _KondisiLansiaScreenState();
}

class _KondisiLansiaScreenState extends State<KondisiLansiaScreen> {
  DateTime? selectedDate;
  String filterStatus = 'Semua';
  final KondisiService _kondisiService = KondisiService();

  List<KondisiHarian> semuaKondisi = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKondisi();
  }

  Future<void> _loadKondisi() async {
    setState(() => isLoading = true);
    try {
      // Ganti ID sesuai lansia yang ingin diambil (sementara contoh 1)
      final data = await _kondisiService.fetchRiwayatById(1);
      setState(() {
        semuaKondisi = data;
      });
    } catch (e) {
      print('⚠️ Error load kondisi: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<KondisiHarian> get filteredLansia {
    List<KondisiHarian> data = semuaKondisi;

    if (selectedDate != null) {
      data = data
          .where((e) =>
              e.tanggal.year == selectedDate!.year &&
              e.tanggal.month == selectedDate!.month &&
              e.tanggal.day == selectedDate!.day)
          .toList();
    }

    if (filterStatus != 'Semua') {
      data = data.where((e) => e.status == filterStatus).toList();
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = filteredLansia;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Kondisi Lansia'),
        backgroundColor: const Color(0xFF9C6223),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            selectedDate == null
                                ? 'Pilih Tanggal'
                                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: filterStatus,
                          items: ['Semua', 'Stabil', 'Perlu Perhatian']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              filterStatus = value!;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Status',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Summary Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildSummaryCard('Total', semuaKondisi.length, Colors.blue),
                      const SizedBox(width: 10),
                      _buildSummaryCard(
                          'Stabil',
                          semuaKondisi.where((l) => l.status == 'Stabil').length,
                          Colors.green),
                      const SizedBox(width: 10),
                      _buildSummaryCard(
                          'Perhatian',
                          semuaKondisi
                              .where((l) => l.status == 'Perlu Perhatian')
                              .length,
                          Colors.orange),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Data List
                Expanded(
                  child: filteredData.isEmpty
                      ? const Center(
                          child: Text('Tidak ada data untuk ditampilkan'),
                        )
                      : ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final lansia = filteredData[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: lansia.status == 'Stabil'
                                              ? Colors.green
                                              : Colors.orange,
                                          child: const Icon(Icons.favorite,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Tanggal: ${lansia.tanggal.day}/${lansia.tanggal.month}/${lansia.tanggal.year}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Chip(
                                          label: Text(lansia.status),
                                          backgroundColor:
                                              lansia.status == 'Stabil'
                                                  ? Colors.green
                                                  : Colors.orange,
                                          labelStyle: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text('Tekanan Darah: ${lansia.tekananDarah}'),
                                    Text('Nadi: ${lansia.nadi} bpm'),
                                    Text('Nafsu Makan: ${lansia.nafsuMakan}'),
                                    Text('Status Obat: ${lansia.statusObat}'),
                                    if (lansia.catatan != null && lansia.catatan!.isNotEmpty)
                                      Text('Catatan: ${lansia.catatan}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(String title, int value, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
