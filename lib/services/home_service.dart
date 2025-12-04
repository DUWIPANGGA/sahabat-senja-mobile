// lib/services/home_service.dart
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/models/kondisi_model.dart';
import 'package:sahabatsenja_app/services/datalansia_service.dart';
import 'package:sahabatsenja_app/services/kondisi_service.dart';
import 'package:sahabatsenja_app/services/keluarga_service.dart' hide DatalansiaService;
import 'package:sahabatsenja_app/models/home_stats_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
  final DatalansiaService _datalansiaService = DatalansiaService();
  final KondisiService _kondisiService = KondisiService();
  final KeluargaService _keluargaService = KeluargaService();

  Future<HomeStats> getHomeStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      
      // 1. Get lansia list
      List<Datalansia> lansiaList = [];
      if (userEmail != null) {
        lansiaList = await _datalansiaService.getDatalansiaByKeluarga(userEmail);
      } else {
        lansiaList = await _keluargaService.getLansiaTerhubung();
      }

      // 2. Get latest conditions
      final List<KondisiHarian> kondisiTerbaru = [];
      for (var lansia in lansiaList) {
        final kondisi = await _kondisiService.getTodayData(lansia.namaLansia ?? '');
        if (kondisi != null) {
          kondisiTerbaru.add(kondisi);
        }
      }

      // 3. Calculate stats
      final totalLansia = lansiaList.length;
      final lansiaStabil = kondisiTerbaru.where((k) {
        final nadi = int.tryParse(k.nadi ?? '0') ?? 0;
        return nadi >= 60 && nadi <= 100;
      }).length;
      final lansiaPerluPerhatian = totalLansia - lansiaStabil;
      final notifikasiCount = lansiaPerluPerhatian;

      return HomeStats(
        totalLansia: totalLansia,
        lansiaStabil: lansiaStabil,
        lansiaPerluPerhatian: lansiaPerluPerhatian,
        notifikasiCount: notifikasiCount,
        kondisiTerbaru: kondisiTerbaru,
        lansiaList: lansiaList,
      );
    } catch (e) {
      print('❌ Error getHomeStats: $e');
      return HomeStats.empty();
    }
  }
}