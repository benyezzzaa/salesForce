import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pfe/core/utils/app_api.dart';

class PromotionService {
  final Dio _dio = Dio();
  final GetStorage _box = GetStorage();

  Future<List<dynamic>> fetchPromotions() async {
    final token = _box.read('token');

    if (token == null || token.isEmpty) {
      print("Erreur fetchPromotions: Token introuvable.");
      throw Exception("Token introuvable. Veuillez vous reconnecter.");
    }

    try {
      final response = await _dio.get(
        AppApi.getPromotionsUrl,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      print("Réponse API promotions - Statut: ${response.statusCode}");
      print("Réponse API promotions - Données: ${response.data}");

      if (response.statusCode == 200) {
        // Assurez-vous que la réponse est bien une liste.
        // L'API retourne une liste d'objets promotion.
        if (response.data is List) {
          return response.data;
        } else {
          // Si l'API ne retourne pas une liste, loggez l'erreur ou lancez une exception
          print("Erreur: L'API des promotions n'a pas retourné une liste. Type reçu: ${response.data.runtimeType}");
          // Ou throw Exception("Format de réponse API inattendu.");
          return []; // Retourner une liste vide pour éviter le crash
        }
      } else {
        print("Erreur ${response.statusCode} lors de la récupération des promotions: ${response.statusMessage}");
        throw Exception("Erreur ${response.statusCode} : impossible de récupérer les promotions.");
      }
    } on DioError catch (e) {
      print("Erreur Dio lors de la récupération des promotions: ${e.message}");
      // Il pourrait être utile de logger aussi e.response?.data pour les erreurs 4xx/5xx
      if (e.response != null) {
        print("Réponse d'erreur Dio: ${e.response?.statusCode} - ${e.response?.statusMessage}");
        print("Données d'erreur Dio: ${e.response?.data}");
      }
      throw Exception("Erreur de réseau ou de serveur lors de la récupération des promotions.");
    } catch (e) {
      print("Erreur inconnue lors de la récupération des promotions: $e");
      throw Exception("Une erreur est survenue lors de la récupération des promotions.");
    }
  }
} 