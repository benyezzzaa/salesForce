// 📁 lib/services/objectif_service.dart
import 'package:dio/dio.dart';
import 'package:pfe/core/utils/app_services.dart';
import '../models/objectif_model.dart';


class ObjectifService {
  final Dio _dio = ApiService().dio;

  Future<Map<int, List<ObjectifModel>>> getGroupedByYear() async {
    final response = await _dio.get('/objectifs/me/by-year');
    final data = response.data as List;

    Map<int, List<ObjectifModel>> grouped = {};
    for (var item in data) {
      final model = ObjectifModel.fromJson(item);
      grouped.putIfAbsent(model.annee, () => []).add(model);
    }
    return grouped;
  }

  Future<List<Map<String, dynamic>>> getSalesByCategory() async {
    final response = await _dio.get('/objectifs/me/sales-by-category');
    return List<Map<String, dynamic>>.from(response.data);
  }
}
