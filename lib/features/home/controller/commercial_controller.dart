// 📁 lib/features/home/controller/commercial_controller.dart
import 'package:get/get.dart';
import 'package:pfe/features/home/Service/objectif_service.dart';
import 'package:pfe/features/home/models/objectif_model.dart';
import 'package:pfe/features/home/models/home_model.dart';

class CommercialController extends GetxController {
  final ObjectifService service = ObjectifService();
  final homeData = Rx<HomeModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void fetchData() async {
    try {
      final objectifs = await service.getGroupedByYear();
      final sales = await service.getSalesByCategory();
      final reclamations = 3; // 🧪 à adapter selon API

      homeData.value = HomeModel(
        objectifsGroupedByYear: objectifs,
        salesByCategory: sales,
        reclamationsCount: reclamations,
      );
    } catch (e) {
      print("❌ Erreur lors du chargement des données: $e");
    }
  }

  // Getters pour faciliter l'accès aux données
  Map<int, List<ObjectifModel>> get objectifsGroupedByYear => 
      homeData.value?.objectifsGroupedByYear ?? {};

  List<Map<String, dynamic>> get salesByCategory => 
      homeData.value?.salesByCategory ?? [];

  int get reclamationsCount => 
      homeData.value?.reclamationsCount ?? 0;

  double get currentYearProgress => 
      homeData.value?.currentYearProgress ?? 0.0;
}
