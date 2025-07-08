import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/core/utils/app_services.dart';

class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;
  final ApiService _apiService = ApiService();

  Future<void> resetPassword(String email) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer une adresse email valide',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    
    try {
      final response = await _apiService.post(
        AppApi.resetPasswordUrl,
        {'email': email},
        useToken: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Succès',
          'Un email de réinitialisation a été envoyé à votre adresse email',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back(); // Retour à la page de login
      } else {
        final errorMessage = response.data['message'] ?? 'Erreur lors de l\'envoi de l\'email';
        Get.snackbar(
          'Erreur',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Exception during password reset: $e');
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue. Veuillez réessayer.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 