import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/commande_model.dart';
import '../../../core/utils/app_api.dart';

class CommandeService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppApi.baseUrl));
  final box = GetStorage();

  Future<void> envoyerCommande({
    required String numeroCommande,
    required int clientId,
    required List<Map<String, dynamic>> lignesCommande,
  }) async {
    final token = box.read('token');

    try {
      final response = await _dio.post(
        '/commandes',
        data: {
          'numeroCommande': numeroCommande,
          'clientId': clientId,
          'lignesCommande': lignesCommande,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Commande envoyée avec succès");
      } else {
        print("❌ Erreur lors de l'envoi de la commande : ${response.statusCode}");
        throw Exception("Erreur ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception pendant l'envoi de la commande : $e");
      throw Exception("Erreur lors de l'envoi");
    }
  }

  Future<List<CommandeModel>> getAllCommandes() async {
    final token = box.read('token');

    try {
      final response = await _dio.get(
        '/commandes',
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
