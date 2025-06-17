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
        print("vvvvvvvvvvvviiiiiiiiiiiiiiiiiiisssssssssssssit t3333333333adaaaaaaaaaaaa");
        
        // Afficher la modal de succès
        await _showSuccessModal();
        
        // Essayer de créer le circuit
        await createCircuit();
        return true;
      } else {
        error.value = visiteResult.error ?? 'Une erreur inconnue est survenue lors de la création de la visite.';
        return false;
      }
      
    } catch (e) {
      error.value = 'Erreur inattendue lors de la création de la visite : ${e.toString()}';
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
                  Text('📅 Date : ${_formatDate(selectedDate.value)}'),
                  Text('👤 Client : ${selectedClient?.fullName}'),
                  Text('📋 Raison : ${selectedRaison?.nom}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continuer'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> createCircuit() async {
    if (selectedClient == null) {
      error.value = 'Client non sélectionné pour la création du circuit.';
      return;
    }

    error.value = '';

    try {
      final token = StorageService.getToken();
      if (token == null) {
        error.value = 'Token non trouvé. Veuillez vous reconnecter.';
        return;
      }

      // D'abord, essayer de récupérer le circuit existant pour cette date
      final existingCircuitResult = await _service.getCircuitByDate(
        token: token,
        date: selectedDate.value,
      );

      if (existingCircuitResult.isSuccess && existingCircuitResult.data != null) {
        // Circuit existe déjà, ajouter le client au circuit existant
        print("Circuit existant trouvé, ajout du client au circuit");
        
        final addClientResult = await _service.addClientToCircuit(
          token: token,
          circuitId: existingCircuitResult.data!.id,
          clientId: selectedClient!.id,
        );

        if (addClientResult.isSuccess && addClientResult.data != null) {
          print("Client ajouté au circuit existant avec succès");
          await _showCircuitUpdatedModal(addClientResult.data!);
        } else {
          error.value = addClientResult.error ?? 'Erreur lors de l\'ajout du client au circuit existant.';
        }
      } else {
        // Aucun circuit existant, créer un nouveau circuit
        print("Aucun circuit existant, création d'un nouveau circuit");
        
        final circuitResult = await _service.createCircuit(
          token: token,
          date: selectedDate.value,
          clientId: selectedClient!.id,
        );

        if (circuitResult.isSuccess && circuitResult.data != null && circuitResult.data!.clients.isNotEmpty) {
          print("Nouveau circuit créé avec succès");
          await _showCircuitModal(circuitResult.data!);
        } else {
          error.value = circuitResult.error ?? 'Erreur lors de la création du circuit.';
        }
      }

    } catch (e) {
      error.value = 'Erreur inattendue lors de la gestion du circuit: ${e.toString()}';
    }
  }

  Future<void> _showCircuitModal(dynamic circuitData) async {
    return Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.map, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            const Text('Circuit créé !'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Le circuit a été créé avec succès.',
              style: TextStyle(fontSize: 16),
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
                    'Voulez-vous voir le circuit sur la carte ?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('🗺️ Visualisez le trajet'),
                  Text('📍 Voir tous les clients'),
                  Text('🛣️ Tracer l\'itinéraire'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.mapCircuit, arguments: circuitData);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Voir le circuit'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showCircuitUpdatedModal(dynamic circuitData) async {
    return Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.update, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('Circuit mis à jour !'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Le client a été ajouté au circuit existant.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voulez-vous voir le circuit mis à jour ?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('🗺️ Circuit du ${_formatDate(selectedDate.value)}'),
                  Text('📍 ${circuitData.clients.length} client(s) au total'),
                  Text('✅ Client ajouté avec succès'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.mapCircuit, arguments: circuitData);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Voir le circuit'),
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
} 