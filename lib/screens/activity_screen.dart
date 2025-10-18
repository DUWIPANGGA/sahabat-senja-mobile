import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _selectedCategory = 0; // 0: Semua, 1: Hari ini, 2: Mendatang, 3: Selesai

  final List<Map<String, dynamic>> _activities = [
    {
      'id': 1,
      'title': 'Senam Pagi Lansia',
      'description': 'Senam ringan untuk melenturkan persendian dan melancarkan peredaran darah',
      'date': '2024-01-15',
      'time': '07:00 - 08:00',
      'category': 'hari_ini',
      'type': 'Olahraga',
      'location': 'Lapangan Panti',
      'participants': 15,
      'instructor': 'Perawat Anita',
      'status': 'upcoming', // upcoming, ongoing, completed
      'image': 'assets/senam.jpg',
    },
    {
      'id': 2,
      'title': 'Terapi Musik Relaksasi',
      'description': 'Terapi dengan musik klasik untuk menenangkan pikiran dan mengurangi stres',
      'date': '2024-01-15',
      'time': '10:00 - 11:00',
      'category': 'hari_ini',
      'type': 'Terapi',
      'location': 'Ruang Terapi',
      'participants': 8,
      'instructor': 'Terapis Budi',
      'status': 'upcoming',
      'image': 'assets/music.jpg',
    },
    {
      'id': 3,
      'title': 'Kelas Memasak Bersama',
      'description': 'Memasak menu sehat dengan panduan nutritionist',
      'date': '2024-01-16',
      'time': '14:00 - 16:00',
      'category': 'mendatang',
      'type': 'Kuliner',
      'location': 'Dapur Umum',
      'participants': 12,
      'instructor': 'Chef Sari',
      'status': 'upcoming',
      'image': 'assets/cooking.jpg',
    },
    {
      'id': 4,
      'title': 'Bercerita Pengalaman Hidup',
      'description': 'Sesi berbagi cerita dan pengalaman hidup antar lansia',
      'date': '2024-01-14',
      'time': '09:00 - 10:30',
      'category': 'selesai',
      'type': 'Sosial',
      'location': 'Ruang Keluarga',
      'participants': 20,
      'instructor': 'Psikolog Rina',
      'status': 'completed',
      'image': 'assets/story.jpg',
    },
    {
      'id': 5,
      'title': 'Yoga untuk Lansia',
      'description': 'Yoga ringan dengan gerakan yang aman untuk lansia',
      'date': '2024-01-17',
      'time': '06:30 - 07:30',
      'category': 'mendatang',
      'type': 'Olahraga',
      'location': 'Taman Panti',
      'participants': 10,
      'instructor': 'Instruktur Yoga',
      'status': 'upcoming',
      'image': 'assets/yoga.jpg',
    },
  ];

  final List<String> _categories = [
    'Semua',
    'Hari Ini',
    'Mendatang',
    'Selesai'
  ];

  List<Map<String, dynamic>> get _filteredActivities {
    if (_selectedCategory == 0) return _activities;
    if (_selectedCategory == 1) {
      return _activities.where((activity) => activity['category'] == 'hari_ini').toList();
    }
    if (_selectedCategory == 2) {
      return _activities.where((activity) => activity['category'] == 'mendatang').toList();
    }
    if (_selectedCategory == 3) {
      return _activities.where((activity) => activity['category'] == 'selesai').toList();
    }
    return _activities;
  }

  void _showActivityDetail(Map<String, dynamic> activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildActivityDetail(activity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Color(0xFFFFF9F5),
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            color: Colors.grey[50],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: FilterChip(
                    label: Text(_categories[index]),
                    selected: _selectedCategory == index,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = index;
                      });
                    },
                    selectedColor: Colors.brown[700],
                    checkmarkColor: Color(0xFFFFF9F5),
                    labelStyle: TextStyle(
                      color: _selectedCategory == index ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),

          // Activities List
          Expanded(
            child: _filteredActivities.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada aktivitas',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredActivities.length,
                    itemBuilder: (context, index) {
                      final activity = _filteredActivities[index];
                      return _buildActivityCard(activity);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    Color statusColor = Colors.grey;
    String statusText = '';

    switch (activity['status']) {
      case 'upcoming':
        statusColor = Colors.blue;
        statusText = 'Akan Datang';
        break;
      case 'ongoing':
        statusColor = Colors.green;
        statusText = 'Sedang Berlangsung';
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusText = 'Selesai';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showActivityDetail(activity),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    activity['type']!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Judul aktivitas
              Text(
                activity['title']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Deskripsi
              Text(
                activity['description']!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Informasi waktu dan lokasi
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${activity['date']!} • ${activity['time']!}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    activity['location']!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Footer dengan peserta dan instruktur
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${activity['participants']} Peserta',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(
                    'Oleh: ${activity['instructor']!}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.brown[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityDetail(Map<String, dynamic> activity) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                activity['title']!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: activity['status'] == 'upcoming' 
                  ? Colors.blue.withOpacity(0.1)
                  : activity['status'] == 'ongoing'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              activity['status'] == 'upcoming' 
                  ? '🕐 Akan Datang'
                  : activity['status'] == 'ongoing'
                      ? '✅ Sedang Berlangsung'
                      : '✓ Selesai',
              style: TextStyle(
                color: activity['status'] == 'upcoming' 
                    ? Colors.blue
                    : activity['status'] == 'ongoing'
                        ? Colors.green
                        : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Detail Informasi
          _buildDetailItem(Icons.description, 'Deskripsi', activity['description']!),
          _buildDetailItem(Icons.calendar_today, 'Tanggal', activity['date']!),
          _buildDetailItem(Icons.access_time, 'Waktu', activity['time']!),
          _buildDetailItem(Icons.location_on, 'Lokasi', activity['location']!),
          _buildDetailItem(Icons.category, 'Jenis Aktivitas', activity['type']!),
          _buildDetailItem(Icons.people, 'Jumlah Peserta', '${activity['participants']} orang'),
          _buildDetailItem(Icons.person, 'Instruktur/Pemandu', activity['instructor']!),

          const Spacer(),

          // Action Buttons
          if (activity['status'] == 'upcoming')
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Add to calendar functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ditambahkan ke kalender')),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Tambahkan ke Kalender'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  foregroundColor: Color(0xFFFFF9F5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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