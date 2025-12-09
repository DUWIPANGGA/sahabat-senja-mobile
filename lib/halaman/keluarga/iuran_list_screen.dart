import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/keluarga/iuran_detail_screen.dart';
import 'package:sahabatsenja_app/models/iuran_model.dart';
import 'package:sahabatsenja_app/services/iuran_service.dart';

class IuranListScreen extends StatefulWidget {
  const IuranListScreen({super.key});

  @override
  State<IuranListScreen> createState() => _IuranListScreenState();
}

class _IuranListScreenState extends State<IuranListScreen> {
  final IuranService _iuranService = IuranService();
  
  List<IuranBulanan> _iuranList = [];
  List<IuranBulanan> _pendingIuran = [];
  List<IuranBulanan> _upcomingIuran = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _selectedStatus;
  String _searchQuery = '';

  // Statistics
  int _totalIuran = 0;
  int _totalLunas = 0;
  int _totalPending = 0;
  int _totalTerlambat = 0;
  String _totalTagihan = 'Rp 0';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.wait([
        _loadIuranList(),
        _loadPendingIuran(),
        _loadUpcomingIuran(),
        _loadStatistics(),
      ]);
    } catch (e) {
      print('❌ Error loading iuran data: $e');
      _showErrorSnackbar('Gagal memuat data iuran');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _loadIuranList() async {
    try {
      final iuran = await _iuranService.getIuranList(
        status: _selectedStatus,
        perPage: 20,
      );
      setState(() => _iuranList = iuran);
    } catch (e) {
      print('❌ Error loading iuran list: $e');
      rethrow;
    }
  }

  Future<void> _loadPendingIuran() async {
    try {
      final pending = await _iuranService.getPendingIuran();
      setState(() => _pendingIuran = pending);
    } catch (e) {
      print('⚠️ Error loading pending iuran: $e');
    }
  }

  Future<void> _loadUpcomingIuran() async {
    try {
      final upcoming = await _iuranService.getUpcomingIuran();
      setState(() => _upcomingIuran = upcoming);
    } catch (e) {
      print('⚠️ Error loading upcoming iuran: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _iuranService.getIuranStatistics();
      if (stats['success'] == true) {
        final data = stats['data'];
        setState(() {
          _totalIuran = data['total_iuran'] ?? 0;
          _totalLunas = data['total_lunas'] ?? 0;
          _totalPending = data['total_pending'] ?? 0;
          _totalTerlambat = data['total_terlambat'] ?? 0;
          _totalTagihan = data['total_tagihan'] ?? 'Rp 0';
        });
      }
    } catch (e) {
      print('⚠️ Error loading statistics: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToDetail(IuranBulanan iuran) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IuranDetailScreen(iuran: iuran),
      ),
    ).then((_) {
      _refreshData();
    });
  }

  void _onStatusSelected(String? status) {
    setState(() => _selectedStatus = status);
    _loadIuranList();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              _buildHeader(),
              
              // Statistics
              _buildStatisticsSection(),
              
              // Pending Iuran (Tagihan)
              if (_pendingIuran.isNotEmpty) _buildPendingSection(),
              
              // Upcoming Iuran
              if (_upcomingIuran.isNotEmpty) _buildUpcomingSection(),
              
              // Search & Filter
              _buildSearchSection(),
              
              // Status Filter
              _buildStatusFilterSection(),
              
              // Iuran List
              _buildIuranList(),
            ],
          ),
        ),
      ),
      floatingActionButton: _pendingIuran.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Navigate to pay all pending
                _showPayAllDialog();
              },
              icon: const Icon(Icons.payment),
              label: const Text('Bayar Semua'),
              backgroundColor: const Color(0xFF9C6223),
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4CAF50),
                const Color(0xFF2E7D32),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/iuran_header.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Iuran Bulanan',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola pembayaran iuran lansia Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.insights_outlined, color: Color(0xFF4CAF50), size: 22),
                SizedBox(width: 8),
                Text(
                  'Statistik Iuran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total Iuran',
                  _totalIuran.toString(),
                  Icons.list_alt_outlined,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Lunas',
                  _totalLunas.toString(),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                _buildStatCard(
                  'Tagihan',
                  _totalTagihan,
                  Icons.payment_outlined,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2), width: 2),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Tagihan Belum Dibayar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            ..._pendingIuran.take(2).map((iuran) => _buildPendingCard(iuran)).toList(),
            
            if (_pendingIuran.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      setState(() => _selectedStatus = 'pending');
                    },
                    child: Text(
                      'Lihat Semua (${_pendingIuran.length})',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(IuranBulanan iuran) {
    final isOverdue = iuran.isTerlambat;
    
    return GestureDetector(
      onTap: () => _navigateToDetail(iuran),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOverdue ? Colors.red[50] : Colors.orange[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverdue ? Colors.red[100]! : Colors.orange[100]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isOverdue ? Colors.red : Colors.orange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOverdue ? Icons.warning : Icons.payment,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    iuran.namaIuran,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isOverdue ? Colors.red[800] : Colors.orange[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    iuran.bulanTahun,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  iuran.formattedJumlah,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? Colors.red[800] : Colors.orange[800],
                  ),
                ),
                Text(
                  isOverdue ? '${iuran.hariTersisa.abs()} hari terlambat' : 'Jatuh tempo',
                  style: TextStyle(
                    fontSize: 11,
                    color: isOverdue ? Colors.red[600] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Iuran Mendatang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            ..._upcomingIuran.take(2).map((iuran) => _buildUpcomingCard(iuran)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(IuranBulanan iuran) {
    final daysLeft = iuran.hariTersisa;
    
    return GestureDetector(
      onTap: () => _navigateToDetail(iuran),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue[100]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    iuran.namaIuran,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    iuran.bulanTahun,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  iuran.formattedJumlah,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  '$daysLeft hari lagi',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: TextField(
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            hintText: 'Cari iuran...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterSection() {
    final statuses = [
      {'label': 'Semua', 'value': null},
      {'label': 'Lunas', 'value': 'lunas'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Menunggu Verifikasi', 'value': 'menunggu_verifikasi'},
      {'label': 'Terlambat', 'value': 'terlambat'},
    ];
    
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: statuses.length,
          itemBuilder: (context, index) {
            final status = statuses[index];
            return _buildStatusChip(
              status['label']!,
              status['value'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String? value) {
    final isSelected = _selectedStatus == value;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => _onStatusSelected(selected ? value : null),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF4CAF50),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected 
                ? const Color(0xFF4CAF50) 
                : Colors.grey[300]!,
            width: isSelected ? 0 : 1,
          ),
        ),
        elevation: isSelected ? 2 : 0,
      ),
    );
  }

  Widget _buildIuranList() {
    final filteredIuran = _searchQuery.isEmpty
        ? _iuranList
        : _iuranList.where((iuran) {
            return iuran.namaIuran.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   iuran.kodeIuran.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   iuran.deskripsi.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    if (filteredIuran.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                _selectedStatus == 'pending'
                    ? Icons.payment_outlined
                    : _selectedStatus == 'lunas'
                      ? Icons.check_circle_outline
                      : Icons.search_off_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty
                    ? 'Tidak ada iuran ditemukan'
                    : 'Tidak ada hasil untuk "$_searchQuery"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedStatus != null
                    ? 'Filter: ${_selectedStatus!.replaceAll('_', ' ')}'
                    : '',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final iuran = filteredIuran[index];
          return _buildIuranCard(iuran);
        },
        childCount: filteredIuran.length,
      ),
    );
  }

  Widget _buildIuranCard(IuranBulanan iuran) {
    final isOverdue = iuran.isTerlambat;
    
    return GestureDetector(
      onTap: () => _navigateToDetail(iuran),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iuran.statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      iuran.namaIuran,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: iuran.statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      iuran.statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Code & Period
                  Row(
                    children: [
                      Icon(Icons.code, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        iuran.kodeIuran,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        iuran.bulanTahun,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  if (iuran.deskripsi.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          iuran.deskripsi,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  
                  // Amount & Due Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jumlah Iuran',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            iuran.formattedJumlah,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Jatuh Tempo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${iuran.tanggalJatuhTempo.day}/${iuran.tanggalJatuhTempo.month}/${iuran.tanggalJatuhTempo.year}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isOverdue ? Colors.red : Colors.grey[700],
                            ),
                          ),
                          Text(
                            isOverdue 
                                ? '${iuran.hariTersisa.abs()} hari terlambat'
                                : iuran.hariTersisa > 0 
                                    ? '${iuran.hariTersisa} hari lagi'
                                    : 'Hari ini',
                            style: TextStyle(
                              fontSize: 11,
                              color: isOverdue ? Colors.red : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Late Fee (if any)
                  if (iuran.denda > 0)
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[100]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, size: 16, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Denda keterlambatan: ${iuran.formattedDenda}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                iuran.formattedTotalBayar,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  if (iuran.isPayable)
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => _payIuran(iuran),
                        icon: const Icon(Icons.payment, size: 18),
                        label: Text(
                          'BAYAR SEKARANG ${iuran.denda > 0 ? '(+ DENDA)' : ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOverdue ? Colors.red : const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  else if (iuran.isWaitingVerification)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Menunggu Verifikasi',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (iuran.isVerified && iuran.tanggalBayar != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Lunas pada ${iuran.tanggalBayar!.day}/${iuran.tanggalBayar!.month}/${iuran.tanggalBayar!.year}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        if (iuran.metodePembayaran != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Metode: ${iuran.metodePembayaran!.replaceAll('_', ' ').toUpperCase()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _payIuran(IuranBulanan iuran) async {
    try {
      final result = await _iuranService.payIuranMidtrans(
        context: context,
        iuranId: iuran.id!,
      );

      if (result['success'] == true) {
        _refreshData();
      } else {
        _showErrorSnackbar(result['message'] ?? 'Gagal melakukan pembayaran');
      }
    } catch (e) {
      _showErrorSnackbar('Terjadi kesalahan: $e');
    }
  }

  void _showPayAllDialog() {
    final totalTagihan = _pendingIuran.fold<double>(0, (sum, iuran) {
      return sum + iuran.jumlah + iuran.denda;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bayar Semua Tagihan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Anda akan membayar semua tagihan yang belum dibayar:'),
            const SizedBox(height: 16),
            ..._pendingIuran.take(3).map((iuran) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        iuran.namaIuran,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      iuran.formattedTotalBayar,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (_pendingIuran.length > 3)
              Text(
                '... dan ${_pendingIuran.length - 3} lainnya',
                style: TextStyle(color: Colors.grey[600]),
              ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Bayar:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  IuranService.formatCurrency(totalTagihan),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSelectPaymentMethodDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Bayar Semua'),
          ),
        ],
      ),
    );
  }

  void _showSelectPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Metode Pembayaran'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: _iuranService.getPaymentMethods(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            
            final methods = snapshot.data ?? [];
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: methods.map((method) {
                return ListTile(
                  leading: Icon(
                    _getPaymentMethodIcon(method['code']),
                    color: const Color(0xFF4CAF50),
                  ),
                  title: Text(method['name'] ?? ''),
                  subtitle: Text(method['description'] ?? ''),
                  onTap: () {
                    Navigator.pop(context);
                    _payAllWithMethod(method['code']);
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _payAllWithMethod(String methodCode) async {
    // TODO: Implement pay all with selected method
    // This would require backend support for bulk payment
    _showErrorSnackbar('Fitur bayar semua sedang dalam pengembangan');
  }

  IconData _getPaymentMethodIcon(String code) {
    switch (code) {
      case 'midtrans':
        return Icons.payment;
      case 'transfer_bank':
        return Icons.account_balance;
      case 'ewallet':
        return Icons.wallet;
      case 'qris':
        return Icons.qr_code;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }
}