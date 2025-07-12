import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/core/utils/app_services.dart';

class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;
  var emailSent = false.obs;
  final ApiService _apiService = ApiService();

  // Validation d'email améliorée
  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    // Nettoyer l'email
    final cleanEmail = email.trim().toLowerCase();
    
    // Regex plus robuste pour la validation d'email
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final isValid = emailRegex.hasMatch(cleanEmail);
    
    print('🔍 Validation email: "$email" -> ${isValid ? "✅ Valide" : "❌ Invalide"}');
    return isValid;
  }

  Future<void> resetPassword(String email) async {
    // Validation améliorée
    if (email.isEmpty) {
      _showErrorSnackbar('Veuillez entrer votre adresse email');
      return;
    }

    final cleanEmail = email.trim().toLowerCase();
    
    if (!_isValidEmail(cleanEmail)) {
      _showErrorSnackbar('Veuillez entrer une adresse email valide (ex: user@example.com)');
      return;
    }
    
    // Validation supplémentaire
    if (cleanEmail.length < 5) {
      _showErrorSnackbar('L\'email semble trop court');
      return;
    }
    
    if (!cleanEmail.contains('@')) {
      _showErrorSnackbar('L\'email doit contenir le symbole @');
      return;
    }
    
    if (!cleanEmail.contains('.')) {
      _showErrorSnackbar('L\'email doit contenir un point (.)');
      return;
    }

    isLoading.value = true;
    
    try {
      print('🔄 Envoi de la demande de réinitialisation pour: $email');
      print('📡 URL: ${AppApi.forgotPasswordUrl}');
      print('📡 Données envoyées: {"email": "${email.trim()}"}');
      
      // Structure de données pour le backend NestJS
      final requestData = {
        'email': cleanEmail,
      };
      
      print('📤 Données envoyées au backend: $requestData');
      print('📤 Email nettoyé: "$cleanEmail"');
      print('📤 Longueur email: ${cleanEmail.length}');
      print('📤 Contient @: ${cleanEmail.contains('@')}');
      print('📤 Contient .: ${cleanEmail.contains('.')}');
      
      final response = await _apiService.post(
        AppApi.forgotPasswordUrl,
        requestData,
        useToken: false,
      );

      print('📡 Réponse API reset password:');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Succès
        emailSent.value = true;
        
        // Analyser la réponse du backend
        final responseData = response.data;
        String successMessage = 'Email envoyé avec succès !';
        String resetLink = '';
        String token = '';
        
        if (responseData != null && responseData is Map<String, dynamic>) {
          if (responseData['message'] != null) {
            successMessage = responseData['message'].toString();
          }
          
          if (responseData['resetLink'] != null) {
            resetLink = responseData['resetLink'].toString();
            print('🔗 Lien de réinitialisation: $resetLink');
          }
          if (responseData['token'] != null) {
            token = responseData['token'].toString();
            print('🔑 Token généré: $token');
          }
        }
        
        // Afficher le lien dans une popup si disponible
        if (resetLink.isNotEmpty) {
          _showResetLinkDialog(resetLink, token);
        }
        
        _showSuccessSnackbar(successMessage);
        
        // Attendre un peu avant de retourner à la page de login
        await Future.delayed(const Duration(seconds: 2));
        Get.back();
      } else {
        // Gestion des erreurs spécifiques du backend NestJS
        final errorData = response.data;
        String errorMessage = 'Erreur lors de l\'envoi de l\'email';
        
        if (errorData != null && errorData is Map<String, dynamic>) {
          // Gestion des erreurs NestJS
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'].toString();
          }
          
          // Gestion spécifique des erreurs HTTP
          if (response.statusCode == 404) {
            errorMessage = 'Utilisateur introuvable avec cet email';
          } else if (response.statusCode == 400) {
            errorMessage = 'Données invalides';
          } else if (response.statusCode == 500) {
            errorMessage = 'Erreur serveur interne. Vérifiez que votre backend fonctionne correctement.';
            print('❌ Erreur 500 - Détails de la réponse:');
            print('   Status: ${response.statusCode}');
            print('   Headers: ${response.headers}');
            print('   Data: ${response.data}');
          }
        }
        
        _showErrorSnackbar(errorMessage);
      }
    } catch (e) {
      print('❌ Exception lors de la réinitialisation: $e');
      
      // Gestion détaillée des erreurs Dio
      if (e.toString().contains('DioException')) {
        if (e.toString().contains('status code of 400')) {
          _showErrorSnackbar('Données invalides. Vérifiez que l\'email est correct.');
        } else if (e.toString().contains('status code of 404')) {
          _showErrorSnackbar('Utilisateur introuvable avec cet email.');
        } else if (e.toString().contains('status code of 500')) {
          _showErrorSnackbar('Erreur serveur. Contactez l\'administrateur.');
        } else if (e.toString().contains('status code of 401')) {
          _showErrorSnackbar('Non autorisé. Vérifiez vos identifiants.');
        } else if (e.toString().contains('status code of 403')) {
          _showErrorSnackbar('Accès interdit.');
        } else {
          _showErrorSnackbar('Erreur de communication avec le serveur.');
        }
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Connection refused') ||
                 e.toString().contains('timeout')) {
        _showErrorSnackbar('Erreur de connexion. Vérifiez votre connexion internet.');
      } else {
        _showErrorSnackbar('Une erreur inattendue est survenue. Veuillez réessayer.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessSnackbar(String message) {
    try {
      Get.snackbar(
        '✅ Succès',
        message,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      print('❌ Erreur lors de l\'affichage du snackbar de succès: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    try {
      print('🚨 Affichage erreur: $message');
      Get.snackbar(
        '❌ Erreur',
        message,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error, color: Colors.white),
        shouldIconPulse: true,
      );
    } catch (e) {
      print('❌ Erreur lors de l\'affichage du snackbar d\'erreur: $e');
    }
  }

  // Méthode pour réinitialiser l'état
  void resetState() {
    emailSent.value = false;
    isLoading.value = false;
  }

  // Méthode pour afficher le lien de réinitialisation
  void _showResetLinkDialog(String resetLink, String token) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.link, color: const Color(0xFF3F51B5), size: 28),
            const SizedBox(width: 12),
            const Text('Lien de réinitialisation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre lien de réinitialisation a été généré :',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3F51B5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3F51B5).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lien :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    resetLink,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF3F51B5)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Token (pour tests) :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    token,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Note : Ce lien est temporaire et expire dans 1 heure.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
} 