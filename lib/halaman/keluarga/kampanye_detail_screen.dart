import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/keluarga/donation_form_screen.dart';
import 'package:sahabatsenja_app/models/kampanye_model.dart';
import 'package:sahabatsenja_app/services/donasi_service.dart';

class KampanyeDetailScreen extends StatefulWidget {
  final KampanyeDonasi kampanye;

  const KampanyeDetailScreen({super.key, required this.kampanye});

  @override
  State<KampanyeDetailScreen> createState() => _KampanyeDetailScreenState();
}

class _KampanyeDetailScreenState extends State<KampanyeDetailScreen> {
  final DonasiService _donasiService = DonasiService();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  KampanyeDonasi? _kampanyeDetail;
  List<Map<String, dynamic>> _recentDonations = [];
  List<Map<String, dynamic>> _similarCampaigns = [];

  @override
  void initState() {
    super.initState();
    _loadKampanyeDetail();
  }
ImageProvider _getKampanyeImage(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return const AssetImage('assets/images/donasi.png');
  }
  
  try {
    final uri = Uri.parse(imageUrl);
    if (uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(imageUrl);
    } else {
      return const AssetImage('assets/images/donasi.png');
    }
  } catch (e) {
    return const AssetImage('assets/images/donasi.png');
  }
}
  Future<void> _loadKampanyeDetail() async {
    setState(() => _isLoading = true);
    
    try {
      final detail = await _donasiService.getKampanyeDetail(widget.kampanye.slug);
      setState(() {
        _kampanyeDetail = detail;
        _recentDonations = detail.recentDonations ?? [];
        _similarCampaigns = detail.similarCampaigns ?? [];
      });
    } catch (e) {
      print('❌ Error loading kampanye detail: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDonation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationFormScreen(kampanye: _kampanyeDetail!),
      ),
    );
  }

  void _navigateToSimilarKampanye(Map<String, dynamic> kampanyeData) {
    final kampanye = KampanyeDonasi(
      id: kampanyeData['id'] ?? 0,
      judul: kampanyeData['judul'] ?? '',
      slug: kampanyeData['slug'] ?? '',
      deskripsiSingkat: kampanyeData['deskripsi_singkat'] ?? '',
      gambar: kampanyeData['gambar'] ?? '',
      targetDana: (kampanyeData['target_dana'] is String)
          ? double.tryParse(kampanyeData['target_dana'].replaceAll('Rp', '').replaceAll('.', '').replaceAll(',', '').trim()) ?? 0
          : kampanyeData['target_dana']?.toDouble() ?? 0,
      danaTerkumpul: (kampanyeData['dana_terkumpul'] is String)
          ? double.tryParse(kampanyeData['dana_terkumpul'].replaceAll('Rp', '').replaceAll('.', '').replaceAll(',', '').trim()) ?? 0
          : kampanyeData['dana_terkumpul']?.toDouble() ?? 0,
      progress: kampanyeData['progress'] ?? 0,
      hariTersisa: kampanyeData['hari_tersisa'] ?? 0,
      isActive: kampanyeData['is_active'] ?? false,
      kategori: kampanyeData['kategori'] ?? '',
      status: kampanyeData['status'] ?? '',
      isFeatured: kampanyeData['is_featured'] ?? false,
      jumlahDonatur: kampanyeData['jumlah_donatur'] ?? 0,
      jumlahDilihat: kampanyeData['jumlah_dilihat'] ?? 0,
      tanggalMulai: DateTime.now(),
      tanggalSelesai: DateTime.now(),
      createdAt: DateTime.now(),
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => KampanyeDetailScreen(kampanye: kampanye),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kampanye = _kampanyeDetail ?? widget.kampanye;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: _isLoading
          ? _buildLoadingScreen()
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Header with image
                _buildHeader(kampanye),
                
                // Fixed App Bar
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 1,
                  pinned: true,
                  floating: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    kampanye.judul,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: Color(0xFF333333)),
                      onPressed: _shareKampanye,
                    ),
                  ],
                ),
                
                // Content
                _buildContent(kampanye),
              ],
            ),
      
      // Fixed Donate Button
      bottomNavigationBar: _buildDonateButton(kampanye),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: Color(0xFF9C6223)),
      ),
    );
  }

  SliverAppBar _buildHeader(KampanyeDonasi kampanye) {
  return SliverAppBar(
    expandedHeight: 250,
    backgroundColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: FlexibleSpaceBar(
      background: Stack(
        children: [
          // Main Image dengan fallback ke gambar dummy
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _getKampanyeImage(kampanye.gambar),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Progress Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: kampanye.progress / 100,
              backgroundColor: Colors.transparent,
              color: Colors.white,
              minHeight: 4,
            ),
          ),
        ],
      ),
    ),
  );
}

  SliverList _buildContent(KampanyeDonasi kampanye) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Campaign Info Card
        _buildCampaignInfoCard(kampanye),
        
        // Description
        _buildDescriptionSection(kampanye),
        
        // Gallery
        if (kampanye.gallery != null && kampanye.gallery!.isNotEmpty)
          _buildGallerySection(kampanye),
        
        // Recent Donations
        if (_recentDonations.isNotEmpty)
          _buildRecentDonationsSection(),
        
        // Similar Campaigns
        if (_similarCampaigns.isNotEmpty)
          _buildSimilarCampaignsSection(),
        
        const SizedBox(height: 100), // Spacer for bottom button
      ]),
    );
  }

  Widget _buildCampaignInfoCard(KampanyeDonasi kampanye) {
    return Container(
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
          // Title
          Text(
            kampanye.judul,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          
          // Category & Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C6223).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  kampanye.kategori,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9C6223),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (kampanye.isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        'Unggulan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress Section
          _buildProgressSection(kampanye),
          const SizedBox(height: 20),
          
          // Stats Row
          _buildStatsRow(kampanye),
        ],
      ),
    );
  }

  Widget _buildProgressSection(KampanyeDonasi kampanye) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${kampanye.progress}% terkumpul',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              kampanye.daysLeftText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kampanye.isExpired 
                    ? Colors.red
                    : kampanye.isAlmostExpired
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Progress Bar
        LinearProgressIndicator(
          value: kampanye.progress / 100,
          backgroundColor: Colors.grey[200],
          color: const Color(0xFF9C6223),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        
        // Amounts
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terkumpul',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  kampanye.formattedDanaTerkumpul,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C6223),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Target',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  kampanye.formattedTargetDana,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(KampanyeDonasi kampanye) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItemDetail(
            Icons.people_outline,
            '${kampanye.jumlahDonatur}',
            'Donatur',
          ),
          _buildStatItemDetail(
            Icons.visibility_outlined,
            '${kampanye.jumlahDilihat}',
            'Dilihat',
          ),
          _buildStatItemDetail(
            Icons.access_time_outlined,
            '${kampanye.hariTersisa}',
            'Hari Tersisa',
          ),
          _buildStatItemDetail(
            Icons.calendar_today_outlined,
            kampanye.tanggalSelesai != null
                ? '${kampanye.tanggalSelesai.day}/${kampanye.tanggalSelesai.month}'
                : '-',
            'Selesai',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF9C6223)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(KampanyeDonasi kampanye) {
    return Container(
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
              Icon(Icons.description_outlined, color: Color(0xFF9C6223), size: 22),
              SizedBox(width: 8),
              Text(
                'Deskripsi Kampanye',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            kampanye.deskripsi ?? kampanye.deskripsiSingkat,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection(KampanyeDonasi kampanye) {
    return Container(
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
              Icon(Icons.photo_library_outlined, color: Color(0xFF9C6223), size: 22),
              SizedBox(width: 8),
              Text(
                'Galeri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kampanye.gallery!.length,
              itemBuilder: (context, index) {
                final imageUrl = kampanye.gallery![index];
                return Container(
                  width: 150,
                  margin: EdgeInsets.only(
                    right: index < kampanye.gallery!.length - 1 ? 12 : 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
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

  Widget _buildRecentDonationsSection() {
    return Container(
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
              Icon(Icons.history_outlined, color: Color(0xFF9C6223), size: 22),
              SizedBox(width: 8),
              Text(
                'Donasi Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._recentDonations.take(5).map((donation) {
            return _buildDonationItem(donation);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDonationItem(Map<String, dynamic> donation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF9C6223).withOpacity(0.1),
            child: Text(
              donation['nama']?.substring(0, 1).toUpperCase() ?? '?',
              style: const TextStyle(
                color: Color(0xFF9C6223),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation['nama'] ?? 'Anonim',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  donation['doa_harapan'] ?? 'Semoga bermanfaat',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                donation['jumlah'] ?? 'Rp 0',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C6223),
                ),
              ),
              Text(
                donation['waktu'] ?? '',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarCampaignsSection() {
    return Container(
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
              Icon(Icons.compare_arrows_outlined, color: Color(0xFF9C6223), size: 22),
              SizedBox(width: 8),
              Text(
                'Kampanye Serupa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._similarCampaigns.take(3).map((campaign) {
            return _buildSimilarCampaignItem(campaign);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSimilarCampaignItem(Map<String, dynamic> campaign) {
    final progress = campaign['progress'] ?? 0;
    final daysLeft = campaign['hari_tersisa'] ?? 0;
    
    return GestureDetector(
      onTap: () => _navigateToSimilarKampanye(campaign),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: NetworkImage(campaign['gambar'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign['judul'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF9C6223),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$progress%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9C6223),
                          ),
                        ),
                        Text(
                          '$daysLeft hari lagi',
                          style: TextStyle(
                            fontSize: 11,
                            color: daysLeft < 7 ? Colors.orange : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  Widget _buildDonateButton(KampanyeDonasi kampanye) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Share Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _shareKampanye,
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text('Bagikan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9C6223),
                side: const BorderSide(color: Color(0xFF9C6223)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Donate Button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _navigateToDonation,
              icon: const Icon(Icons.favorite_border, size: 18),
              label: const Text(
                'DONASI SEKARANG',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6223),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareKampanye() {
    // TODO: Implement share functionality
    print('Share kampanye: ${widget.kampanye.judul}');
  }
}