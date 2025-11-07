import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/halaman/services/biodata_service.dart';
import 'detail_lansia_screen.dart';

class DataLansiaScreen extends StatefulWidget {
  const DataLansiaScreen({super.key});

  @override
  State<DataLansiaScreen> createState() => _DataLansiaScreenState();
}

class _DataLansiaScreenState extends State<DataLansiaScreen> {
  final BiodataService _biodataService = BiodataService();
  List<Datalansia> _lansiaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBiodata();
  }

  Future<void> _loadBiodata() async {
    try {
      final data = await _biodataService.fetchAllDataLansia();
      setState(() {
        _lansiaList = data;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat data lansia: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Master Lansia'),
        backgroundColor: const Color(0xFF9C6223),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lansiaList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Belum ada data lansia'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _lansiaList.length,
                  itemBuilder: (context, index) {
                    final lansia = _lansiaList[index];
                    final status = lansia.statusLansia ?? 'Belum Ada Data';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF9C6223),
                          child: Text(
                            lansia.namaLansia.isNotEmpty
                                ? lansia.namaLansia[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          lansia.namaLansia,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${lansia.umurLansia ?? '-'} tahun - Kamar ${lansia.noKamarLansia ?? '-'}'),
                            Text(
                                'Penanggung Jawab: ${lansia.namaAnak ?? '-'}'),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: status == 'Stabil'
                                    ? Colors.green.withOpacity(0.1)
                                    : status == 'Perlu Perhatian'
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Status: $status',
                                style: TextStyle(
                                  color: status == 'Stabil'
                                      ? Colors.green
                                      : status == 'Perlu Perhatian'
                                          ? Colors.orange
                                          : Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailLansiaScreen(
                                biodata: lansia,
                                kamar: lansia.noKamarLansia ?? '-',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
