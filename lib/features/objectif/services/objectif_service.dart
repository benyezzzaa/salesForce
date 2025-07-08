import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/utils/app_api.dart';
import '../models/objectif_model.dart';

class ObjectifService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppApi.baseUrl));
  final box = GetStorage();

  Future<List<ObjectifModel>> fetchObjectifs() async {
    final token = box.read('token');
    print('TOKEN UTILISÉ POUR FETCH OBJECTIFS: $token');

    try {
      final response = await _dio.get(
        '/objectifs/me/progress',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('RÉPONSE OBJECTIFS: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ObjectifModel.fromJson(json)).toList();
      } else {
        print("❌ Erreur de chargement des objectifs : ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Exception lors de la récupération des objectifs : $e");
      return [];
    }
  }
} 