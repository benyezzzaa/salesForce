import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pfe/core/utils/app_api.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl:AppApi.baseUrl,
      contentType: 'application/json',
    ),
  );

  final GetStorage _storage = GetStorage();

  Future<Response> get(String endpoint) async {
    _dio.options.headers['Authorization'] = 'Bearer ${_storage.read('token')}';
    return await _dio.get(endpoint);
  }
Future<Response> patch(String endpoint, Map<String, dynamic> data) async {
  final token = _storage.read('token');
  return await _dio.patch(
    endpoint,
    data: data,
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );
}
  Future<Response> post(String endpoint, Map<String, dynamic> data, {bool useToken = true}) async {
    if (useToken) {
      _dio.options.headers['Authorization'] = 'Bearer ${_storage.read('token')}';
    }
    return await _dio.post(endpoint, data: data);
  }
  Dio get dio => _dio;
}
