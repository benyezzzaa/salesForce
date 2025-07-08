import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'package:pfe/core/utils/app_api.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppApi.baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final GetStorage _storage = GetStorage();

  /// GET
  Future<Response> get(String endpoint) async {
    _dio.options.headers['Authorization'] = 'Bearer ${_storage.read('token')}';
    return await _dio.get(endpoint);
  }

  /// POST
  Future<Response> post(String endpoint, Map<String, dynamic> data, {bool useToken = true}) async {
    if (useToken) {
      _dio.options.headers['Authorization'] = 'Bearer ${_storage.read('token')}';
    }
    return await _dio.post(endpoint, data: data);
  }

  /// PATCH
  Future<Response> patch(String endpoint, Map<String, dynamic> data) async {
    final token = _storage.read('token');
    return await _dio.patch(
      endpoint,
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// DOWNLOAD PDF
  Future<void> downloadPdf(int commandeId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = "${dir.path}/commande_$commandeId.pdf";
      final token = _storage.read('token');

      final response = await _dio.get(
        "${AppApi.getCommandeUrl}/pdf/$commandeId",
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final file = File(savePath);
      await file.writeAsBytes(response.data);
      await OpenFile.open(savePath);
    } catch (e) {
      print("Erreur téléchargement PDF : $e");
      rethrow;
    }
  }

  Dio get dio => _dio;
}
