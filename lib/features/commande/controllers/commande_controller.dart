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

  void setSelectedClient(ClientModel client) {
    selectedClient.value = client;
  }
}
