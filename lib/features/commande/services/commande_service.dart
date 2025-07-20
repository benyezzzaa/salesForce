import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../models/commande_model.dart';
import '../../../core/utils/app_api.dart';

class CommandeService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppApi.baseUrl));
  final box = GetStorage();

  Future<void> envoyerCommande(Map<String, dynamic> payload) async {
    final token = box.read('token');

    try {
      print('📡 CommandeService: Envoi du payload = $payload');
      
      final response = await _dio.post(
        '/commandes',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('📡 CommandeService: Réponse status = ${response.statusCode}');
      print('📡 CommandeService: Réponse data = ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Commande envoyée avec succès");
      } else {
        print("❌ Erreur lors de l'envoi de la commande : ${response.statusCode}");
        throw Exception("Erreur ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception pendant l'envoi de la commande : $e");
      
      // Capturer les détails de l'erreur Dio
      if (e is DioException) {
        print("📡 DioException Type: ${e.type}");
        print("📡 DioException Message: ${e.message}");
        print("📡 DioException Response Status: ${e.response?.statusCode}");
        print("📡 DioException Response Data: ${e.response?.data}");
        print("📡 DioException Request Data: ${e.requestOptions.data}");
        print("📡 DioException Request Headers: ${e.requestOptions.headers}");
      }
      
      throw Exception("Erreur lors de l'envoi");
    }
  }

 Future<List<CommandeModel>> getAllCommandes() async {
  final token = box.read('token');

  try {
    final response = await _dio.get(
      '/commandes/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => CommandeModel.fromJson(json)).toList();
    } else {
      print("❌ Erreur de chargement : ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("❌ Erreur de récupération des commandes : $e");
    return [];
  }
}
}
