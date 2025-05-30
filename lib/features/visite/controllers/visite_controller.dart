import 'package:get/get.dart';
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

    try {
      isLoading.value = true;
      error.value = '';
      
      final token = StorageService.getToken();
      if (token == null) {
        error.value = 'Token non trouvé. Veuillez vous reconnecter.';
        return false;
      }
      
      await _service.createVisite(
        token: token,
        date: selectedDate.value,
        clientId: selectedClient!.id,
        raisonId: selectedRaison!.id,
      );

      await createCircuit();
      
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCircuit() async {
    if (selectedClient == null) {
      error.value = 'Client non sélectionné pour la création du circuit.';
      return;
    }

    try {
      final token = StorageService.getToken();
      if (token == null) {
        error.value = 'Token non trouvé. Veuillez vous reconnecter.';
        return;
      }

      final circuit = await _service.createCircuit(
        token: token,
        date: selectedDate.value,
        clientId: selectedClient!.id,
      );

      Get.toNamed(AppRoutes.mapCircuit, arguments: circuit);

    } catch (e) {
      error.value = 'Erreur lors de la création du circuit: ${e.toString()}';
    }
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
} 