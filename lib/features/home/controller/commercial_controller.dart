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
    print('CommercialController onInit called. Fetching data...');
    fetchData();
  }

  void fetchData() async {
    print('fetchData started.');
    try {
      print('Fetching objectifs...');
      final objectifs = await service.getGroupedByYear();
      print('Objectifs fetched: ${objectifs.length} groups.');

      print('Fetching sales...');
      final sales = await service.getSalesByCategory();
      print('Sales fetched: ${sales.length} categories.');

      final reclamations = 3; // 🧪 à adapter selon API
      print('Reclamations count (hardcoded): $reclamations.');

      final fetchedHomeData = HomeModel(
        objectifsGroupedByYear: objectifs,
        salesByCategory: sales,
        reclamationsCount: reclamations,
      );
      homeData.value = fetchedHomeData;
      print('homeData updated with new data.');

    } catch (e) {
      print("❌ Erreur lors du chargement des données dans CommercialController: $e");
      // Optionally, you could set an error message observable here
      // errorMessage.value = 'Failed to load data';
    } finally {
      print('fetchData finished.');
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
