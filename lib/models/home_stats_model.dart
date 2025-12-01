// lib/models/home_stats_model.dart
import 'package:sahabatsenja_app/models/datalansia_model.dart';
import 'package:sahabatsenja_app/models/kondisi_model.dart';

class HomeStats {
  final int totalLansia;
  final int lansiaStabil;
  final int lansiaPerluPerhatian;
  final int notifikasiCount;
  final List<KondisiHarian> kondisiTerbaru;
  final List<Datalansia> lansiaList;

  HomeStats({
    required this.totalLansia,
    required this.lansiaStabil,
    required this.lansiaPerluPerhatian,
    required this.notifikasiCount,
    required this.kondisiTerbaru,
    required this.lansiaList,
  });

  factory HomeStats.empty() {
    return HomeStats(
      totalLansia: 0,
      lansiaStabil: 0,
      lansiaPerluPerhatian: 0,
      notifikasiCount: 0,
      kondisiTerbaru: [],
      lansiaList: [],
    );
  }
}