import 'package:flutter/material.dart';
import '../../services/kondisi_service.dart';
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
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadKondisi();
  }

  Future<void> _loadKondisi() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    try {
      final data = await _kondisiService.fetchAllKondisi();
      if (mounted) {
        setState(() {
          semuaKondisi = data;
        });
      }
    } catch (e) {
      print('⚠️ Error load kondisi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadKondisi();
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  // Helper untuk menentukan status berdasarkan data
  String _getStatus(KondisiHarian kondisi) {
    // Jika sudah ada status dari API, gunakan itu
    if (kondisi.status != null && kondisi.status!.isNotEmpty) {
      return kondisi.status!;
    }
    
    // Default logic jika status tidak ada
    if (kondisi.nadi != null && kondisi.nadi!.isNotEmpty) {
      final nadi = int.tryParse(kondisi.nadi ?? '0') ?? 0;
      if (nadi >= 60 && nadi <= 100) {
        return 'Stabil';
      } else {
        return 'Perlu Perhatian';
      }
    }
    
    return 'Stabil'; // Default
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
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'stabil':
      case 'baik':
        return Icons.check_circle;
      case 'perlu perhatian':
      case 'sedang':
        return Icons.warning;
      case 'kritis':
      case 'buruk':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  List<KondisiHarian> get filteredLansia {
    List<KondisiHarian> data = semuaKondisi;

    // Filter tanggal
    if (selectedDate != null) {
      data = data.where((e) {
        return e.tanggal.year == selectedDate!.year &&
               e.tanggal.month == selectedDate!.month &&
               e.tanggal.day == selectedDate!.day;
      }).toList();
    }

    // Filter status
    if (filterStatus != 'Semua') {
      data = data.where((e) {
        final status = _getStatus(e);
        return status == filterStatus;
      }).toList();
    }

    // Sort by tanggal descending (terbaru dulu)
    data.sort((a, b) => b.tanggal.compareTo(a.tanggal));

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = filteredLansia;
    final totalStabil = semuaKondisi.where((l) => _getStatus(l) == 'Stabil').length;
    final totalPerluPerhatian = semuaKondisi.where((l) => _getStatus(l) == 'Perlu Perhatian').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Kondisi Lansia'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isRefreshing ? Icons.refresh : Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF9C6223)))
            : Column(
                children: [
                  // 🔸 Filter Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[50],
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _selectDate(context),
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
                                  selectedDate == null
                                      ? 'Semua Tanggal'
                                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                                ),
                              ),
                            ),
                            if (selectedDate != null) ...[
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    selectedDate = null;
                                  });
                                },
                                tooltip: 'Hapus filter tanggal',
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: filterStatus,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelText: 'Filter Status',
                            prefixIcon: const Icon(Icons.filter_list),
                          ),
                          items: ['Semua', 'Stabil', 'Perlu Perhatian']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getStatusIcon(status),
                                          color: _getStatusColor(status),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(status),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              filterStatus = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // 🔸 Summary Cards
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildSummaryCard(
                          'Total',
                          semuaKondisi.length,
                          Colors.blue,
                          Icons.people,
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryCard(
                          'Stabil',
                          totalStabil,
                          Colors.green,
                          Icons.check_circle,
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryCard(
                          'Perlu Perhatian',
                          totalPerluPerhatian,
                          Colors.orange,
                          Icons.warning,
                        ),
                      ],
                    ),
                  ),

                  // 🔸 Data List Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hasil (${filteredData.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        if (filteredData.isNotEmpty)
                          Text(
                            'Terbaru → Terlama',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 🔸 Data List
                  Expanded(
                    child: filteredData.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Tidak ada data ditemukan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (selectedDate != null || filterStatus != 'Semua')
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedDate = null;
                                        filterStatus = 'Semua';
                                      });
                                    },
                                    child: const Text('Reset Filter'),
                                  ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final kondisi = filteredData[index];
                              final status = _getStatus(kondisi);
                              final statusColor = _getStatusColor(status);
                              final statusIcon = _getStatusIcon(status);
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    _showDetailDialog(kondisi, status);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 🔹 Header: Nama Lansia + Status
                                        Row(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                color: statusColor,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    kondisi.namaLansia ?? 'Tidak diketahui',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    'Tanggal: ${_formatDate(kondisi.tanggal)}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statusColor,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    statusIcon,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    status,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        // 🔹 Detail kondisi (grid)
                                        GridView.count(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 2,
                                          childAspectRatio: 3,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                          children: [
                                            _buildDetailItem(
                                              '❤️',
                                              'Detak Jantung',
                                              '${kondisi.nadi ?? "-"} bpm',
                                            ),
                                            _buildDetailItem(
                                              '🩸',
                                              'Tekanan Darah',
                                              kondisi.tekananDarah ?? "-",
                                            ),
                                            _buildDetailItem(
                                              '🍽️',
                                              'Nafsu Makan',
                                              kondisi.nafsuMakan ?? "-",
                                            ),
                                            _buildDetailItem(
                                              '💊',
                                              'Status Obat',
                                              kondisi.statusObat ?? "-",
                                            ),
                                          ],
                                        ),

                                        // 🔹 Catatan (jika ada)
                                        if (kondisi.catatan != null && 
                                            kondisi.catatan!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.note,
                                                        size: 16,
                                                        color: Colors.blue,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Catatan:',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    kondisi.catatan!,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
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

  // 🔹 Kartu ringkasan
  Widget _buildSummaryCard(String title, int value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Item detail
  Widget _buildDetailItem(String emoji, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(emoji),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Pilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
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
        selectedDate = picked;
      });
    }
  }

  // 🔹 Format tanggal
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Hari ini';
    if (dateOnly == yesterday) return 'Kemarin';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  // 🔹 Show detail dialog
  void _showDetailDialog(KondisiHarian kondisi, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Kondisi ${kondisi.namaLansia}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: const Text('Tanggal'),
                subtitle: Text(_formatDate(kondisi.tanggal)),
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('Detak Jantung'),
                subtitle: Text('${kondisi.nadi ?? "-"} bpm'),
              ),
              ListTile(
                leading: const Icon(Icons.monitor_heart, color: Colors.purple),
                title: const Text('Tekanan Darah'),
                subtitle: Text(kondisi.tekananDarah ?? "-"),
              ),
              ListTile(
                leading: const Icon(Icons.restaurant, color: Colors.green),
                title: const Text('Nafsu Makan'),
                subtitle: Text(kondisi.nafsuMakan ?? "-"),
              ),
              ListTile(
                leading: const Icon(Icons.medication, color: Colors.orange),
                title: const Text('Status Obat'),
                subtitle: Text(kondisi.statusObat ?? "-"),
              ),
              ListTile(
                leading: Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                ),
                title: const Text('Status Kesehatan'),
                subtitle: Text(status),
              ),
              if (kondisi.catatan != null && kondisi.catatan!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.note, color: Colors.brown),
                  title: const Text('Catatan'),
                  subtitle: Text(kondisi.catatan!),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}