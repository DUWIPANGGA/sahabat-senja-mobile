import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/models/kondisi_model.dart';
import 'package:sahabatsenja_app/services/datalansia_service.dart';
import 'package:sahabatsenja_app/services/kondisi_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KesehatanScreen extends StatefulWidget {
  const KesehatanScreen({super.key});

  @override
  State<KesehatanScreen> createState() => _KesehatanScreenState();
}

class _KesehatanScreenState extends State<KesehatanScreen> {
  final DatalansiaService _datalansiaService = DatalansiaService();
  final KondisiService _kondisiService = KondisiService();

  List<Datalansia> _lansiaTerhubung = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _userEmail;

  // Warna tema sesuai dengan KeluargaMainScreen
  final Color _primaryColor = const Color(0xFF9C6223); // Warna coklat utama
  final Color _backgroundColor = const Color(0xFFF8F3EA); // Background cream
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF5D4037); // Warna teks coklat gelap
  final Color _accentColor = const Color(0xFF4CAF50); // Hijau untuk kesehatan

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 🔹 Ambil email user dari SharedPreferences
  Future<void> _loadUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userEmail = prefs.getString('user_email');
      debugPrint('📧 User email: $_userEmail');
    } catch (e) {
      debugPrint('❌ Error load email: $e');
    }
  }

  /// 🔹 Ambil data lansia berdasarkan email user yang login
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _loadUserEmail();
      
      if (_userEmail != null && _userEmail!.isNotEmpty) {
        // Ambil data lansia berdasarkan email keluarga
        final dataLansia = await _datalansiaService.getDatalansiaByKeluarga(_userEmail!);
        
        debugPrint('📊 Data lansia ditemukan: ${dataLansia.length} item');
        
        setState(() {
          _lansiaTerhubung = dataLansia;
        });
      } else {
        setState(() {
          _errorMessage = 'Silakan login terlebih dahulu';
        });
        debugPrint('⚠️ User belum login atau email tidak ditemukan');
      }
    } catch (e) {
      debugPrint('❌ Error ambil data lansia: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
      });
    }

    setState(() => _isLoading = false);
  }

  /// 🔹 Refresh data
  Future<void> _refreshData() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Kesehatan Lansia',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildErrorState()
              : _lansiaTerhubung.isEmpty
                  ? _buildEmptyState()
                  : _buildLansiaList(),
    );
  }

  Widget _buildLoading() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Memuat data kesehatan...',
              style: TextStyle(
                fontSize: 16,
                color: _textColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mohon tunggu sebentar',
              style: TextStyle(
                fontSize: 13,
                color: _textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );

  Widget _buildErrorState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage ?? 'Terjadi kesalahan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Silakan coba lagi atau periksa koneksi internet Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Coba Lagi',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildEmptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.health_and_safety,
                  size: 60,
                  color: _primaryColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum Ada Data Lansia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Anda belum memiliki data lansia yang terhubung. Tambahkan data lansia terlebih dahulu untuk memantau kesehatan mereka.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textColor.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email, size: 16, color: _primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Email login: $_userEmail',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Refresh Data',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildLansiaList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      backgroundColor: _primaryColor,
      color: Colors.white,
      displacement: 40,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _lansiaTerhubung.length,
        itemBuilder: (context, index) {
          final lansia = _lansiaTerhubung[index];
          final namaLansia = lansia.namaLansia ?? 'Tanpa Nama';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: FutureBuilder<KondisiHarian?>(
              future: _kondisiService.getTodayData(namaLansia),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingCard(lansia);
                }

                if (snapshot.hasError) {
                  return _buildErrorCard(lansia, snapshot.error.toString());
                }

                final kondisi = snapshot.data;
                return _buildLansiaCard(lansia, kondisi);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingCard(Datalansia lansia) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: _primaryColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lansia.namaLansia ?? 'Tanpa Nama',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lansia.umurLansia ?? '-'} tahun',
                    style: TextStyle(
                      color: _textColor.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 4,
                    backgroundColor: _backgroundColor,
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(Datalansia lansia, String error) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    lansia.namaLansia ?? 'Tanpa Nama',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, size: 16, color: Colors.orange[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Gagal memuat data kesehatan',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    error.length > 80 ? '${error.substring(0, 80)}...' : error,
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 12,
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

  Widget _buildLansiaCard(Datalansia lansia, KondisiHarian? kondisi) {
    final status = kondisi?.status ?? 'Belum Diperiksa';
    final statusColor = _getStatusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan informasi lansia
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: _primaryColor.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lansia.namaLansia ?? 'Tanpa Nama',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lansia.umurLansia ?? '-'} tahun | ${lansia.jenisKelaminLansia ?? '-'}',
                        style: TextStyle(
                          color: _textColor.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      if (lansia.alamatLengkap != null && lansia.alamatLengkap!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: _textColor.withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  lansia.alamatLengkap!,
                                  style: TextStyle(
                                    color: _textColor.withOpacity(0.5),
                                    fontSize: 11,
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
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Data kesehatan jika ada
            const SizedBox(height: 16),
            kondisi != null 
                ? _buildHealthData(kondisi)
                : _buildNoHealthData(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthData(KondisiHarian kondisi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.health_and_safety,
              color: _accentColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Kondisi Kesehatan Hari Ini',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _textColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Metrics Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.8,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildMetricItem('🩸', 'Tekanan Darah', kondisi.tekananDarah ?? '-'),
            _buildMetricItem('❤️', 'Nadi', kondisi.nadi != null ? '${kondisi.nadi} BPM' : '-'),
            _buildMetricItem('🍽️', 'Nafsu Makan', kondisi.nafsuMakan ?? '-'),
            _buildMetricItem('💊', 'Status Obat', kondisi.statusObat ?? '-'),
          ],
        ),

        // Catatan jika ada
        if (kondisi.catatan != null && kondisi.catatan!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accentColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.note, color: _accentColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Catatan Perawat',
                      style: TextStyle(
                        color: _accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  kondisi.catatan!,
                  style: TextStyle(
                    color: _textColor.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Tanggal pemeriksaan
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: _textColor.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Tanggal Pemeriksaan: ${kondisi.tanggal ?? '-'}',
                style: TextStyle(
                  color: _textColor.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoHealthData() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info,
              color: _primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada data kesehatan',
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Perawat belum melakukan pemeriksaan hari ini',
                  style: TextStyle(
                    color: _textColor.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String emoji, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: _textColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'stabil':
        return _accentColor; // Hijau
      case 'perlu perhatian':
        return const Color(0xFFFF9800); // Orange
      case 'kritis':
        return const Color(0xFFF44336); // Red
      case 'belum diperiksa':
        return const Color(0xFF9E9E9E); // Grey
      default:
        return _primaryColor; // Coklat default
    }
  }
}