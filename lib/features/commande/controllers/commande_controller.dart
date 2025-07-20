import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/commande_model.dart';
import '../services/commande_service.dart';
import 'package:pfe/features/clients/models/client_model.dart';
import '../models/promotion_model.dart';

class CommandeController extends GetxController {
  final commandes = <CommandeModel>[].obs;
  final isLoading = false.obs;
  final _service = CommandeService();
  final selectedClient = Rxn<ClientModel>();
  final Rx<Promotion?> selectedPromotion = Rx<Promotion?>(null);

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
    
    final promotion = selectedPromotion.value;
    // La promotion est totalement optionnelle :
    // Si aucune promotion n'est sélectionnée, la commande sera créée sans promotion côté backend.
    print('🔍 CommandeController: Promotion sélectionnée =  [32m${promotion?.titre} [0m (ID: ${promotion?.id})');
    
    final payload = {
      'numeroCommande': 'CMD- [34m${DateTime.now().millisecondsSinceEpoch} [0m',
      'clientId': clientId,
      'lignesCommande': cart.entries.map((entry) => {
        'produitId': entry.key,
        'quantite': entry.value,
      }).toList(),
    };
    
    // Ajouter promotionId seulement si une promotion est sélectionnée
    if (promotion != null) {
      payload['promotionId'] = promotion.id;
    }
    // Si aucune promotion, le champ n'est pas envoyé du tout
    
    print('Payload envoyé : $payload');

    await _service.envoyerCommande(payload);

    // Rafraîchir les données après création
    await fetchCommandes();
    
    // Afficher la popup de confirmation
    await _showSuccessDialog();
    
  } catch (e) {
    print("❌ Exception pendant l'envoi de la commande : $e");
    Get.snackbar(
      'Erreur', 
      'Échec de l\'envoi de la commande',
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
