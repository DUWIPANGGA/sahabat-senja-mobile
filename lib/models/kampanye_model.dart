

class KampanyeDonasi {
  int id;
  String judul;
  String slug;
  String deskripsiSingkat;
  String? deskripsi;
  String gambar;
  String? thumbnail;
  double targetDana;
  double danaTerkumpul;
  int progress;
  int hariTersisa;
  bool isActive;
  String kategori;
  String status;
  bool isFeatured;
  int jumlahDonatur;
  int jumlahDilihat;
  DateTime tanggalMulai;
  DateTime tanggalSelesai;
  DateTime createdAt;
  String? terimaKasihPesan;
  Map<String, dynamic>? datalansia;
  List<String>? gallery;
  List<Map<String, dynamic>>? recentDonations;
  List<Map<String, dynamic>>? similarCampaigns;

  KampanyeDonasi({
    required this.id,
    required this.judul,
    required this.slug,
    required this.deskripsiSingkat,
    this.deskripsi,
    required this.gambar,
    this.thumbnail,
    required this.targetDana,
    required this.danaTerkumpul,
    required this.progress,
    required this.hariTersisa,
    required this.isActive,
    required this.kategori,
    required this.status,
    required this.isFeatured,
    required this.jumlahDonatur,
    required this.jumlahDilihat,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.createdAt,
    this.terimaKasihPesan,
    this.datalansia,
    this.gallery,
    this.recentDonations,
    this.similarCampaigns,
  });

  factory KampanyeDonasi.fromJson(Map<String, dynamic> json) {
    return KampanyeDonasi(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      slug: json['slug'] ?? '',
      deskripsiSingkat: json['deskripsi_singkat'] ?? '',
      deskripsi: json['deskripsi'],
      gambar: json['gambar'] ?? '',
      thumbnail: json['thumbnail'],
      targetDana: _parseAmount(json['target_dana']),
      danaTerkumpul: _parseAmount(json['dana_terkumpul']),
      progress: (json['progress'] is num ? json['progress'].toInt() : 0),
      hariTersisa: (json['hari_tersisa'] is num ? json['hari_tersisa'].toInt() : 0),
      isActive: json['is_active'] ?? false,
      kategori: json['kategori'] ?? '',
      status: json['status'] ?? '',
      isFeatured: json['is_featured'] ?? false,
      jumlahDonatur: (json['jumlah_donatur'] is num ? json['jumlah_donatur'].toInt() : 0),
      jumlahDilihat: (json['jumlah_dilihat'] is num ? json['jumlah_dilihat'].toInt() : 0),
      tanggalMulai: _parseDate(json['tanggal_mulai']),
      tanggalSelesai: _parseDate(json['tanggal_selesai']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      terimaKasihPesan: json['terima_kasih_pesan'],
      datalansia: json['datalansia'] is Map ? Map<String, dynamic>.from(json['datalansia']) : null,
      gallery: json['galeri'] is List ? List<String>.from(json['galeri']) : null,
      recentDonations: json['recent_donations'] is List 
          ? List<Map<String, dynamic>>.from(json['recent_donations'])
          : null,
      similarCampaigns: json['similar_campaigns'] is List
          ? List<Map<String, dynamic>>.from(json['similar_campaigns'])
          : null,
    );
  }

  // Helper function untuk parse tanggal dengan berbagai format
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }

    final String dateString = dateValue.toString();
    
