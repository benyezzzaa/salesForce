import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/features/objectif/models/objectif_model.dart';

class ObjectifService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppApi.baseUrl));
  final box = GetStorage();

  Future<List<ObjectifModel>> getObjectifsProgress() async {
    final token = box.read('token');
    print('🔍 HomeObjectifService: Début de getObjectifsProgress');
    print('🔍 HomeObjectifService: Token = ${token != null ? "Présent" : "Absent"}');
    
    try {
      final response = await _dio.get(
        '/objectifs/me/progress',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      print('🔍 HomeObjectifService: Status = ${response.statusCode}');
      print('🔍 HomeObjectifService: Data = ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final objectifs = data.map((json) => ObjectifModel.fromJson(json)).toList();
        print('🔍 HomeObjectifService: ${objectifs.length} objectifs trouvés');
        return objectifs;
      } else {
        print("❌ HomeObjectifService: Erreur ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ HomeObjectifService: Exception = $e");
      return [];
    }
  }
}
