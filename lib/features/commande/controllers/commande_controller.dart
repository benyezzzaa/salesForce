import 'package:get/get.dart';
import '../../../data/models/commande_model.dart';
import '../services/commande_service.dart';

class CommandeController extends GetxController {
  final commandes = <CommandeModel>[].obs;
  final isLoading = false.obs;
  final _service = CommandeService();

  @override
  void onInit() {
    fetchCommandes();
    super.onInit();
  }

  void fetchCommandes() async {
    try {
      isLoading.value = true;
      final data = await _service.getAllCommandes();
      commandes.value = data;
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de chargement des commandes');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCommande(int clientId, Map<int, int> cart) async {
    try {
      isLoading.value = true;

      final String numeroCommande = 'CMD-${DateTime.now().millisecondsSinceEpoch}';

      final lignesCommande = cart.entries.map((e) => {
            'produitId': e.key,
            'quantite': e.value,
          }).toList();

      await _service.envoyerCommande(
        numeroCommande: numeroCommande,
        clientId: clientId,
        lignesCommande: lignesCommande,
      );

      fetchCommandes();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer la commande');
    } finally {
      isLoading.value = false;
    }
  }
}
