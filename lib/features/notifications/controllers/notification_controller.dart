import 'package:get/get.dart';
import 'package:pfe/features/notifications/promotion_service.dart';

class NotificationController extends GetxController {
  final PromotionService _promotionService = PromotionService();
  var promotions = <dynamic>[].obs; // Liste observable de promotions
  var isLoading = true.obs; // État de chargement observable
  var errorMessage = ''.obs; // Message d'erreur observable

  @override
  void onInit() {
    super.onInit();
    print('NotificationController onInit called');
    fetchPromotions(); // Récupérer les promotions au démarrage du contrôleur
  }

  Future<void> fetchPromotions() async {
    try {
      isLoading(true);
      errorMessage('');
      var fetchedPromotions = await _promotionService.fetchPromotions();
      promotions.assignAll(fetchedPromotions); // Mettre à jour la liste observable
    } catch (e) {
      errorMessage('Erreur lors du chargement des promotions: ${e.toString()}');
      print('Erreur dans NotificationController: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
} 