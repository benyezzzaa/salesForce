import 'package:pfe/features/objectif/models/objectif_model.dart';

class HomeModel {
  final List<ObjectifModel> objectifs;
  final List<Map<String, dynamic>> salesByCategory;
  final int reclamationsCount;
  

  HomeModel({
    required this.objectifs,
    required this.salesByCategory,
    required this.reclamationsCount,
  });

  double get currentYearProgress {
    double totalObjectif = 0;
    double totalRealise = 0;

    for (var obj in objectifs) {
      totalObjectif += obj.objectif;
      totalRealise += obj.realise ?? 0.0;
    }

    return totalObjectif > 0 ? (totalRealise / totalObjectif).clamp(0.0, 1.0) : 0.0;
  }
}
