import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/utils/app_api.dart';
import '../models/objectif_model.dart';

class ObjectifService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppApi.baseUrl));
  final box = GetStorage();

  Future<List<ObjectifModel>> fetchObjectifs() async {
    final token = box.read('token');
    print('🔍 ObjectifService: Début de fetchObjectifs');
    print('🔍 ObjectifService: Token = ${token != null ? "Présent" : "Absent"}');
    print('🔍 ObjectifService: URL = /objectifs/me/progress');

    try {
      final response = await _dio.get(
        '/objectifs/me/progress',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('🔍 ObjectifService: Status = ${response.statusCode}');
      print('🔍 ObjectifService: Data = ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final objectifs = data.map((json) => ObjectifModel.fromJson(json)).toList();
        print('🔍 ObjectifService: ${objectifs.length} objectifs trouvés');
        return objectifs;
      } else {
        print("❌ ObjectifService: Erreur ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ ObjectifService: Exception = $e");
      return [];
    }
  }
} 