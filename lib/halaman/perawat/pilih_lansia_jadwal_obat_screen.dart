import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/services/biodata_service.dart';
import 'jadwal_obat_screen.dart';

class PilihLansiaJadwalObatScreen extends StatefulWidget {
  const PilihLansiaJadwalObatScreen({super.key});

  @override
  State<PilihLansiaJadwalObatScreen> createState() =>
      _PilihLansiaJadwalObatScreenState();
}

class _PilihLansiaJadwalObatScreenState
    extends State<PilihLansiaJadwalObatScreen> {
  final BiodataService _biodataService = BiodataService();
  List<Datalansia> _lansiaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLansia();
  }

  Future<void> loadLansia() async {
    try {
      final data = await _biodataService.fetchAllDataLansia();
      setState(() {
        _lansiaList = data;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error load lansia: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C6223),
        title: const Text("Pilih Lansia untuk Jadwal Obat"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _lansiaList.length,
              itemBuilder: (context, index) {
                final lansia = _lansiaList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(lansia.namaLansia),
                    subtitle: Text("Kamar ${lansia.noKamarLansia ?? '-'}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              JadwalObatScreen(datalansiaId: lansia.id!,namaLansia: lansia.namaLansia,),
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
