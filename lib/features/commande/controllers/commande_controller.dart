import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/commande_model.dart';
import '../services/commande_service.dart';
import 'package:pfe/features/clients/models/client_model.dart';

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
      
      // Afficher la popup de confirmation
      await _showSuccessDialog();
      
    } catch (e) {
      print(e);
      Get.snackbar(
        'Erreur', 
        'Impossible de créer la commande',
        backgroundColor: Get.theme?.colorScheme?.errorContainer,
        colorText: Get.theme?.colorScheme?.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _showSuccessDialog() async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Succès', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Commande créée avec succès !',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Fermer la popup
              Get.offAllNamed('/commandes'); // Naviguer vers la page des commandes
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: Get.theme?.colorScheme?.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void setSelectedClient(ClientModel client) {
    selectedClient.value = client;
  }

  // Méthode pour rafraîchir les données
  void refreshCommandes() {
    fetchCommandes();
  }
}
