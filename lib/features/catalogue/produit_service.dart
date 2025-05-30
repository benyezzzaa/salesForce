import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class ProduitService {
  final Dio dio = Dio();
  final box = GetStorage();

  Future<List<dynamic>> fetchProduits() async {
    final token = box.read('token');

    if (token == null || token.isEmpty) {
      throw Exception("Token introuvable. Veuillez vous reconnecter.");
    }

    final response = await dio.get(
      'http://localhost:4000/produits',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception("Erreur ${response.statusCode} : impossible de récupérer les produits.");
    }
  }
}
