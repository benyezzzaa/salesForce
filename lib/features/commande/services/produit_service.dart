import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/utils/app_api.dart';

class ProduitService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppApi.baseUrl,
      contentType: 'application/json',
    ),
  );
  final GetStorage _storage = GetStorage();

  Future<List<dynamic>> getAllProduits() async {
    _dio.options.headers['Authorization'] = 'Bearer ${_storage.read('token')}';
    final response = await _dio.get('/produits');
    return response.data;
  }
}