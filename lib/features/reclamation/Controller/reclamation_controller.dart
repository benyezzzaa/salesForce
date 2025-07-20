import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pfe/core/utils/app_api.dart';

class ReclamationController extends GetxController {
  final Dio dio = Dio(BaseOptions(baseUrl: AppApi.baseUrl));
  final token = GetStorage().read('token');

  final RxList clients = [].obs;
  final RxBool isLoading = true.obs;
  final selectedClientId = Rxn<int>();

  final sujetController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Map<String, String> get headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  @override
  void onInit() {
    fetchClients();
     fetchMyReclamations();
    super.onInit();
  }
final RxList mesReclamations = [].obs;

Future<void> fetchMyReclamations() async {
  isLoading.value = true;
  try {
    final res = await dio.get('/reclamations/me', options: Options(headers: headers));
    mesReclamations.value = res.data;
    print(res.data);
  } catch (e) {
    Get.snackbar('Erreur', 'Impossible de récupérer les réclamations');
  } finally {
    isLoading.value = false;
  }
}
  Future<void> fetchClients() async {
    try {
      final res = await dio.get('/client/mes-clients', options: Options(headers: headers));
      clients.value = res.data;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les clients');
    } finally {
      isLoading.value = false;
    }
  }

 Future<void> submitReclamation() async {
  if (!formKey.currentState!.validate()) return;

  try {
    final res = await dio.post(
      '/reclamations',
      data: jsonEncode({
        'clientId': selectedClientId.value,
        'sujet': sujetController.text,
        'description': descriptionController.text,
      }),
      options: Options(headers: headers),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      // ✅ Rafraîchir les réclamations après ajout
      await fetchMyReclamations();

      // ✅ Fermer le formulaire et passer un message de succès
      Get.back(result: 'added'); // on envoie 'added' comme résultat
    } else {
      Get.snackbar('Erreur', 'Échec de l’envoi');
    }
  } catch (e) {
    Get.snackbar('Erreur', 'Exception : $e');
  }
}
}
