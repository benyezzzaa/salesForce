import 'package:get/get.dart';
import '../models/commande_model.dart';
import '../services/commande_service.dart';
import 'package:pfe/features/visite/models/client_model.dart';

class CommandeController extends GetxController {
  final commandes = <CommandeModel>[].obs;
  final isLoading = false.obs;
  final _service = CommandeService();
  final selectedClient = Rxn<ClientModel>();

  @override
  void onInit() {
    fetchCommandes();
    super.onInit();
  }

  Future<void> fetchCommandes() async {
    try {
      isLoading.value = true;
      final data = await _service.getAllCommandes();
      commandes.value = data;
    } catch (e) {
      Get.snackbar(
        'Erreur', 
        'Échec de chargement des commandes',
        backgroundColor: Get.theme?.colorScheme?.errorContainer,
        colorText: Get.theme?.colorScheme?.onErrorContainer,
      );
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

      // Rafraîchir les données après création
      fetchCommandes();
      
      Get.snackbar(
        'Succès', 
        'Commande créée avec succès ✅',
        backgroundColor: Get.theme?.colorScheme?.primaryContainer,
        colorText: Get.theme?.colorScheme?.onPrimaryContainer,
      );
      
      // Retourner à la page des commandes
      Get.offNamed('/commercial-orders');
    } catch (e) {
      print(e);
      // Get.snackbar(
      //   'Erreur', 
      //   'Impossible de créer la commande',
      //   backgroundColor: Get.theme?.colorScheme?.errorContainer,
      //   colorText: Get.theme?.colorScheme?.onErrorContainer,
      // );
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedClient(ClientModel client) {
    selectedClient.value = client;
  }

  // Méthode pour rafraîchir les données
  void refreshCommandes() {
    fetchCommandes();
  }
}
