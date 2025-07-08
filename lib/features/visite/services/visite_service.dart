import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/features/clients/models/client_model.dart';
import '../models/raison_model.dart';
import '../models/visite_model.dart';
import '../models/circuit_model.dart';

class Result<T> {
  final T? data;
  final String? error;

  Result.success(this.data) : error = null;
  Result.error(this.error) : data = null;

  bool get isSuccess => error == null;
}

class VisiteService {

  Future<List<ClientModel>> getClients(String token) async {
    final response = await http.get(
      Uri.parse('${AppApi.baseUrl}/client'),
      headers: {
        'Authorization': 'Bearer $token',
         'Content-Type': 'application/json',
      },
    );

    print('Réponse API clients : ' + response.body);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ClientModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clients');
    }
  }

  Future<List<RaisonModel>> getRaisons(String token) async {
    final response = await http.get(
      Uri.parse('${AppApi.baseUrl}/raisons/actives'),
      headers: {
        'Authorization': 'Bearer $token',
         'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RaisonModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load raisons');
    }
  }

  Future<List<VisiteModel>> getAllVisites(String token) async {
    try {
      print('🔄 Appel API getAllVisites...');
      
      // Essayer d'abord l'endpoint spécifique au commercial connecté
      String url = AppApi.getMyVisitesUrl;
      print('   URL: $url');
      print('   Token: ${token.substring(0, 10)}...');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Réponse API getAllVisites:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('   ✅ Données parsées: ${data.length} visites');
        
        final visites = data.map((json) => VisiteModel.fromJson(json)).toList();
        
        // Analyser chaque visite
        for (int i = 0; i < visites.length; i++) {
          final visite = visites[i];
          final hasCoords = visite.client.latitude != null && visite.client.longitude != null;
          print('   ${i + 1}. Visite ${visite.id} - Client: ${visite.client.fullName} - Date: ${visite.date} - Coordonnées: ${hasCoords ? "✅" : "❌"}');
        }
        
        return visites;
      } else if (response.statusCode == 404) {
        // Si l'endpoint spécifique n'existe pas, essayer l'endpoint général
        print('⚠️ Endpoint spécifique non trouvé, essai avec l\'endpoint général...');
        return await _getAllVisitesGeneral(token);
      } else {
        print('❌ Erreur API getAllVisites - Status: ${response.statusCode}');
        print('   Body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getAllVisites: $e');
      // En cas d'erreur, essayer l'endpoint général
      return await _getAllVisitesGeneral(token);
    }
  }

  Future<List<VisiteModel>> _getAllVisitesGeneral(String token) async {
    try {
      print('🔄 Appel API getAllVisites (endpoint général)...');
      print('   URL: ${AppApi.getVisitesUrl}');
      
      final response = await http.get(
        Uri.parse(AppApi.getVisitesUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Réponse API getAllVisites (général):');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('   ✅ Données parsées (général): ${data.length} visites');
        
        final visites = data.map((json) => VisiteModel.fromJson(json)).toList();
        
        // Analyser chaque visite
        for (int i = 0; i < visites.length; i++) {
          final visite = visites[i];
          final hasCoords = visite.client.latitude != null && visite.client.longitude != null;
          print('   ${i + 1}. Visite ${visite.id} - Client: ${visite.client.fullName} - Date: ${visite.date} - Coordonnées: ${hasCoords ? "✅" : "❌"}');
        }
        
        return visites;
      } else {
        print('❌ Erreur API getAllVisites (général) - Status: ${response.statusCode}');
        print('   Body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getAllVisites (général): $e');
      return [];
    }
  }

  Future<List<CircuitModel>> getAllCircuits(String token) async {
    try {
      print('🔄 Appel API getAllCircuits...');
      
      // Essayer d'abord l'endpoint spécifique au commercial connecté
      String url = AppApi.getMyCircuitsUrl;
      print('   URL: $url');
      print('   Token: ${token.substring(0, 10)}...');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Réponse API getAllCircuits:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('   ✅ Données parsées: ${data.length} circuits');
        
        final circuits = data.map((json) => CircuitModel.fromJson(json)).toList();
        
        // Analyser chaque circuit
        for (int i = 0; i < circuits.length; i++) {
          final circuit = circuits[i];
          print('   ${i + 1}. Circuit ${circuit.id} - Date: ${circuit.date} - Clients: ${circuit.clients.length}');
          for (int j = 0; j < circuit.clients.length; j++) {
            final client = circuit.clients[j];
            final hasCoords = client.latitude != null && client.longitude != null;
            print('      ${j + 1}. Client: ${client.fullName} - Coordonnées: ${hasCoords ? "✅" : "❌"}');
          }
        }
        
        return circuits;
      } else if (response.statusCode == 404) {
        // Si l'endpoint spécifique n'existe pas, essayer l'endpoint général
        print('⚠️ Endpoint spécifique non trouvé, essai avec l\'endpoint général...');
        return await _getAllCircuitsGeneral(token);
      } else {
        print('❌ Erreur API getAllCircuits - Status: ${response.statusCode}');
        print('   Body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getAllCircuits: $e');
      // En cas d'erreur, essayer l'endpoint général
      return await _getAllCircuitsGeneral(token);
    }
  }

  Future<List<CircuitModel>> _getAllCircuitsGeneral(String token) async {
    try {
      print('🔄 Appel API getAllCircuits (endpoint général)...');
      print('   URL: ${AppApi.getCircuitsUrl}');
      
      final response = await http.get(
        Uri.parse(AppApi.getCircuitsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Réponse API getAllCircuits (général):');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('   ✅ Données parsées (général): ${data.length} circuits');
        
        final circuits = data.map((json) => CircuitModel.fromJson(json)).toList();
        
        // Analyser chaque circuit
        for (int i = 0; i < circuits.length; i++) {
          final circuit = circuits[i];
          print('   ${i + 1}. Circuit ${circuit.id} - Date: ${circuit.date} - Clients: ${circuit.clients.length}');
          for (int j = 0; j < circuit.clients.length; j++) {
            final client = circuit.clients[j];
            final hasCoords = client.latitude != null && client.longitude != null;
            print('      ${j + 1}. Client: ${client.fullName} - Coordonnées: ${hasCoords ? "✅" : "❌"}');
          }
        }
        
        return circuits;
      } else {
        print('❌ Erreur API getAllCircuits (général) - Status: ${response.statusCode}');
        print('   Body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getAllCircuits (général): $e');
      return [];
    }
  }

  Future<Result<VisiteModel>> createVisite({
    required String token,
    required DateTime date,
    required int clientId,
    required int raisonId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppApi.baseUrl}/visites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'date': date.toIso8601String(),
          'clientId': clientId,
          'raisonId': raisonId,
        }),
      );

      if (response.statusCode == 201) {
        return Result.success(VisiteModel.fromJson(json.decode(response.body)));
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to create visite';
        print('Failed to create visite - Status Code: ${response.statusCode}');
        print('Error Message: $errorMessage');
        return Result.error(errorMessage);
      }
    } catch (e) {
      print('Exception during visite creation: $e');
      return Result.error('Une erreur est survenue lors de la création de la visite');
    }
  }

  Future<Result<CircuitModel>> createCircuit({
    required String token,
    required DateTime date,
    required int clientId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppApi.baseUrl}/circuits'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'date': date.toIso8601String().split('T').first,
          'clientIds': [clientId],
        }),
      );

      if (response.statusCode == 201) {
        return Result.success(CircuitModel.fromJson(json.decode(response.body)));
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to create circuit';
        print('Failed to create circuit - Status Code: ${response.statusCode}');
        print('Error Message: $errorMessage');
        return Result.error(errorMessage);
      }
    } catch (e) {
      print('Exception during circuit creation: $e');
      return Result.error('Une erreur est survenue lors de la création du circuit');
    }
  }

  Future<Result<CircuitModel>> getCircuitByDate({
    required String token,
    required DateTime date,
  }) async {
    if (date == null) {
      print('ERREUR: Date envoyée à getCircuitByDate est nulle !');
      return Result.error('Date non définie');
    }
    final dateString = date.toIso8601String().split('T').first;
    print('Appel API avec date:  [35m$dateString [0m (objet: $date)');
    try {
      final response = await http.get(
        Uri.parse('${AppApi.baseUrl}/circuits/date/$dateString'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Result.success(CircuitModel.fromJson(json.decode(response.body)));
      } else if (response.statusCode == 404) {
        return Result.error('Aucun circuit trouvé pour cette date');
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to get circuit';
        print('Failed to get circuit - Status Code: ${response.statusCode}');
        print('Error Message: $errorMessage');
        return Result.error(errorMessage);
      }
    } catch (e) {
      print('Exception during circuit retrieval: $e');
      return Result.error('Une erreur est survenue lors de la récupération du circuit');
    }
  }

  Future<Result<CircuitModel>> addClientToCircuit({
    required String token,
    required int circuitId,
    required int clientId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${AppApi.baseUrl}/circuits/$circuitId/clients'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'clientId': clientId,
        }),
      );

      if (response.statusCode == 200) {
        return Result.success(CircuitModel.fromJson(json.decode(response.body)));
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to add client to circuit';
        print('Failed to add client to circuit - Status Code: ${response.statusCode}');
        print('Error Message: $errorMessage');
        return Result.error(errorMessage);
      }
    } catch (e) {
      print('Exception during adding client to circuit: $e');
      return Result.error('Une erreur est survenue lors de l\'ajout du client au circuit');
    }
  }

  // Méthode de test pour diagnostiquer les problèmes d'API
  Future<void> testApiEndpoints(String token) async {
    print('\n🔍 TEST DES ENDPOINTS API...');
    
    // Test des visites
    print('\n📍 TEST ENDPOINT VISITES:');
    try {
      final response = await http.get(
        Uri.parse(AppApi.getMyVisitesUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('   URL: ${AppApi.getMyVisitesUrl}');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('   ✅ Données reçues: ${data.length} visites');
        
        if (data.isNotEmpty) {
          print('   📋 Premier élément: ${data.first}');
        }
      }
    } catch (e) {
      print('   ❌ Erreur: $e');
    }
    
    // Test des circuits
    print('\n🛣️ TEST ENDPOINT CIRCUITS:');
    try {
      final response = await http.get(
        Uri.parse(AppApi.getMyCircuitsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('   URL: ${AppApi.getMyCircuitsUrl}');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('   ✅ Données reçues: ${data.length} circuits');
        
        if (data.isNotEmpty) {
          print('   📋 Premier élément: ${data.first}');
        }
      }
    } catch (e) {
      print('   ❌ Erreur: $e');
    }
    
    // Test des endpoints généraux
    print('\n🌐 TEST ENDPOINTS GÉNÉRAUX:');
    
    // Test visites générales
    try {
      final response = await http.get(
        Uri.parse(AppApi.getVisitesUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('   URL Visites générales: ${AppApi.getVisitesUrl}');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
    } catch (e) {
      print('   ❌ Erreur visites générales: $e');
    }
    
    // Test circuits généraux
    try {
      final response = await http.get(
        Uri.parse(AppApi.getCircuitsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('   URL Circuits généraux: ${AppApi.getCircuitsUrl}');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
    } catch (e) {
      print('   ❌ Erreur circuits généraux: $e');
    }
  }
} 