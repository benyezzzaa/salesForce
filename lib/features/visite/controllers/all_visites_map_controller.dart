import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pfe/core/utils/storage_services.dart';
import '../models/visite_model.dart';
import '../models/circuit_model.dart';
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
      
      // Charger toutes les visites et circuits en parallèle
      final futures = await Future.wait([
        _service.getAllVisites(token),
        _service.getAllCircuits(token),
      ]);
      
      allVisites.value = futures[0] as List<VisiteModel>;
      allCircuits.value = futures[1] as List<CircuitModel>;
      
      print('Loaded [32m${allVisites.length}[0m visites and [34m${allCircuits.length}[0m circuits');
      print('Date sélectionnée (selectedDate): [33m${selectedDate.value}[0m');
      for (var v in allVisites) {
        print('Visite: id=${v.id}, date=${v.date}, client=${v.client.fullName}, lat=${v.client.latitude}, lng=${v.client.longitude}');
      }
      for (var c in allCircuits) {
        print('Circuit: id=${c.id}, date=${c.date}, clients=${c.clients.length}');
        for (var cl in c.clients) {
          print('  Client: id=${cl.id}, nom=${cl.fullName}, lat=${cl.latitude}, lng=${cl.longitude}');
        }
      }
      
    } catch (e) {
      error.value = 'Erreur lors du chargement des données: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  List<VisiteModel> getVisitesByDate(DateTime date) {
    print('Filtrage des visites pour la date: [36m$date[0m');
    return allVisites.where((visite) {
      print('Comparaison: visite.date=${visite.date} vs date sélectionnée=$date');
      return visite.date.year == date.year &&
             visite.date.month == date.month &&
             visite.date.day == date.day;
    }).toList();
  }

  List<CircuitModel> getCircuitsByDate(DateTime date) {
    print('Filtrage des circuits pour la date: [36m$date[0m');
    return allCircuits.where((circuit) {
      print('Comparaison: circuit.date=${circuit.date} vs date sélectionnée=$date');
      return circuit.date.year == date.year &&
             circuit.date.month == date.month &&
             circuit.date.day == date.day;
    }).toList();
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  void refreshData() {
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
} 