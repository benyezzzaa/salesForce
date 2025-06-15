import 'package:dio/dio.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/features/home/models/objectif_model.dart';

class ObjectifService {
  final Dio dio = Dio(BaseOptions(baseUrl: AppApi.baseUrl));

  Future<List<ObjectifModel>> getObjectifsProgress() async {
    final response = await dio.get(AppApi.mesObjectifs);
    return (response.data as List)
        .map((e) => ObjectifModel.fromJson(e))
        .toList();
  }
}
