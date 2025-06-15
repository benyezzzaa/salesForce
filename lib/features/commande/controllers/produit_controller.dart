import 'package:get/get.dart';
import '../services/produit_service.dart';
import '../models/produit_model.dart';

class ProduitController extends GetxController {
  final produits = <ProduitModel>[].obs;
  final isLoading = false.obs;
  final _service = ProduitService();

  @override
  void onInit() {
    fetchProduits();
    super.onInit();
  }

  void fetchProduits() async {
    try {
      isLoading.value = true;
      final data = await _service.getAllProduits();
      produits.value = data.map((e) => ProduitModel.fromJson(e)).toList();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les produits');
    } finally {
      isLoading.value = false;
    }
  }
}
