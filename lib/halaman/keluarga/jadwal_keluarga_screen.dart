import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/services/jadwal_service.dart';
import 'package:sahabatsenja_app/models/jadwal_aktivitas_model.dart';
import 'package:intl/intl.dart';

class JadwalKeluargaScreen extends StatefulWidget {
  const JadwalKeluargaScreen({super.key});

  @override
  State<JadwalKeluargaScreen> createState() => _JadwalKeluargaScreenState();
}

class _JadwalKeluargaScreenState extends State<JadwalKeluargaScreen> {
  List<JadwalAktivitas> _list = [];
  bool _loading = true;
  final JadwalService _service = JadwalService();

  final List<String> _activityImages = [
    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400', // Olahraga
    'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400', // Musik
    'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400', // Yoga
    'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400', // Meditasi
    'https://images.unsplash.com/photo-1534258936925-c58bed479fcb?w=400', // Seni
  ];

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchJadwal();
      setState(() => _list = data);
    } catch (e) {
      print('⚠️ Error: $e');
      _showSnackbar('Gagal memuat jadwal: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  // Fungsi untuk mendapatkan ukuran responsif berdasarkan screen size
  double _getResponsiveSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Base reference: 360x640 (phone kecil)
    final baseWidth = 360.0;
    final baseHeight = 640.0;
    
    // Ambil scaling factor dari width dan height, lalu ambil rata-rata
    final widthScale = screenWidth / baseWidth;
    final heightScale = screenHeight / baseHeight;
    final scale = (widthScale + heightScale) / 2;
    
    // Batasi scaling antara 0.8 dan 1.5 untuk menghindari ukuran ekstrem
    final clampedScale = scale.clamp(0.8, 1.5);
    
    return baseSize * clampedScale;
  }

  // Fungsi untuk mendapatkan font size responsif
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 360.0; // Base width 360
    final clampedScale = scale.clamp(0.8, 1.3); // Batasi scaling font
    return baseSize * clampedScale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jadwal Keluarga',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _getResponsiveFontSize(context, 18),
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadJadwal,
              color: Colors.brown[700],
              child: _list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: _getResponsiveSize(context, 60),
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: _getResponsiveSize(context, 12)),
                          Text(
                            'Belum ada aktivitas',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 16),
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: _getResponsiveSize(context, 6)),
                          Text(
                            'Swipe down untuk refresh',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 12),
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(_getResponsiveSize(context, 12)),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: _getResponsiveSize(context, 12),
                        mainAxisSpacing: _getResponsiveSize(context, 12),
                        childAspectRatio: _getChildAspectRatio(context),
                      ),
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        final a = _list[index];
                        final imageUrl = _getActivityImage(a, index);
                        return _buildActivityCard(a, imageUrl, context);
                      },
                    ),
            ),
    );
  }

  // Fungsi untuk menentukan aspect ratio berdasarkan screen size
  double _getChildAspectRatio(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    if (screenHeight < 600) {
      return 0.75; // Untuk layar sangat kecil
    } else if (screenHeight < 700) {
      return 0.8; // Untuk layar kecil
    } else if (screenHeight < 800) {
      return 0.85; // Untuk layar medium
    } else {
      return 0.9; // Untuk layar besar
    }
  }

  String _getActivityImage(JadwalAktivitas jadwal, int index) {
    final namaAktivitas = jadwal.namaAktivitas.toLowerCase();
    
    if (namaAktivitas.contains('nyanyi') || namaAktivitas.contains('musik')) {
      return _activityImages[1];
    } else if (namaAktivitas.contains('olahraga') || namaAktivitas.contains('senam')) {
      return _activityImages[0];
    } else if (namaAktivitas.contains('yoga') || namaAktivitas.contains('meditasi')) {
      return _activityImages[3];
    } else if (namaAktivitas.contains('seni') || namaAktivitas.contains('lukis') || namaAktivitas.contains('kerajinan')) {
      return _activityImages[4];
    } else if (namaAktivitas.contains('masak') || namaAktivitas.contains('memasak') || namaAktivitas.contains('makan')) {
      return 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400';
    } else if (namaAktivitas.contains('obat') || namaAktivitas.contains('minum obat') || namaAktivitas.contains('kesehatan')) {
      return 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400';
    } else {
      return _activityImages[index % _activityImages.length];
    }
  }

  Widget _buildActivityCard(JadwalAktivitas a, String imageUrl, BuildContext context) {
    final cardHeight = _getResponsiveSize(context, 160);
    final imageHeight = _getResponsiveSize(context, 50);
    
    // Format tanggal dari createdAt atau gunakan hari
    final displayDate = _getDisplayDate(a);
    final displayTime = _formatJam(a.jam);

    return GestureDetector(
      onTap: () => _showDetail(a, imageUrl, context),
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_getResponsiveSize(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getResponsiveSize(context, 16)),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_getResponsiveSize(context, 16)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: a.completed
                    ? [const Color(0xFFF8F0E3), const Color(0xFFE8D5C4)]
                    : [const Color(0xFFF5E6D3), const Color(0xFFDBC3A5)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar kegiatan
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_getResponsiveSize(context, 16)),
                    topRight: Radius.circular(_getResponsiveSize(context, 16)),
                  ),
                  child: Container(
                    height: imageHeight,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.brown[700],
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.photo_library,
                            color: Colors.grey[400],
                            size: _getResponsiveSize(context, 24),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(_getResponsiveSize(context, 8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header dengan status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: _getResponsiveSize(context, 20),
                              height: _getResponsiveSize(context, 20),
                              decoration: BoxDecoration(
                                color: a.completed ? const Color(0xFFEED992) : Colors.blue,
                                borderRadius: BorderRadius.circular(_getResponsiveSize(context, 6)),
                              ),
                              child: Icon(
                                a.completed ? Icons.check_circle : Icons.event_available,
                                color: Colors.white,
                                size: _getResponsiveSize(context, 10),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _getResponsiveSize(context, 6), 
                                vertical: _getResponsiveSize(context, 2),
                              ),
                              decoration: BoxDecoration(
                                color: a.completed ? Colors.green : Colors.blue,
                                borderRadius: BorderRadius.circular(_getResponsiveSize(context, 6)),
                              ),
                              child: Text(
                                a.completed ? 'Selesai' : 'Aktif',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _getResponsiveFontSize(context, 8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: _getResponsiveSize(context, 4)),
                        
                        // Nama aktivitas
                        Expanded(
                          child: Text(
                            a.namaAktivitas,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _getResponsiveFontSize(context, 11),
                              color: Colors.grey[800],
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        SizedBox(height: _getResponsiveSize(context, 2)),
                        
                        // Hari
                        if (a.hari != null && a.hari!.isNotEmpty)
                          _buildInfoRow(
                            Icons.calendar_today,
                            a.hari!,
                            context,
                          ),
                        
                        SizedBox(height: _getResponsiveSize(context, 1)),
                        
                        // Waktu
                        _buildInfoRow(
                          Icons.access_time,
                          displayTime,
                          context,
                        ),
                        
                        // Keterangan singkat
                        if (a.keterangan != null && a.keterangan!.isNotEmpty)
                          SizedBox(
                            height: _getResponsiveSize(context, 20),
                            child: Text(
                              a.keterangan!,
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(context, 8),
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        
                        // Spacer
                        const Spacer(),
                        
                        // Tanggal dibuat
                        if (a.createdAt != null)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              DateFormat('dd/MM').format(a.createdAt!),
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(context, 7),
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDisplayDate(JadwalAktivitas jadwal) {
    if (jadwal.hari != null && jadwal.hari!.isNotEmpty) {
      return jadwal.hari!;
    } else if (jadwal.createdAt != null) {
      return DateFormat('EEEE', 'id_ID').format(jadwal.createdAt!);
    }
    return '-';
  }

  String _formatJam(String jam) {
    try {
      // Format jam dari "HH:mm" ke format yang lebih user friendly
      final parts = jam.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        
        if (hour < 12) {
          return '$jam pagi';
        } else if (hour < 15) {
          return '$jam siang';
        } else if (hour < 19) {
          return '$jam sore';
        } else {
          return '$jam malam';
        }
      }
      return jam;
    } catch (e) {
      return jam;
    }
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context, {int maxLines = 1}) {
    return Row(
      children: [
        Icon(
          icon, 
          size: _getResponsiveSize(context, 8), 
          color: Colors.grey[600]
        ),
        SizedBox(width: _getResponsiveSize(context, 3)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 8),
              color: Colors.grey[600],
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showDetail(JadwalAktivitas a, String imageUrl, BuildContext context) {
    final bottomSheetHeight = MediaQuery.of(context).size.height * 0.75;
    final imageHeight = _getResponsiveSize(context, 150);
    
    // Format data untuk ditampilkan
    final displayHari = a.hari ?? '-';
    final displayTime = _formatJam(a.jam);
    final displayDate = a.createdAt != null 
        ? DateFormat('dd MMMM yyyy', 'id_ID').format(a.createdAt!)
        : '-';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: bottomSheetHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_getResponsiveSize(context, 24)),
            topRight: Radius.circular(_getResponsiveSize(context, 24)),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(
                top: _getResponsiveSize(context, 8), 
                bottom: _getResponsiveSize(context, 4),
              ),
              width: _getResponsiveSize(context, 40),
              height: _getResponsiveSize(context, 4),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(_getResponsiveSize(context, 2)),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Gambar kegiatan di detail
                    Container(
                      height: imageHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(_getResponsiveSize(context, 24)),
                          topRight: Radius.circular(_getResponsiveSize(context, 24)),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(_getResponsiveSize(context, 24)),
                            topRight: Radius.circular(_getResponsiveSize(context, 24)),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _getResponsiveSize(context, 12), 
                                    vertical: _getResponsiveSize(context, 4),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(_getResponsiveSize(context, 12)),
                                  ),
                                  child: Text(
                                    a.completed ? 'SELESAI' : 'BELUM SELESAI',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: _getResponsiveFontSize(context, 10),
                                    ),
                                  ),
                                ),
                                SizedBox(height: _getResponsiveSize(context, 8)),
                                Text(
                                  a.namaAktivitas,
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(context, 18),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: _getResponsiveSize(context, 4)),
                                // Informasi hari dan waktu
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today, 
                                      size: _getResponsiveSize(context, 12), 
                                      color: Colors.white70
                                    ),
                                    SizedBox(width: _getResponsiveSize(context, 4)),
                                    Text(
                                      displayHari,
                                      style: TextStyle(
                                        color: Colors.white70, 
                                        fontSize: _getResponsiveFontSize(context, 11)
                                      ),
                                    ),
                                    SizedBox(width: _getResponsiveSize(context, 8)),
                                    Icon(
                                      Icons.access_time, 
                                      size: _getResponsiveSize(context, 12), 
                                      color: Colors.white70
                                    ),
                                    SizedBox(width: _getResponsiveSize(context, 4)),
                                    Text(
                                      displayTime,
                                      style: TextStyle(
                                        color: Colors.white70, 
                                        fontSize: _getResponsiveFontSize(context, 11)
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Konten detail
                    Padding(
                      padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Keterangan
                          if (a.keterangan != null && a.keterangan!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Keterangan',
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(context, 14),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: _getResponsiveSize(context, 6)),
                                Text(
                                  a.keterangan!,
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(context, 12),
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: _getResponsiveSize(context, 16)),
                              ],
                            ),
                          
                          // Informasi detail
                          _buildDetailInfoItem(
                            Icons.calendar_today, 
                            'Hari', 
                            displayHari, 
                            context
                          ),
                          _buildDetailInfoItem(
                            Icons.access_time, 
                            'Waktu', 
                            displayTime, 
                            context
                          ),
                          
                          // Informasi tambahan jika ada
                          if (a.datalansiaId != null)
                            _buildDetailInfoItem(
                              Icons.person, 
                              'ID Lansia', 
                              a.datalansiaId.toString(), 
                              context
                            ),
                          
                          if (a.createdAt != null)
                            _buildDetailInfoItem(
                              Icons.date_range, 
                              'Dibuat Pada', 
                              displayDate, 
                              context
                            ),
                          
                          SizedBox(height: _getResponsiveSize(context, 20)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailInfoItem(IconData icon, String title, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: _getResponsiveSize(context, 12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _getResponsiveSize(context, 32),
            height: _getResponsiveSize(context, 32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(_getResponsiveSize(context, 8)),
            ),
            child: Icon(
              icon, 
              color: Colors.brown[700], 
              size: _getResponsiveSize(context, 16)
            ),
          ),
          SizedBox(width: _getResponsiveSize(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: _getResponsiveFontSize(context, 12),
                  ),
                ),
                SizedBox(height: _getResponsiveSize(context, 2)),
                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 13),
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}