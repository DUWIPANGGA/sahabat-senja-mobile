import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/keluarga/kampanye_detail_screen.dart';
import 'package:sahabatsenja_app/models/kampanye_model.dart';
import 'package:sahabatsenja_app/services/donasi_service.dart';

class KampanyeListScreen extends StatefulWidget {
  const KampanyeListScreen({super.key});

  @override
  State<KampanyeListScreen> createState() => _KampanyeListScreenState();
}

class _KampanyeListScreenState extends State<KampanyeListScreen> {
  final DonasiService _donasiService = DonasiService();
  
  List<KampanyeDonasi> _kampanyeList = [];
  List<KampanyeDonasi> _featuredKampanye = [];
  List<String> _categories = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _selectedCategory;
  String _searchQuery = '';

  // Statistics
  int _totalKampanye = 0;
  String _totalDonasi = 'Rp 0';
  int _totalDonatur = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load in parallel
      await Future.wait([
        _loadKampanye(),
        _loadFeaturedKampanye(),
        _loadCategories(),
        _loadStatistics(),
      ]);
    } catch (e) {
      print('❌ Error loading data: $e');
      _showErrorSnackbar('Gagal memuat data kampanye');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _loadKampanye() async {
    try {
      final kampanye = await _donasiService.getActiveKampanye(
        kategori: _selectedCategory,
        perPage: 20,
      );
      setState(() => _kampanyeList = kampanye);
    } catch (e) {
      print('❌ Error loading kampanye: $e');
      rethrow;
    }
  }

  Future<void> _loadFeaturedKampanye() async {
    try {
      final featured = await _donasiService.getFeaturedKampanye();
      setState(() => _featuredKampanye = featured);
    } catch (e) {
      print('⚠️ Error loading featured: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _donasiService.getKampanyeCategories();
      setState(() => _categories = categories);
    } catch (e) {
      print('⚠️ Error loading categories: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _donasiService.getKampanyeStatistics();
      if (stats['success'] == true) {
        final data = stats['data'];
        setState(() {
          _totalKampanye = data['total_kampanye'] ?? 0;
          _totalDonasi = data['total_donasi'] ?? 'Rp 0';
          _totalDonatur = data['total_donatur'] ?? 0;
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

  void _navigateToDetail(KampanyeDonasi kampanye) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KampanyeDetailScreen(kampanye: kampanye),
      ),
    ).then((_) {
      _refreshData();
    });
  }

  void _onCategorySelected(String? category) {
    setState(() => _selectedCategory = category);
    _loadKampanye();
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
              
              // Featured Campaigns
              if (_featuredKampanye.isNotEmpty) _buildFeaturedSection(),
              
              // Search & Filter
              _buildSearchSection(),
              
              // Categories
              if (_categories.isNotEmpty) _buildCategoriesSection(),
              
              // Campaigns List
              _buildKampanyeList(),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildHeader() {
    return SliverAppBar(
      expandedHeight: 140,
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
                const Color(0xFF9C6223),
                const Color(0xFFB87D4A),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/donation_header.jpg'),
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
                    'Kampanye Donasi',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bantu lansia mendapatkan kehidupan yang lebih baik',
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

  SliverToBoxAdapter _buildStatisticsSection() {
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
                Icon(Icons.insights_outlined, color: Color(0xFF9C6223), size: 22),
                SizedBox(width: 8),
                Text(
                  'Statistik Donasi',
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
                  'Total Kampanye',
                  _totalKampanye.toString(),
                  Icons.campaign_outlined,
                  const Color(0xFF9C6223),
                ),
                _buildStatCard(
                  'Total Donasi',
                  _totalDonasi,
                  Icons.attach_money_outlined,
                  Colors.green,
                ),
                _buildStatCard(
                  'Total Donatur',
                  _totalDonatur.toString(),
                  Icons.people_outline,
                  Colors.blue,
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

  SliverToBoxAdapter _buildFeaturedSection() {
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
                  Icon(Icons.star_border_outlined, color: Color(0xFF9C6223), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Kampanye Unggulan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _featuredKampanye.length,
                itemBuilder: (context, index) {
                  final kampanye = _featuredKampanye[index];
                  return _buildFeaturedCard(kampanye,index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(KampanyeDonasi kampanye, int index) {
  return GestureDetector(
    onTap: () => _navigateToDetail(kampanye),
    child: Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: 8,
        right: index == _featuredKampanye.length - 1 ? 8 : 0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: _getKampanyeImage(kampanye.gambar),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Featured Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Unggulan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  kampanye.judul,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Progress Bar
                LinearProgressIndicator(
                  value: kampanye.progress / 100,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  color: Colors.amber,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 6),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${kampanye.progress}% terkumpul',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          kampanye.formattedDanaTerkumpul,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          kampanye.daysLeftText,
                          style: TextStyle(
                            color: kampanye.isExpired 
                                ? Colors.red[300]
                                : kampanye.isAlmostExpired
                                    ? Colors.amber
                                    : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${kampanye.jumlahDonatur} donatur',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
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

// Helper function untuk mendapatkan gambar kampanye
ImageProvider _getKampanyeImage(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    // Gunakan gambar dummy dari assets
    return const AssetImage('assets/images/donasi.png');
  }
  
  // Cek apakah URL valid
  try {
    final uri = Uri.parse(imageUrl);
    if (uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(imageUrl);
    } else {
      // URL tidak valid, gunakan gambar dummy
      return const AssetImage('assets/images/donasi.png');
    }
  } catch (e) {
    // Error parsing URL, gunakan gambar dummy
    print('⚠️ Error parsing image URL: $e');
    return const AssetImage('assets/images/donasi.png');
  }
}

  SliverToBoxAdapter _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: TextField(
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            hintText: 'Cari kampanye donasi...',
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

  SliverToBoxAdapter _buildCategoriesSection() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length + 1, // +1 for "Semua"
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildCategoryChip('Semua', null);
            }
            final category = _categories[index - 1];
            return _buildCategoryChip(category, category);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _selectedCategory == value;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => _onCategorySelected(selected ? value : null),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF9C6223),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected 
                ? const Color(0xFF9C6223) 
                : Colors.grey[300]!,
            width: isSelected ? 0 : 1,
          ),
        ),
        elevation: isSelected ? 2 : 0,
      ),
    );
  }

  Widget _buildKampanyeList() {
  final filteredKampanye = _searchQuery.isEmpty
      ? _kampanyeList
      : _kampanyeList.where((kampanye) {
          return kampanye!.judul!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 kampanye.deskripsiSingkat.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 kampanye.kategori.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

  if (filteredKampanye.isEmpty) {
    return SliverToBoxAdapter(
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada kampanye ditemukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Tidak ada kampanye aktif saat ini'
                  : 'Tidak ada hasil untuk "$_searchQuery"',
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
        final kampanye = filteredKampanye[index];
        return _buildKampanyeCard(kampanye);
      },
      childCount: filteredKampanye.length,
    ),
  );
}


  Widget _buildKampanyeCard(KampanyeDonasi kampanye) {
    return GestureDetector(
      onTap: () => _navigateToDetail(kampanye),
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
            // Image
            Stack(
              children: [
                ClipRRect(
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
  ),
  child: Container(
    height: 160,
    width: double.infinity,
    child: FadeInImage.assetNetwork(
      placeholder: 'assets/images/donasi.png',
      image: kampanye.gambar,
      fit: BoxFit.cover,
      imageErrorBuilder: (context, error, stackTrace) {
        // If network image fails, show the dummy image
        return Image.asset(
          'assets/images/donasi.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: 160,
        );
      },
      placeholderErrorBuilder: (context, error, stackTrace) {
        // If placeholder fails, show a colored container with icon
        return Container(
          height: 160,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 50,
                color: Colors.grey[400],
              ),
              SizedBox(height: 8),
              Text(
                kampanye.judul,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    ),
  ),
),
                
                // Category Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      kampanye.kategori,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9C6223),
                      ),
                    ),
                  ),
                ),
                
                // Featured Badge
                if (kampanye.isFeatured)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Unggulan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Progress Indicator on Image
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
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    kampanye.judul,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Short Description
                  Text(
                    kampanye.deskripsiSingkat,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Details
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${kampanye.progress}% terkumpul',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              kampanye.formattedDanaTerkumpul,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9C6223),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Target: ${kampanye.formattedTargetDana}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              kampanye.daysLeftText,
                              style: TextStyle(
                                fontSize: 12,
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.people_outline,
                          '${kampanye.jumlahDonatur}',
                          'Donatur',
                        ),
                        _buildStatItem(
                          Icons.visibility_outlined,
                          '${kampanye.jumlahDilihat}',
                          'Dilihat',
                        ),
                        _buildStatItem(
                          Icons.calendar_today_outlined,
                          '${kampanye.hariTersisa}',
                          'Hari Tersisa',
                        ),
                      ],
                    ),
                  ),
                  
                  // Donate Button
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToDetail(kampanye),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(height: 4),
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
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}