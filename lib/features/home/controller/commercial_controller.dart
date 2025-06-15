// 📁 lib/features/home/controller/commercial_controller.dart
import 'package:get/get.dart';
import 'package:pfe/features/home/Service/objectif_service.dart';
import 'package:pfe/features/home/models/home_model.dart';
import 'package:pfe/features/home/models/objectif_model.dart';

class CommercialController extends GetxController {
  final ObjectifService service = ObjectifService();
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
      final objectifs = await service.getObjectifsProgress();
      final sales = <Map<String, dynamic>>[]; // À remplacer par appel réel
      final reclamations = 3; // Exemple

      final homeModel = HomeModel(
        objectifs: objectifs,
        salesByCategory: sales,
        reclamationsCount: reclamations,
      );

      homeData.value = homeModel;
    } catch (e) {
      print('Erreur fetchData: \$e');
    }
  }

  Future<void> fetchNotificationsCount() async {
    try {
      // Simule un appel backend à adapter avec ton ApiService
      await Future.delayed(const Duration(milliseconds: 500));
      notificationsCount.value = 4; // Valeur temporaire. Mets ici le vrai nombre
    } catch (e) {
      print('Erreur notifications: \$e');
    }
  }

  List<ObjectifModel> get objectifs => homeData.value?.objectifs ?? [];
  List<Map<String, dynamic>> get salesByCategory => homeData.value?.salesByCategory ?? [];
  int get reclamationsCount => homeData.value?.reclamationsCount ?? 0;
  double get currentYearProgress => homeData.value?.currentYearProgress ?? 0.0;
}