    try {
      // Format: "26 Nov 2025" (dari API Laravel)
      if (dateString.contains(' ')) {
        final parts = dateString.split(' ');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]) ?? 1;
          final month = _getMonthNumber(parts[1]);
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          return DateTime(year, month, day);
        }
      }
      
      // Format ISO: "2025-11-26T00:00:00.000000Z"
      if (dateString.contains('T')) {
        return DateTime.parse(dateString);
      }
      
      // Format Y-m-d: "2025-11-26"
      if (dateString.contains('-')) {
        final parts = dateString.split('-');
        if (parts.length == 3) {
          final year = int.tryParse(parts[0]) ?? DateTime.now().year;
          final month = int.tryParse(parts[1]) ?? 1;
          final day = int.tryParse(parts[2]) ?? 1;
          return DateTime(year, month, day);
        }
      }
      
      return DateTime.now();
    } catch (e) {
      print('⚠️ Error parsing date "$dateString": $e');
      return DateTime.now();
    }
  }

  // Convert month name to number
  static int _getMonthNumber(String monthName) {
    final months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      'Januari': 1, 'Februari': 2, 'Maret': 3, 'April': 4, 'Mei': 5, 'Juni': 6,
      'Juli': 7, 'Agustus': 8, 'September': 9, 'Oktober': 10, 'November': 11, 'Desember': 12,
      '01': 1, '02': 2, '03': 3, '04': 4, '05': 5, '06': 6,
      '07': 7, '08': 8, '09': 9, '10': 10, '11': 11, '12': 12,
    };
    
    // Ambil 3 karakter pertama untuk short month
    final shortName = monthName.length > 3 ? monthName.substring(0, 3) : monthName;
    return months[shortName] ?? months[monthName] ?? DateTime.now().month;
  }

  // Helper function untuk parse amount (bisa string "Rp 1.000.000" atau angka)
  static double _parseAmount(dynamic amountValue) {
    if (amountValue == null) return 0;
    
    if (amountValue is num) {
      return amountValue.toDouble();
    }
    
    final String amountStr = amountValue.toString();
    
    try {
      // Jika ada format currency "Rp 1.000.000"
      if (amountStr.contains('Rp')) {
        final cleanStr = amountStr
            .replaceAll('Rp', '')
            .replaceAll('.', '')
            .replaceAll(',', '.')
            .trim();
        return double.tryParse(cleanStr) ?? 0;
      }
      
      // Coba parse langsung
      return double.tryParse(amountStr) ?? 0;
    } catch (e) {
      print('⚠️ Error parsing amount "$amountStr": $e');
      return 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'slug': slug,
      'deskripsi_singkat': deskripsiSingkat,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'thumbnail': thumbnail,
      'target_dana': targetDana,
      'dana_terkumpul': danaTerkumpul,
      'progress': progress,
      'hari_tersisa': hariTersisa,
      'is_active': isActive,
      'kategori': kategori,
      'status': status,
      'is_featured': isFeatured,
      'jumlah_donatur': jumlahDonatur,
      'jumlah_dilihat': jumlahDilihat,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_selesai': tanggalSelesai.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'terima_kasih_pesan': terimaKasihPesan,
      'datalansia': datalansia,
      'gallery': gallery,
      'recent_donations': recentDonations,
      'similar_campaigns': similarCampaigns,
    };
  }

  // Helper methods
  String get formattedTargetDana {
    return _formatCurrency(targetDana);
  }

  String get formattedDanaTerkumpul {
    return _formatCurrency(danaTerkumpul);
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(1)} Rb';
    } else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }

  String get daysLeftText {
    if (hariTersisa == 0) return 'Berakhir';
    if (hariTersisa == 1) return '1 hari lagi';
    if (hariTersisa < 0) return '${hariTersisa.abs()} hari terlambat';
    return '$hariTersisa hari lagi';
  }

  bool get isExpired => hariTersisa < 0;
  bool get isAlmostExpired => hariTersisa > 0 && hariTersisa <= 7;
  
  String get formattedTanggalMulai {
    return _formatDateDisplay(tanggalMulai);
  }
  
  String get formattedTanggalSelesai {
    return _formatDateDisplay(tanggalSelesai);
  }
  
  String get formattedCreatedAt {
    return _formatDateDisplay(createdAt);
  }
  
  String _formatDateDisplay(DateTime date) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }
}