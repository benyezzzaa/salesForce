import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:pfe/core/utils/app_services.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/core/utils/storage_services.dart';
import 'package:pfe/features/visite/models/client_model.dart';
// 👈 AJOUT ICI

class ClientController extends GetxController {
  final clients = <ClientModel>[].obs;
  final isLoading = false.obs;
  final ApiService _api = ApiService(); // ✅ Tu utilises bien ApiService
  final Dio dio = Dio(); // pour les appels manuels

  /// 🔄 Charger les clients du commercial connecté
  Future<void> fetchMesClients() async {
    try {
      isLoading.value = true;
      final response = await _api.get("${AppApi.getClientsUrl}/mes-clients");
      
      // Log plus visible des données
      print("\n\n=== DONNÉES CLIENTS ===");
      print("Nombre total de clients: ${(response.data as List).length}");
      
      clients.value = (response.data as List)
          .map((e) => ClientModel.fromJson(e))
          .toList();
      
      // Log des clients avec leurs coordonnées
      print("\n=== COORDONNÉES CLIENTS ===");
      for (var client in clients) {
        print("Client: ${client.fullName}");
        print("  - Latitude: ${client.latitude}");
        print("  - Longitude: ${client.longitude}");
        print("  - Adresse: ${client.adresse}");
        print("-------------------");
      }
      
      // Compte des clients avec coordonnées
      final clientsWithCoords = clients.where((c) => 
        c.latitude != null && c.longitude != null
      ).length;
      
      print("\n=== RÉSUMÉ ===");
      print("Total clients: ${clients.length}");
      print("Clients avec coordonnées: $clientsWithCoords");
      print("Clients sans coordonnées: ${clients.length - clientsWithCoords}");
      print("===================\n\n");
      
    } catch (e) {
      print("\n=== ERREUR ===");
      print("Erreur lors du chargement des clients: $e");
      print("===================\n\n");
      Get.snackbar("Erreur", "Impossible de charger vos clients");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Activer / désactiver un client
  Future<void> toggleClientStatus(int id, bool newStatus) async {
    try {
      final token = StorageService.getToken(); // ✅ ICI la correction

      final response = await dio.put(
        'http://localhost:4000/client/$id/status',
        data: {"isActive": newStatus},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final index = clients.indexWhere((c) => c.id == id);
      if (index != -1) {
        clients[index].isActive = newStatus;
        clients.refresh();
      }

      Get.snackbar("Succès", "Statut du client mis à jour");
    } catch (e) {
      print("Erreur changement statut client : $e");
      Get.snackbar("Erreur", "Impossible de modifier le statut du client");
    }
  }

  /// ➕ Ajouter un client
  Future<ClientModel?> addClient({
    required String nom,
    required String prenom,
    required String email,
    required String adresse,
    required String telephone,
    required double latitude,
    required double longitude,
    required String codeFiscale,
  }) async {
    try {
      final response = await _api.post(AppApi.getClientsUrl, {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'adresse': adresse,
        'codeFiscale': codeFiscale,
        'telephone': telephone,
        'latitude': latitude,
        'longitude': longitude,
        'estFidele': true,
      });

      final client = ClientModel.fromJson(response.data);
      clients.add(client);
      return client;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter le client');
      return null;
    }
  }

  // Méthode pour récupérer les informations du commercial connecté
  Map<String, dynamic>? getConnectedCommercial() {
    return StorageService.getUser();
  }
}
