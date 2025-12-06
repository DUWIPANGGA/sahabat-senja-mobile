import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/perawat/manage_obat_screen.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/services/biodata_service.dart';
import 'jadwal_obat_main_screen.dart'; // Screen obat hari ini

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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLansia();
  }

  Future<void> _loadLansia() async {
    try {
      final data = await _biodataService.fetchAllDataLansia();
      setState(() {
        _lansiaList = data;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error load lansia: $e");
      setState(() => _isLoading = false);
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data lansia: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Datalansia> get _filteredLansia {
    if (_searchQuery.isEmpty) return _lansiaList;
    
    return _lansiaList.where((lansia) {
      final nama = lansia.namaLansia?.toLowerCase() ?? '';
      final noKamar = lansia.noKamarLansia?.toLowerCase() ?? '';
      return nama.contains(_searchQuery.toLowerCase()) ||
             noKamar.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C6223),
        title: const Text("Jadwal Obat Lansia"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLansia,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari nama lansia atau nomor kamar...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9C6223)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),

          // Quick action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JadwalObatMainScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.today, size: 18),
                    label: const Text('Obat Hari Ini'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loadLansia,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF9C6223)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Lansia (${_filteredLansia.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5D4037),
                  ),
                ),
                Text(
                  '${_lansiaList.length} total',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lansia list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF9C6223)),
                        SizedBox(height: 16),
                        Text('Memuat data lansia...'),
                      ],
                    ),
                  )
                : _filteredLansia.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty 
                                ? Icons.search_off 
                                : Icons.people_outline,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tidak ditemukan lansia dengan kata kunci "$_searchQuery"'
                                  : 'Belum ada data lansia',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _searchQuery = ''),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF9C6223),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Reset Pencarian'),
                                ),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadLansia,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredLansia.length,
                          itemBuilder: (context, index) {
                            final lansia = _filteredLansia[index];
                            return _buildLansiaCard(lansia);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLansiaCard(Datalansia lansia) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showLansiaOptions(lansia);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar/Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C6223).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF9C6223).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  lansia.jenisKelaminLansia == 'Laki-laki' 
                      ? Icons.male 
                      : Icons.female,
                  color: const Color(0xFF9C6223),
                ),
              ),
              const SizedBox(width: 12),

              // Info lansia
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lansia.namaLansia ?? 'Tanpa Nama',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.bed,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lansia.noKamarLansia ?? 'No Kamar: -',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.cake,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lansia.umurLansia ?? '-'} tahun',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (lansia.alamatLengkap != null && lansia.alamatLengkap!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 10,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lansia.alamatLengkap!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLansiaOptions(Datalansia lansia) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 8,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C6223),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  lansia.namaLansia ?? 'Lansia',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${lansia.umurLansia ?? '-'} tahun • ${lansia.jenisKelaminLansia ?? '-'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Options
            _buildOptionButton(
              icon: Icons.today,
              title: 'Lihat Obat Hari Ini',
              subtitle: 'Obat yang harus diberikan hari ini',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JadwalObatMainScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              icon: Icons.medication,
              title: 'Kelola Jadwal Obat',
              subtitle: 'Tambah, edit, hapus jadwal obat',
              color: const Color(0xFF9C6223),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageJadwalObatScreen(
                      datalansiaId: lansia.id!,
                      namaLansia: lansia.namaLansia ?? 'Lansia',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              icon: Icons.history,
              title: 'Riwayat Obat',
              subtitle: 'Lihat riwayat pemberian obat',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement riwayat obat screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur riwayat obat akan segera tersedia'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Batal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}