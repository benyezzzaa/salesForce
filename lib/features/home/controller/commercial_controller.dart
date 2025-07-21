// 📁 lib/features/home/controller/commercial_controller.dart
import 'package:get/get.dart';
import 'package:pfe/features/objectif/services/objectif_service.dart';
import 'package:pfe/features/home/models/home_model.dart';
import 'package:pfe/features/objectif/models/objectif_model.dart'; // Corrected import

class CommercialController extends GetxController {
  final ObjectifService _objectifService = ObjectifService();
  final homeData = Rx<HomeModel?>(null);
  final RxInt notificationsCount = 0.obs; // ✅ Nouveau champ observable pour notifications
  final RxBool isLoading = false.obs; // ✅ Ajout d'un état de chargement

  @override
  void onInit() {
    super.onInit();
    fetchData();
    fetchNotificationsCount(); // ✅ Appel de la méthode pour charger les notifications
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      print('🔄 CommercialController: Début du chargement des objectifs...');
      
      // Test des endpoints pour debug
      await _objectifService.testEndpoints();
      
      // Fetch objectives from the backend
      final objectifs = await _objectifService.fetchObjectifs();
      print('📊 CommercialController: ${objectifs.length} objectifs récupérés du backend');
      
      // Log details of each objectif
      for (int i = 0; i < objectifs.length; i++) {
        final obj = objectifs[i];
        print('📋 Objectif $i: ${obj.mission} - Cible: ${obj.montantCible}€ - Réalisé: ${obj.ventes}€ - Atteint: ${obj.atteint}');
      }

      // Replace with actual sales data fetch if available
      final sales = <Map<String, dynamic>>[]; 
      final reclamations = 3; // Placeholder, fetch from reclamation controller if available

      final homeModel = HomeModel(
        objectifs: objectifs,
        salesByCategory: sales,
        reclamationsCount: reclamations,
      );

      homeData.value = homeModel;
      print('✅ CommercialController: homeData mis à jour avec ${objectifs.length} objectifs');
      print('🔍 CommercialController: objectifs getter retourne ${this.objectifs.length} objectifs');
    } catch (e) {
      print('❌ CommercialController: Erreur fetchData: $e');
      Get.snackbar('Erreur', 'Échec de chargement des données du tableau de bord');
    } finally {
      isLoading.value = false;
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