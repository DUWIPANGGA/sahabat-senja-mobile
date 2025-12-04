import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/services/biodata_service.dart';
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
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBiodata();
  }

  Future<void> _loadBiodata() async {
    try {
      print('🔄 Memulai load data lansia...');
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final data = await _biodataService.fetchAllDataLansia();
      
      print('✅ Data berhasil di-load: ${data.length} items');
      
      setState(() {
        _lansiaList = data;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error dalam _loadBiodata: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: $e';
        _lansiaList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Master Lansia'),
        backgroundColor: const Color(0xFF9C6223),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBiodata,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF9C6223)),
            SizedBox(height: 16),
            Text('Memuat data lansia...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBiodata,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6223),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_lansiaList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada data lansia',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Data akan muncul setelah lansia terdaftar',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBiodata,
      color: const Color(0xFF9C6223),
      child: ListView.builder(
        itemCount: _lansiaList.length,
        itemBuilder: (context, index) {
          final lansia = _lansiaList[index];
          final status = lansia.statusLansia ?? 'Belum Ada Data';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  Text('${lansia.umurLansia ?? '-'} tahun - Kamar ${lansia.noKamarLansia ?? '-'}'),
                  Text('Penanggung Jawab: ${lansia.namaAnak ?? '-'}'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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