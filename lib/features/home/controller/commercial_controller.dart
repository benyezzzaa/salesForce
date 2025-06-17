// 📁 lib/features/home/controller/commercial_controller.dart
import 'package:get/get.dart';
import 'package:pfe/features/objectif/services/objectif_service.dart';
import 'package:pfe/features/home/models/home_model.dart';
import 'package:pfe/features/objectif/models/objectif_model.dart'; // Corrected import

class CommercialController extends GetxController {
  final ObjectifService _objectifService = ObjectifService();
  final homeData = Rx<HomeModel?>(null);
  final RxInt notificationsCount = 0.obs; // ✅ Nouveau champ observable pour notifications

  @override
  void onInit() {
    super.onInit();
    fetchData();
    fetchNotificationsCount(); // ✅ Appel de la méthode pour charger les notifications
  }

  Future<void> fetchData() async {
    try {
      // Fetch objectives from the new service
      final objectifs = await _objectifService.fetchObjectifs();

      // Replace with actual sales data fetch if available
      final sales = <Map<String, dynamic>>[]; 
      final reclamations = 3; // Placeholder, fetch from reclamation controller if available

      final homeModel = HomeModel(
        objectifs: objectifs,
        salesByCategory: sales,
        reclamationsCount: reclamations,
      );

      homeData.value = homeModel;
    } catch (e) {
      print('Erreur fetchData: $e');
      Get.snackbar('Erreur', 'Échec de chargement des données du tableau de bord');
    }
  }

  Future<void> fetchNotificationsCount() async {
    try {
      // Simule un appel backend à adapter avec ton ApiService
      await Future.delayed(const Duration(milliseconds: 500));
      notificationsCount.value = 4; // Valeur temporaire. Mets ici le vrai nombre
    } catch (e) {
      print('Erreur notifications: $e');
    }
  }

  List<ObjectifModel> get objectifs => homeData.value?.objectifs ?? [];
  List<Map<String, dynamic>> get salesByCategory => homeData.value?.salesByCategory ?? [];
  int get reclamationsCount => homeData.value?.reclamationsCount ?? 0;
}