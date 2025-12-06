import 'package:flutter/material.dart';
import '../../services/kondisi_service.dart';
import '../../models/datalansia_model.dart';
import '../../models/kondisi_model.dart';

class KondisiDetailScreen extends StatefulWidget {
  final Datalansia lansia;
  final KondisiHarian? latestKondisi;

  const KondisiDetailScreen({
    super.key,
    required this.lansia,
    this.latestKondisi,
  });

  @override
  State<KondisiDetailScreen> createState() => _KondisiDetailScreenState();
}

class _KondisiDetailScreenState extends State<KondisiDetailScreen> {
  final KondisiService _kondisiService = KondisiService();
  List<KondisiHarian> _riwayatKondisi = [];
  bool _isLoading = true;
  DateTime? _selectedFilterDate;
  String _filterMonth = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadRiwayatKondisi();
  }

  Future<void> _loadRiwayatKondisi() async {
    setState(() => _isLoading = true);
    try {
      final namaLansia = widget.lansia.namaLansia ?? '';
      if (namaLansia.isNotEmpty) {
        final riwayat = await _kondisiService.getRiwayatByNamaLansia(namaLansia);
        setState(() {
          _riwayatKondisi = riwayat;
        });
      }
    } catch (e) {
      print('❌ Error load riwayat: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getStatus(KondisiHarian kondisi) {
    if (kondisi.status != null && kondisi.status!.isNotEmpty) {
      return kondisi.status!;
    }
    
    if (kondisi.nadi != null && kondisi.nadi!.isNotEmpty) {
      final nadi = int.tryParse(kondisi.nadi ?? '0') ?? 0;
      if (nadi >= 60 && nadi <= 100) return 'Stabil';
      return 'Perlu Perhatian';
    }
    
    return 'Stabil';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'stabil':
      case 'baik':
        return Colors.green;
      case 'perlu perhatian':
      case 'sedang':
        return Colors.orange;
      case 'kritis':
      case 'buruk':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  List<KondisiHarian> get _filteredRiwayat {
    var filtered = _riwayatKondisi;

    // Filter by date
    if (_selectedFilterDate != null) {
      filtered = filtered.where((k) {
        return k.tanggal.year == _selectedFilterDate!.year &&
               k.tanggal.month == _selectedFilterDate!.month &&
               k.tanggal.day == _selectedFilterDate!.day;
      }).toList();
    }

    // Filter by month
    if (_filterMonth != 'Semua') {
      final monthIndex = _getMonthIndex(_filterMonth);
      filtered = filtered.where((k) => k.tanggal.month == monthIndex).toList();
    }

    // Sort by tanggal descending (terbaru dulu)
    filtered.sort((a, b) => b.tanggal.compareTo(a.tanggal));

    return filtered;
  }

  int _getMonthIndex(String monthName) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months.indexOf(monthName) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final filteredRiwayat = _filteredRiwayat;
    final latestKondisi = widget.latestKondisi;
    final latestStatus = latestKondisi != null ? _getStatus(latestKondisi) : 'Belum Diperiksa';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lansia.namaLansia ?? 'Detail Lansia'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRiwayatKondisi,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9C6223)))
          : Column(
              children: [
                // 🔹 Profil Lansia
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF9C6223).withOpacity(0.1),
                        const Color(0xFF9C6223).withOpacity(0.05),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C6223).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF9C6223).withOpacity(0.3), width: 2),
                        ),
                        child: Icon(
                          widget.lansia.jenisKelaminLansia == 'Laki-laki' ? Icons.male : Icons.female,
                          color: const Color(0xFF9C6223),
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.lansia.namaLansia ?? 'Tanpa Nama',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.lansia.umurLansia ?? '-'} tahun • ${widget.lansia.jenisKelaminLansia ?? '-'} • ${widget.lansia.golDarahLansia ?? '-'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (widget.lansia.alamatLengkap != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        widget.lansia.alamatLengkap!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[500],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔹 Kondisi Terkini (jika ada)
                if (latestKondisi != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Kondisi Terkini',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(latestStatus),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                latestStatus,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildHealthMetrics(latestKondisi),
                        if (latestKondisi.catatan != null && latestKondisi.catatan!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.note, size: 16, color: Colors.blue[700]),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Catatan Perawat',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    latestKondisi.catatan!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue[900],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // 🔹 Filter Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _selectFilterDate(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(
                                _selectedFilterDate == null
                                    ? 'Semua Tanggal'
                                    : '${_selectedFilterDate!.day}/${_selectedFilterDate!.month}/${_selectedFilterDate!.year}',
                              ),
                            ),
                          ),
                          if (_selectedFilterDate != null) ...[
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _selectedFilterDate = null;
                                });
                              },
                              tooltip: 'Hapus filter tanggal',
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _filterMonth,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: 'Filter Bulan',
                          prefixIcon: const Icon(Icons.filter_list, color: Color(0xFF9C6223)),
                        ),
                        items: [
                          'Semua',
                          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
                        ].map((month) => DropdownMenuItem(
                          value: month,
                          child: Text(month),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _filterMonth = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // 🔹 Header Riwayat
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Riwayat Pemeriksaan (${filteredRiwayat.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      if (filteredRiwayat.isNotEmpty)
                        Text(
                          'Terbaru → Terlama',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),

                // 🔹 Riwayat Pemeriksaan
                Expanded(
                  child: filteredRiwayat.isEmpty
                      ? _buildEmptyRiwayat()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: filteredRiwayat.length,
                          itemBuilder: (context, index) {
                            final kondisi = filteredRiwayat[index];
                            final status = _getStatus(kondisi);
                            final statusColor = _getStatusColor(status);
                            
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: _buildRiwayatCard(kondisi, status, statusColor),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildHealthMetrics(KondisiHarian kondisi) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildMetricCard('❤️', 'Detak Jantung', '${kondisi.nadi ?? "-"} bpm'),
        _buildMetricCard('🩸', 'Tekanan Darah', kondisi.tekananDarah ?? "-"),
        _buildMetricCard('🍽️', 'Nafsu Makan', kondisi.nafsuMakan ?? "-"),
        _buildMetricCard('💊', 'Status Obat', kondisi.statusObat ?? "-"),
      ],
    );
  }

  Widget _buildMetricCard(String emoji, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRiwayat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilterDate != null || _filterMonth != 'Semua'
                ? 'Tidak ada data pada periode ini'
                : 'Belum ada riwayat pemeriksaan',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (_selectedFilterDate != null || _filterMonth != 'Semua')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilterDate = null;
                    _filterMonth = 'Semua';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C6223),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reset Filter'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(KondisiHarian kondisi, String status, Color statusColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            status == 'Stabil' ? Icons.check_circle : 
            status == 'Perlu Perhatian' ? Icons.warning : Icons.help,
            color: statusColor,
          ),
        ),
        title: Text(
          _formatDate(kondisi.tanggal),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Status: $status',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildDetailRow('❤️', 'Detak Jantung', '${kondisi.nadi ?? "-"} bpm'),
                const SizedBox(height: 8),
                _buildDetailRow('🩸', 'Tekanan Darah', kondisi.tekananDarah ?? "-"),
                const SizedBox(height: 8),
                _buildDetailRow('🍽️', 'Nafsu Makan', kondisi.nafsuMakan ?? "-"),
                const SizedBox(height: 8),
                _buildDetailRow('💊', 'Status Obat', kondisi.statusObat ?? "-"),
                if (kondisi.catatan != null && kondisi.catatan!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note, size: 14, color: Colors.blue[700]),
                            const SizedBox(width: 6),
                            Text(
                              'Catatan:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          kondisi.catatan!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _selectFilterDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9C6223),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && mounted) {
      setState(() {
        _selectedFilterDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Hari ini';
    if (dateOnly == yesterday) return 'Kemarin';
    
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}