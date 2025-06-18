import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pfe/core/utils/storage_services.dart';
import 'package:pfe/core/routes/app_routes.dart';
import '../models/client_model.dart';
import '../models/raison_model.dart';
import '../models/visite_model.dart';
import '../services/visite_service.dart';

class VisiteController extends GetxController {
  final VisiteService _service = VisiteService();
  
  final clients = <ClientModel>[].obs;
  final raisons = <RaisonModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  final selectedDate = DateTime.now().obs;
  ClientModel? selectedClient;
  RaisonModel? selectedRaison;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final token = StorageService.getToken();
      if (token == null) {
        error.value = 'Token non trouvé. Veuillez vous reconnecter.';
        return;
      }
      
      final clientsData = await _service.getClients(token);
      final raisonsData = await _service.getRaisons(token);
      
      clients.value = clientsData;
      raisons.value = raisonsData;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createVisite() async {
    if (selectedClient == null || selectedRaison == null) {
      error.value = 'Veuillez sélectionner un client et une raison';
      return false;
    }

    isLoading.value = true;
    error.value = '';
    
    try {
      final token = StorageService.getToken();
      if (token == null) {
        error.value = 'Token non trouvé. Veuillez vous reconnecter.';
        return false;
      }
      
      final visiteResult = await _service.createVisite(
        token: token,
        date: selectedDate.value,
        clientId: selectedClient!.id,
        raisonId: selectedRaison!.id,
      );

      if (visiteResult.isSuccess) {
        print("Visite créée avec succès");
        
        // Récupérer les informations du commercial connecté
        final commercial = getConnectedCommercial();
        if (commercial != null) {
          // Rediriger vers la page des positions pour voir le commercial et le client
          Get.offAllNamed('/positions-map', arguments: {
            'commercial': commercial,
            'client': selectedClient,
          });
        } else {
          // Fallback vers la page des visites si pas d'infos commercial
          Get.offAllNamed('/all-visites-map');
        }
        return true;
      } else {
        error.value = visiteResult.error ?? 'Une erreur inconnue est survenue lors de la création de la visite.';
        return false;
      }
      
    } catch (e) {
      error.value = 'Erreur inattendue lors de la création de la visite : '+e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _showSuccessModal() async {
    return Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('Visite créée !'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La visite a été créée avec succès.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails de la visite :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('📅 Date : '+_formatDate(selectedDate.value)),
                  Text('👤 Client : '+(selectedClient?.fullName ?? '')),
                  Text('📋 Raison : '+(selectedRaison?.nom ?? '')),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Que souhaitez-vous faire ?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('➕ Créer une autre visite'),
                  Text('🏠 Retourner à l\'accueil'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/home');
            },
            child: const Text('Accueil'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Réinitialiser les sélections pour une nouvelle visite
              selectedClient = null;
              selectedRaison = null;
              // La page se recharge automatiquement
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Nouvelle visite'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  void setClient(ClientModel? client) {
    selectedClient = client;
  }

  void setRaison(RaisonModel? raison) {
    selectedRaison = raison;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Méthode pour récupérer les informations du commercial connecté
  Map<String, dynamic>? getConnectedCommercial() {
    return StorageService.getUser();
  }

  // Méthode pour afficher la carte avec les positions
  void showPositionsMap() {
    if (selectedClient == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez d\'abord sélectionner un client',
        backgroundColor: Get.theme?.colorScheme?.errorContainer,
        colorText: Get.theme?.colorScheme?.onErrorContainer,
      );
      return;
    }

    final commercial = getConnectedCommercial();
    if (commercial == null) {
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer les informations du commercial',
        backgroundColor: Get.theme?.colorScheme?.errorContainer,
        colorText: Get.theme?.colorScheme?.onErrorContainer,
      );
      return;
    }

    // Naviguer vers la page de carte avec les positions
    Get.toNamed('/positions-map', arguments: {
      'commercial': commercial,
      'client': selectedClient,
    });
  }
} 