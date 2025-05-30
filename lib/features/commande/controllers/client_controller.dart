import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/core/utils/app_services.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/data/models/client_model.dart';

class ClientController extends GetxController {
  final clients = <ClientModel>[].obs;
  final isLoading = false.obs;
  final ApiService _api = ApiService();

  Future<void> fetchClients() async {
    try {
      isLoading.value = true;
      final response = await _api.get(AppApi.getClientsUrl);
      clients.value = (response.data as List)
          .map((e) => ClientModel.fromJson(e))
          .toList();
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de charger les clients");
    } finally {
      isLoading.value = false;
    }
  }

  Future<ClientModel?> addClient({
    required String nom,
    required String email,
    required String adresse,
    required String telephone,
  }) async {
    try {
      final response = await _api.post(AppApi.getClientsUrl, {
        'nom': nom,
        'email': email,
        'adresse': adresse,
        'telephone': telephone,
      });

      final client = ClientModel.fromJson(response.data);
      clients.add(client);
      return client;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter le client');
      return null;
    }
  }

  Future<void> toggleClientStatus(int clientId, bool isActive) async {
    try {
      final response = await _api.patch('${AppApi.getClientsUrl}/$clientId/status', {
        'isActive': isActive,
      });

      final updatedIndex = clients.indexWhere((c) => c.id == clientId);
      if (updatedIndex != -1) {
        clients[updatedIndex].isActive = isActive;
        clients.refresh();
      }

      Get.snackbar("Succès", "Statut mis à jour avec succès");
    } catch (e) {
      Get.snackbar("Erreur", "Échec de la mise à jour du statut du client");
    }
  }
}
