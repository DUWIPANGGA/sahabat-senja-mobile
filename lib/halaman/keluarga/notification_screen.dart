import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Update Kondisi Kesehatan',
        'message': 'Hasil pemeriksaan rutin Ibu Siti: Tekanan darah normal, gula darah terkontrol',
        'detail': 'Hasil pemeriksaan rutin Ibu Siti:\n\n• Tekanan darah: 120/80 mmHg (Normal)\n• Denyut nadi: 72x/menit\n• Gula darah puasa: 110 mg/dL\n• Saturasi oksigen: 98%\n\nKondisi umum: Ibu Siti dalam kondisi sehat dan aktif mengikuti kegiatan sehari-hari.',
        'time': '2 jam lalu',
        'icon': Icons.health_and_safety,
        'color': Colors.green,
        'isRead': false,
        'category': 'Kesehatan',
        'type': 'text',
      },
      {
        'title': 'Foto Terapi Musik',
        'message': 'Lihat foto Bapak sedang menikmati sesi terapi musik Rabu ini',
        'detail': 'Bapak tampak menikmati sesi terapi musik bersama 5 teman lainnya. Ekspresi ceria dan aktif bernyanyi mengikuti lagu-lagu nostalgia.',
        'time': '5 jam lalu',
        'icon': Icons.photo_library,
        'color': Colors.purple,
        'isRead': false,
        'category': 'Aktivitas',
        'type': 'photo',
        'imageUrl': 'assets/images/music_therapy.jpg',
      },
      {
        'title': 'Ulang Tahun Ibu Siti',
        'message': 'Lihat foto merayakan ulang tahun Ibu Siti yang ke-80',
        'detail': 'Ibu Siti merayakan ulang tahun ke-80 bersama teman-teman dan staf panti. Acara berlangsung meriah dengan tiup lilin dan potong kue.',
        'time': '1 hari lalu',
        'icon': Icons.cake,
        'color': Colors.orange,
        'isRead': false,
        'category': 'Acara Spesial',
        'type': 'photo',
        'imageUrl': 'assets/images/birthday.jpg',
      },
      {
        'title': 'Laporan Perkembangan Bulanan',
        'message': 'Laporan perkembangan Ibu Siti bulan November sudah tersedia',
        'detail': 'Laporan Perkembangan Ibu Siti - November 2024:\n\nProgress Fisik:\n• Mobilitas: Meningkat 20%\n• Kekuatan otot: Stabil\n• Keseimbangan: Membaik\n\nKondisi Emosional:\n• Lebih sering tersenyum\n• Aktif dalam kegiatan\n• Tidur lebih nyenyak',
        'time': '2 hari lalu',
        'icon': Icons.assignment,
        'color': Colors.blue,
        'isRead': true,
        'category': 'Laporan',
        'type': 'text',
      },
      {
        'title': 'Pengingat Pembayaran',
        'message': 'Tagihan biaya perawatan bulan Desember sudah tersedia',
        'detail': 'Detail Tagihan Desember 2024:\n\n• Biaya perawatan dasar: Rp 3.500.000\n• Obat dan vitamin: Rp 750.000\n• Terapi dan kegiatan: Rp 500.000\n• Makanan dan nutrisi: Rp 1.200.000\n\nTotal: Rp 5.950.000\n\nJatuh Tempo: 10 Desember 2024',
        'time': '3 hari lalu',
        'icon': Icons.payment,
        'color': Colors.orange,
        'isRead': true,
        'category': 'Keuangan',
        'type': 'text',
      },
      {
        'title': 'Donasi Diterima',
        'message': 'Terima kasih! Donasi Rp 500.000 telah kami terima',
        'detail': 'Konfirmasi Donasi:\n\nJumlah: Rp 500.000\nTanggal: 28 November 2024\n\nDonasi akan digunakan untuk:\n• Vitamin D dan kalsium\n• Suplemen omega-3\n• Multivitamin lansia\n\nTerima kasih atas kontribusi Anda!',
        'time': '4 hari lalu',
        'icon': Icons.volunteer_activism,
        'color': Colors.red,
        'isRead': true,
        'category': 'Donasi',
        'type': 'text',
      },
      {
        'title': 'Kegiatan Senam Pagi',
        'message': 'Foto kegiatan senam pagi lansia hari ini',
        'detail': 'Kegiatan senam pagi diikuti oleh 12 lansia. Semua tampak bersemangat dan aktif mengikuti gerakan instruktur.',
        'time': '1 minggu lalu',
        'icon': Icons.photo_library,
        'color': Colors.purple,
        'isRead': true,
        'category': 'Aktivitas',
        'type': 'photo',
        'imageUrl': 'assets/images/morning_exercise.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: const Color(0xFFFFF9F5),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(
            context,
            notification['title'] as String,
            notification['message'] as String,
            notification['detail'] as String,
            notification['time'] as String,
            notification['icon'] as IconData,
            notification['color'] as Color,
            notification['isRead'] as bool,
            notification['category'] as String,
            notification['type'] as String,
            notification['imageUrl'] as String?,
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    String title,
    String message,
    String detail,
    String time,
    IconData icon,
    Color color,
    bool isRead,
    String category,
    String type,
    String? imageUrl,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showNotificationDetail(
            context,
            title,
            detail,
            icon,
            color,
            category,
            type,
            imageUrl,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isRead 
                ? null 
                : Border(
                    left: BorderSide(color: color, width: 4),
                  ),
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
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                        if (type == 'photo') 
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.photo, size: 10, color: Colors.purple),
                                SizedBox(width: 2),
                                Text(
                                  'Foto',
                                  style: TextStyle(fontSize: 10, color: Colors.purple),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(
    BuildContext context,
    String title,
    String detail,
    IconData icon,
    Color color,
    String category,
    String type,
    String? imageUrl,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: type == 'photo' 
              ? MediaQuery.of(context).size.height * 0.85
              : MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: type == 'photo' && imageUrl != null
                      ? Column(
                          children: [
                            // Gambar
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[200],
                              ),
                              child: Image.asset(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.photo, size: 50, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text(
                                          'Foto tidak tersedia',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Deskripsi
                            Text(
                              detail,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          detail,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}