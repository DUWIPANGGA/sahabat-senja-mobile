import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/services/jadwal_obat_service.dart';
import 'package:sahabatsenja_app/models/jadwal_obat_model.dart';

class JadwalObatScreen extends StatefulWidget {
  final int datalansiaId;

  const JadwalObatScreen({super.key, required this.datalansiaId});

  @override
  State<JadwalObatScreen> createState() => _JadwalObatScreenState();
}

class _JadwalObatScreenState extends State<JadwalObatScreen> {
  final JadwalObatService service = JadwalObatService();
  List<JadwalObat> jadwal = [];
  bool isLoading = true;

  // Filter
  String filterWaktu = "Semua";

  // form input
  final TextEditingController namaObatC = TextEditingController();
  final TextEditingController dosisC = TextEditingController();
  String? waktuSelected;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future fetchData() async {
    setState(() => isLoading = true);
    jadwal = await service.fetchJadwalObat(widget.datalansiaId);
    setState(() => isLoading = false);
  }

  Future tambahObat() async {
    if (namaObatC.text.isEmpty || dosisC.text.isEmpty || waktuSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Semua data harus diisi")),
      );
      return;
    }

    bool success = await service.tambahJadwalObat(
      datalansiaId: widget.datalansiaId,
      namaObat: namaObatC.text,
      dosis: dosisC.text,
      waktu: waktuSelected!,
    );

    if (success) {
      Navigator.pop(context);
      namaObatC.clear();
      dosisC.clear();
      waktuSelected = null;
      fetchData();
    }
  }

  Future updateStatus(int id, bool value) async {
    await service.updateStatus(id, value);
    fetchData();
  }

  Future deleteObat(int id) async {
    await service.deleteJadwalObat(id);
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    // 🔎 Filter jadwal sesuai pilihan
    final jadwalFiltered = filterWaktu == "Semua"
        ? jadwal
        : jadwal.where((j) => j.waktu == filterWaktu).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Jadwal Obat"),
        backgroundColor: Colors.teal,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
        onPressed: openAddDialog,
      ),

      body: Column(
        children: [
          // 🔽 WIDGET FILTER
          Padding(
            padding: EdgeInsets.all(16),
            child: DropdownButtonFormField(
              value: filterWaktu,
              decoration: InputDecoration(
                labelText: "Filter Waktu",
                border: OutlineInputBorder(),
              ),
              items: ["Semua", "Pagi", "Siang", "Sore", "Malam"]
                  .map((w) => DropdownMenuItem(
                        value: w,
                        child: Text(w),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() => filterWaktu = val!);
              },
            ),
          ),

          // 🔹 ISI LIST DATA
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : jadwalFiltered.isEmpty
                    ? Center(child: Text("Belum ada jadwal obat"))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: jadwalFiltered.length,
                        itemBuilder: (context, index) {
                          final item = jadwalFiltered[index];

                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Checkbox(
                                value: item.completed,
                                onChanged: (val) =>
                                    updateStatus(item.id, val!),
                              ),
                              title: Text(
                                item.namaObat,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: item.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle:
                                  Text("${item.dosis} • ${item.waktu}"),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteObat(item.id),
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

  // 🔹 POPUP TAMBAH OBAT
  void openAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Jadwal Obat"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: namaObatC,
                  decoration: InputDecoration(
                    labelText: "Nama Obat",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: dosisC,
                  decoration: InputDecoration(
                    labelText: "Dosis",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: "Waktu",
                    border: OutlineInputBorder(),
                  ),
                  value: waktuSelected,
                  items: ["Pagi", "Siang", "Sore", "Malam"]
                      .map((w) => DropdownMenuItem(
                            child: Text(w),
                            value: w,
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => waktuSelected = val.toString());
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: tambahObat,
              child: Text("Simpan"),
            )
          ],
        );
      },
    );
  }
}
