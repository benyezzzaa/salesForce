import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:pfe/core/utils/app_services.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/core/utils/storage_services.dart';
import 'package:pfe/features/clients/models/client_model.dart';
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
  void toggleClientStatus(int clientId, bool value) async {
    try {
      final token = StorageService.getToken(); // ✅ ICI la correction

      final response = await dio.put(
        'http://localhost:4000/client/$clientId/status',
        data: {"isActive": value},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Remplacer l'affectation directe par une nouvelle instance
      final index = clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        final oldClient = clients[index];
        clients[index] = ClientModel(
          id: oldClient.id,
          nom: oldClient.nom,
          prenom: oldClient.prenom,
          email: oldClient.email,
          telephone: oldClient.telephone,
          adresse: oldClient.adresse,
          isActive: value,
          latitude: oldClient.latitude,
          longitude: oldClient.longitude,
        );
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
    required dynamic categorieId, // Ajouté
  }) async {
    // Formatage automatique du téléphone
    String formattedTelephone = _formatTelephone(telephone);
    print('📞 Téléphone original: $telephone');
    print('📞 Téléphone formaté: $formattedTelephone');
    try {
      // Validation des données avant envoi
      print('🔍 Validation des données client:');
      print('  Nom: "$nom" (longueur: ${nom.length})');
      print('  Prénom: "$prenom" (longueur: ${prenom.length})');
      print('  Email: "$email" (longueur: ${email.length})');
      print('  Téléphone: "$telephone" (longueur: ${telephone.length})');
      print('  Adresse: "$adresse" (longueur: ${adresse.length})');
      print('  Code Fiscal: "$codeFiscale" (longueur: ${codeFiscale.length})');
      print('  Latitude: $latitude');
      print('  Longitude: $longitude');

      // Nettoyage des données - Structure compatible avec NestJS
      final cleanData = {
        'nom': nom.trim(),
        'prenom': prenom.trim(),
        'email': email.trim().toLowerCase(),
        'adresse': adresse.trim(),
        'codeFiscale': codeFiscale.trim(),
        'telephone': formattedTelephone, // ✅ Utilise 'telephone' comme dans la réponse backend
        'latitude': latitude,
        'longitude': longitude,
        'categorieId': categorieId, // Ajouté
      };

      print('📤 Données envoyées au backend: $cleanData');
      print('📡 URL: ${AppApi.getClientsUrl}');

      // Validation finale avant envoi
      if (!_validateClientData(cleanData)) {
        Get.snackbar(
          'Erreur de validation',
          'Certaines données sont invalides',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return null;
      }

      try {
        final response = await _api.post(AppApi.getClientsUrl, cleanData);
        print('✅ Réponse reçue: ${response.statusCode}');
        print('📄 Données reçues: ${response.data}');

        final client = ClientModel.fromJson(response.data);
        clients.add(client);
        
        print('✅ Client ajouté avec succès: ${client.fullName}');
        return client;
      } catch (firstError) {
        print('❌ Première tentative échouée: $firstError');
        
        // Essayer avec une structure alternative (sans champs optionnels)
        try {
          print('🔄 Tentative avec structure alternative...');
          final alternativeData = {
            'nom': nom.trim(),
            'prenom': prenom.trim(),
            'email': email.trim().toLowerCase(),
            'adresse': adresse.trim(),
            'codeFiscale': codeFiscale.trim(),
            'telephone': formattedTelephone, // ✅ Utilise 'telephone' comme dans la réponse backend
            'latitude': latitude,
            'longitude': longitude,
            'categorieId': categorieId, // Ajouté
          };
          
          print('📤 Données alternatives: $alternativeData');
          final response = await _api.post(AppApi.getClientsUrl, alternativeData);
          
          print('✅ Réponse reçue (alternative): ${response.statusCode}');
          final client = ClientModel.fromJson(response.data);
          clients.add(client);
          
          print('✅ Client ajouté avec succès (alternative): ${client.fullName}');
          return client;
        } catch (secondError) {
          print('❌ Deuxième tentative échouée: $secondError');
          
          // Troisième tentative avec structure minimale
          try {
            print('🔄 Tentative avec structure minimale...');
            final minimalData = {
              'nom': nom.trim(),
              'prenom': prenom.trim(),
              'email': email.trim().toLowerCase(),
              'adresse': adresse.trim(),
              'codeFiscale': codeFiscale.trim(),
              'telephone': formattedTelephone, // ✅ Utilise 'telephone' comme dans la réponse backend
              'categorieId': categorieId, // Ajouté
            };
            
            print('📤 Données minimales: $minimalData');
            final response = await _api.post(AppApi.getClientsUrl, minimalData);
            
            print('✅ Réponse reçue (minimale): ${response.statusCode}');
            final client = ClientModel.fromJson(response.data);
            clients.add(client);
            
            print('✅ Client ajouté avec succès (minimale): ${client.fullName}');
            return client;
          } catch (thirdError) {
            print('❌ Troisième tentative échouée: $thirdError');
            rethrow; // Relancer l'erreur originale
          }
        }
      }
    } catch (e) {
      print('❌ Erreur lors de l\'ajout du client: $e');
      
      // Gestion détaillée des erreurs
      if (e.toString().contains('DioException')) {
        if (e.toString().contains('status code of 400')) {
          // Essayer de récupérer les détails de l'erreur
          String errorMessage = 'Vérifiez que tous les champs sont correctement remplis';
          
          try {
            // Si c'est une DioException, on peut récupérer la réponse
            if (e is DioException && e.response != null) {
              final errorData = e.response!.data;
              print('📄 Détails de l\'erreur 400: $errorData');
              
              if (errorData != null && errorData is Map<String, dynamic>) {
                if (errorData['message'] != null) {
                  errorMessage = errorData['message'].toString();
                } else if (errorData['error'] != null) {
                  errorMessage = errorData['error'].toString();
                } else if (errorData['errors'] != null) {
                  // Gestion des erreurs de validation
                  final errors = errorData['errors'];
                  if (errors is List && errors.isNotEmpty) {
                    errorMessage = errors.join(', ');
                  }
                }
              }
            }
          } catch (parseError) {
            print('❌ Erreur lors du parsing de l\'erreur: $parseError');
          }
          
          Get.snackbar(
            'Erreur de validation',
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 6),
          );
        } else if (e.toString().contains('status code of 409')) {
          Get.snackbar(
            'Client existant',
            'Un client avec cet email ou code fiscal existe déjà',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        } else if (e.toString().contains('status code of 500')) {
          // Essayer de récupérer les détails de l'erreur 500
          String errorMessage = 'Problème côté serveur. Contactez l\'administrateur';
          
          try {
            if (e is DioException && e.response != null) {
              final errorData = e.response!.data;
              print('📄 Détails de l\'erreur 500: $errorData');
              
              if (errorData != null && errorData is Map<String, dynamic>) {
                if (errorData['message'] != null) {
                  errorMessage = errorData['message'].toString();
                } else if (errorData['error'] != null) {
                  errorMessage = errorData['error'].toString();
                }
              }
            }
          } catch (parseError) {
            print('❌ Erreur lors du parsing de l\'erreur 500: $parseError');
          }
          
          Get.snackbar(
            'Erreur serveur',
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 6),
          );
        } else {
          Get.snackbar(
            'Erreur de communication',
            'Impossible de communiquer avec le serveur',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
      } else {
        Get.snackbar(
          'Erreur inattendue',
          'Une erreur inattendue s\'est produite: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
      
      return null;
    }
  }

  // Méthode pour récupérer les informations du commercial connecté
  Map<String, dynamic>? getConnectedCommercial() {
    return StorageService.getUser();
  }

  // Méthode de validation des données client
  bool _validateClientData(Map<String, dynamic> data) {
    try {
      // Vérifications de base
      if (data['nom'] == null || data['nom'].toString().isEmpty) {
        print('❌ Nom manquant ou vide');
        return false;
      }
      
      if (data['prenom'] == null || data['prenom'].toString().isEmpty) {
        print('❌ Prénom manquant ou vide');
        return false;
      }
      
      if (data['email'] == null || data['email'].toString().isEmpty) {
        print('❌ Email manquant ou vide');
        return false;
      }
      
      if (data['telephone'] == null || data['telephone'].toString().isEmpty) {
        print('❌ Téléphone manquant ou vide');
        return false;
      }
      
      // Validation spécifique du téléphone français
      final telephone = data['telephone'].toString();
      final cleanTelephone = telephone.replaceAll(RegExp(r'[^\d+]'), '');
      
      if (!RegExp(r'^(\+33|0|33)[1-9](\d{8})$').hasMatch(cleanTelephone)) {
        print('❌ Format téléphone invalide: $telephone (nettoyé: $cleanTelephone)');
        print('   Format attendu: 0612345678, +33612345678 ou 33612345678');
        return false;
      }
      
      print('✅ Téléphone valide: $telephone');
      
      if (data['adresse'] == null || data['adresse'].toString().isEmpty) {
        print('❌ Adresse manquante ou vide');
        return false;
      }
      
      if (data['codeFiscale'] == null || data['codeFiscale'].toString().isEmpty) {
        print('❌ Code fiscal manquant ou vide');
        return false;
      }
      
      if (data['latitude'] == null || data['longitude'] == null) {
        print('❌ Coordonnées manquantes');
        return false;
      }
      
      // Validation spécifique
      final email = data['email'].toString();
      if (!email.contains('@') || email.length < 5) {
        print('❌ Email invalide: $email');
        return false;
      }
      
      final codeFiscale = data['codeFiscale'].toString();
      if (!RegExp(r'^\d{13}$').hasMatch(codeFiscale)) {
        print('❌ Code fiscal invalide: $codeFiscale');
        return false;
      }
      
      print('✅ Validation des données réussie');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la validation: $e');
      return false;
    }
  }
  
  /// Formatage automatique du téléphone français
  String _formatTelephone(String telephone) {
    final cleanNumber = telephone.replaceAll(RegExp(r'[^\d+]'), '');
    
    print('📞 Formatage téléphone: $telephone -> $cleanNumber');
    
    // Si c'est déjà au format international, le retourner
    if (cleanNumber.startsWith('+33') && cleanNumber.length == 12) {
      print('✅ Déjà au format international: $cleanNumber');
      return cleanNumber;
    }
    
    // Si c'est au format national (0XXXXXXXXX), le convertir
    if (cleanNumber.startsWith('0') && cleanNumber.length == 10) {
      final formatted = '+33${cleanNumber.substring(1)}';
      print('✅ Converti national vers international: $cleanNumber -> $formatted');
      return formatted;
    }
    
    // Si c'est au format 33XXXXXXXXX, ajouter le +
    if (cleanNumber.startsWith('33') && cleanNumber.length == 11) {
      final formatted = '+$cleanNumber';
      print('✅ Ajouté + au format 33: $cleanNumber -> $formatted');
      return formatted;
    }
    
    // Sinon, retourner le numéro tel quel
    print('⚠️ Format non reconnu, retourné tel quel: $cleanNumber');
    return cleanNumber;
  }
}
