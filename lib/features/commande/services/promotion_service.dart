import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pfe/core/utils/app_api.dart';
import '../models/promotion_model.dart';

class PromotionService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppApi.baseUrl));
  final box = GetStorage();

  Future<List<Promotion>> fetchPromotions() async {
    final token = box.read('token');
    print('🔍 PromotionService: Début de fetchPromotions');
    print('🔍 PromotionService: Token = ${token != null ? "Présent" : "Absent"}');
    print('🔍 PromotionService: URL = /promotions');
    
    try {
      final response = await _dio.get(
        '/promotions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      print('🔍 PromotionService: Status = ${response.statusCode}');
      print('🔍 PromotionService: Data = ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          final promotions = data.map((json) => Promotion.fromJson(json)).toList();
          print('🔍 PromotionService: ${promotions.length} promotions trouvées');
          return promotions;
        } else {
          print('❌ PromotionService: Format inattendu - ${data.runtimeType}');
          return [];
        }
      } else {
        print('❌ PromotionService: Erreur ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ PromotionService: Exception = $e');
      return [];
    }
  }
} 