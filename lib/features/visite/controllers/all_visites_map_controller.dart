import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pfe/core/utils/storage_services.dart';
import '../models/visite_model.dart';
import '../models/circuit_model.dart';
import 'package:pfe/features/clients/models/client_model.dart';
import '../services/visite_service.dart';

class AllVisitesMapController extends GetxController {
  final VisiteService _service = VisiteService();
  
  final allVisites = <VisiteModel>[].obs;
  final allCircuits = <CircuitModel>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;
  final selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> loadAllData() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final token = StorageService.getToken();
      if (token == null) {
        error.value = 'Token non trouvé. Veuillez vous reconnecter.';
        return;
      }
      
      print('🔄 Chargement des données...');
      print('📅 Date sélectionnée: ${formatDate(selectedDate.value)}');
      
      // Charger toutes les visites et circuits en parallèle
      final futures = await Future.wait([
        _service.getAllVisites(token),
        _service.getAllCircuits(token),
      ]);
      
      allVisites.value = futures[0] as List<VisiteModel>;
      allCircuits.value = futures[1] as List<CircuitModel>;
      
      print('✅ Données chargées:');
      print('   📍 Visites: ${allVisites.length}');
      print('   🛣️ Circuits: ${allCircuits.length}');
      
      // Analyser les données
      _analyzeData();
      
    } catch (e) {
      print('❌ Erreur lors du chargement: $e');
      error.value = 'Erreur lors du chargement des données: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void _analyzeData() {
    print('\n📊 ANALYSE DES DONNÉES:');
    
    // Analyser les visites
    print('📍 VISITES:');
    if (allVisites.isEmpty) {
      print('   ❌ Aucune visite trouvée');
    } else {
      for (int i = 0; i < allVisites.length; i++) {
        final visite = allVisites[i];
        final hasCoords = visite.client.latitude != null && visite.client.longitude != null;
        print('   ${i + 1}. ${visite.client.fullName} - Date: ${formatDate(visite.date)} - Coordonnées: ${hasCoords ? "✅" : "❌"}');
      }
    }
    
    // Analyser les circuits
    print('🛣️ CIRCUITS:');
    if (allCircuits.isEmpty) {
      print('   ❌ Aucun circuit trouvé');
    } else {
      for (int i = 0; i < allCircuits.length; i++) {
        final circuit = allCircuits[i];
        print('   ${i + 1}. Circuit ${circuit.id} - Date: ${formatDate(circuit.date)} - Clients: ${circuit.clients.length}');
        for (int j = 0; j < circuit.clients.length; j++) {
          final client = circuit.clients[j];
          final hasCoords = client.latitude != null && client.longitude != null;
          print('      ${j + 1}. ${client.fullName} - Coordonnées: ${hasCoords ? "✅" : "❌"}');
        }
      }
    }
    
    // Analyser pour la date sélectionnée
    print('\n📅 POUR LA DATE SÉLECTIONNÉE (${formatDate(selectedDate.value)}):');
    final visitesForDate = getVisitesByDate(selectedDate.value);
    final circuitsForDate = getCircuitsByDate(selectedDate.value);
    
    print('   📍 Visites: ${visitesForDate.length}');
    print('   🛣️ Circuits: ${circuitsForDate.length}');
    
    int totalClientsWithCoords = 0;
    for (final visite in visitesForDate) {
      if (visite.client.latitude != null && visite.client.longitude != null) {
        totalClientsWithCoords++;
      }
    }
    for (final circuit in circuitsForDate) {
      for (final client in circuit.clients) {
        if (client.latitude != null && client.longitude != null) {
          totalClientsWithCoords++;
        }
      }
    }
    print('   🎯 Clients avec coordonnées: $totalClientsWithCoords');
  }

  // Fonction utilitaire pour comparer deux dates sans l'heure
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<VisiteModel> getVisitesByDate(DateTime date) {
    print('🔍 Filtrage visites pour ${formatDate(date)}...');
    print('   Total visites disponibles: ${allVisites.length}');
    
    final visites = allVisites.where((visite) {
      final isSameDate = isSameDay(visite.date, date);
      // Vérifier si la visite est future ou aujourd'hui
      final isFutureOrToday = !visite.date.isBefore(DateTime.now().subtract(Duration(days: 1)));
      if (isSameDate && isFutureOrToday) {
        print('   ✅ Visite trouvée (future): ${visite.client.fullName} - Date: ${formatDate(visite.date)}');
      } else if (isSameDate && !isFutureOrToday) {
        print('   ⏰ Visite trouvée (passée): ${visite.client.fullName} - Date: ${formatDate(visite.date)} - IGNORÉE');
      }
      return isSameDate && isFutureOrToday;
    }).toList();
    print('🔍 Filtrage visites pour ${formatDate(date)}: ${visites.length} trouvées (futures uniquement)');
    return visites;
  }

  List<CircuitModel> getCircuitsByDate(DateTime date) {
    print('🔍 Filtrage circuits pour ${formatDate(date)}...');
    print('   Total circuits disponibles: ${allCircuits.length}');
    
    final circuits = allCircuits.where((circuit) {
      final isSameDate = isSameDay(circuit.date, date);
      // Vérifier si le circuit est future ou aujourd'hui
      final isFutureOrToday = !circuit.date.isBefore(DateTime.now().subtract(Duration(days: 1)));
      if (isSameDate && isFutureOrToday) {
        print('   ✅ Circuit trouvé (future): Circuit ${circuit.id} - Date: ${formatDate(circuit.date)} - Clients: ${circuit.clients.length}');
      } else if (isSameDate && !isFutureOrToday) {
        print('   ⏰ Circuit trouvé (passé): Circuit ${circuit.id} - Date: ${formatDate(circuit.date)} - IGNORÉ');
      }
      return isSameDate && isFutureOrToday;
    }).toList();
    print('🔍 Filtrage circuits pour ${formatDate(date)}: ${circuits.length} trouvés (futurs uniquement)');
    return circuits;
  }

  void setSelectedDate(DateTime date) {
    print('📅 Changement de date: ${formatDate(selectedDate.value)} → ${formatDate(date)}');
    selectedDate.value = date;
    _analyzeData();
  }

  void refreshData() {
    print('🔄 Actualisation des données...');
    loadAllData();
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  int getTotalVisitesForDate(DateTime date) {
    return getVisitesByDate(date).length;
  }

  int getTotalClientsForDate(DateTime date) {
    final circuits = getCircuitsByDate(date);
    int totalClients = 0;
    for (final circuit in circuits) {
      totalClients += circuit.clients.length;
    }
    return totalClients;
  }

  // Nouvelle méthode pour obtenir tous les clients avec coordonnées pour une date
  List<ClientModel> getClientsWithCoordinatesForDate(DateTime date) {
    List<ClientModel> clients = [];
    
    // Ajouter les clients des visites (futures uniquement)
    final visites = getVisitesByDate(date);
    for (final visite in visites) {
      if (visite.client.latitude != null && visite.client.longitude != null) {
        clients.add(visite.client);
      }
    }
    
    // Ajouter les clients des circuits (futurs uniquement)
    final circuits = getCircuitsByDate(date);
    for (final circuit in circuits) {
      for (final client in circuit.clients) {
        if (client.latitude != null && client.longitude != null) {
          clients.add(client);
        }
      }
    }
    
    print('🎯 Clients avec coordonnées pour ${formatDate(date)} (futurs uniquement): ${clients.length}');
    return clients;
  }

  // Méthode de test pour vérifier les données
  void testData() {
    print('\n🧪 TEST DES DONNÉES:');
    print('📅 Date sélectionnée: ${formatDate(selectedDate.value)}');
    print('📍 Total visites: ${allVisites.length}');
    print('🛣️ Total circuits: ${allCircuits.length}');
    
    if (allVisites.isEmpty && allCircuits.isEmpty) {
      print('⚠️ Aucune donnée disponible - problème de chargement');
      return;
    }
    
    // Analyser les visites futures vs passées
    print('\n📊 ANALYSE VISITES FUTURES VS PASSÉES:');
    final now = DateTime.now();
    final futureVisites = allVisites.where((visite) => visite.date.isAfter(now.subtract(Duration(days: 1)))).toList();
    final pastVisites = allVisites.where((visite) => visite.date.isBefore(now)).toList();
    
    print('   📍 Visites futures: ${futureVisites.length}');
    print('   ⏰ Visites passées: ${pastVisites.length}');
    
    // Analyser les circuits futurs vs passés
    final futureCircuits = allCircuits.where((circuit) => circuit.date.isAfter(now.subtract(Duration(days: 1)))).toList();
    final pastCircuits = allCircuits.where((circuit) => circuit.date.isBefore(now)).toList();
    
    print('   🛣️ Circuits futurs: ${futureCircuits.length}');
    print('   ⏰ Circuits passés: ${pastCircuits.length}');
    
    // Tester avec une date différente
    final testDate = DateTime.now().subtract(const Duration(days: 1));
    print('\n🔍 Test avec la date d\'hier: ${formatDate(testDate)}');
    
    final visitesYesterday = getVisitesByDate(testDate);
    final circuitsYesterday = getCircuitsByDate(testDate);
    
    print('   📍 Visites hier (futures): ${visitesYesterday.length}');
    print('   🛣️ Circuits hier (futurs): ${circuitsYesterday.length}');
    
    // Tester avec une date future
    final futureDate = DateTime.now().add(const Duration(days: 1));
    print('\n🔍 Test avec la date de demain: ${formatDate(futureDate)}');
    
    final visitesTomorrow = getVisitesByDate(futureDate);
    final circuitsTomorrow = getCircuitsByDate(futureDate);
    
    print('   📍 Visites demain (futures): ${visitesTomorrow.length}');
    print('   🛣️ Circuits demain (futurs): ${circuitsTomorrow.length}');
    
    // Analyser toutes les dates disponibles
    print('\n📊 ANALYSE DES DATES DISPONIBLES:');
    
    Set<String> datesVisites = {};
    for (final visite in allVisites) {
      datesVisites.add(formatDate(visite.date));
    }
    print('   📍 Dates des visites: ${datesVisites.toList()}');
    
    Set<String> datesCircuits = {};
    for (final circuit in allCircuits) {
      datesCircuits.add(formatDate(circuit.date));
    }
    print('   🛣️ Dates des circuits: ${datesCircuits.toList()}');
  }

  // Méthode pour obtenir les visites futures uniquement
  List<VisiteModel> getFutureVisites() {
    final now = DateTime.now();
    return allVisites.where((visite) => visite.date.isAfter(now.subtract(Duration(days: 1)))).toList();
  }

  // Méthode pour obtenir les circuits futurs uniquement
  List<CircuitModel> getFutureCircuits() {
    final now = DateTime.now();
    return allCircuits.where((circuit) => circuit.date.isAfter(now.subtract(Duration(days: 1)))).toList();
  }

  // Méthode pour créer des données de test
  void createTestData() {
    print('\n🧪 CRÉATION DE DONNÉES DE TEST...');
    
    // Créer des clients de test avec coordonnées
    final testClients = [
      ClientModel(
        id: 1,
        latitude: 48.8566,
        longitude: 2.3522,
        nom: 'Dupont',
        prenom: 'Jean',
        email: 'jean.dupont@test.com',
        telephone: '0123456789',
        adresse: '1 Rue de la Paix, Paris',
        isActive: true,
      ),
      ClientModel(
        id: 2,
        latitude: 48.8584,
        longitude: 2.2945,
        nom: 'Martin',
        prenom: 'Marie',
        email: 'marie.martin@test.com',
        telephone: '0987654321',
        adresse: 'Tour Eiffel, Paris',
        isActive: true,
      ),
      ClientModel(
        id: 3,
        latitude: 48.8606,
        longitude: 2.3376,
        nom: 'Bernard',
        prenom: 'Pierre',
        email: 'pierre.bernard@test.com',
        telephone: '0555666777',
        adresse: 'Arc de Triomphe, Paris',
        isActive: true,
      ),
    ];

    // Créer des visites de test pour aujourd'hui
    final testVisites = [
      VisiteModel(
        id: 1,
        date: DateTime.now(),
        client: testClients[0],
        user: {'id': 1, 'nom': 'Test Commercial'},
      ),
      VisiteModel(
        id: 2,
        date: DateTime.now(),
        client: testClients[1],
        user: {'id': 1, 'nom': 'Test Commercial'},
      ),
    ];

    // Créer un circuit de test pour aujourd'hui
    final testCircuit = CircuitModel(
      id: 1,
      date: DateTime.now(),
      commercial: {'id': 1, 'nom': 'Test Commercial'},
      clients: [testClients[2]],
    );

    // Remplacer les données actuelles par les données de test
    allVisites.value = testVisites;
    allCircuits.value = [testCircuit];
    
    print('✅ Données de test créées:');
    print('   📍 Visites: ${allVisites.length}');
    print('   🛣️ Circuits: ${allCircuits.length}');
    print('   🎯 Clients avec coordonnées: ${testClients.length}');
    
    // Analyser les données
    _analyzeData();
  }

  // Méthode pour forcer le rechargement des données
  void forceReloadData() async {
    print('\n🔄 FORÇAGE DU RECHARGEMENT DES DONNÉES...');
    isLoading.value = true;
    error.value = '';
    
    try {
      final token = StorageService.getToken();
      if (token == null) {
        error.value = 'Token non trouvé. Veuillez vous reconnecter.';
        return;
      }
      
      print('📡 Appel API direct...');
      
      // Appel direct aux services
      final visites = await _service.getAllVisites(token);
      final circuits = await _service.getAllCircuits(token);
      
      allVisites.value = visites;
      allCircuits.value = circuits;
      
      print('✅ Rechargement terminé:');
      print('   📍 Visites: ${allVisites.length}');
      print('   🛣️ Circuits: ${allCircuits.length}');
      
      // Analyser les données
      _analyzeData();
      
    } catch (e) {
      print('❌ Erreur lors du rechargement: $e');
      error.value = 'Erreur lors du rechargement: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode pour tester les endpoints API
  void testApiEndpoints() async {
    print('\n🔍 TEST DES ENDPOINTS API...');
    
    final token = StorageService.getToken();
    if (token == null) {
      print('❌ Token non trouvé');
      return;
    }
    
    await _service.testApiEndpoints(token);
  }
} 