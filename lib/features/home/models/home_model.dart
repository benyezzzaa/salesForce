import 'objectif_model.dart';

class HomeModel {
  final Map<int, List<ObjectifModel>> objectifsGroupedByYear;
  final List<Map<String, dynamic>> salesByCategory;
  final int reclamationsCount;

  HomeModel({
    required this.objectifsGroupedByYear,
    required this.salesByCategory,
    required this.reclamationsCount,
  });

  double get currentYearProgress {
    final currentYear = DateTime.now().year;
    final objectifsThisYear = objectifsGroupedByYear[currentYear] ?? [];
    
    double achieved = 0;
    double target = 0;
    for (var obj in objectifsThisYear) {
      achieved += obj.realise ?? 0;
      target += obj.objectif ?? 0;
    }
    return target > 0 ? (achieved / target).clamp(0.0, 1.0) : 0.0;
  }
} 