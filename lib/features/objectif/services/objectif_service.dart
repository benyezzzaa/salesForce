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

    try {
      // Test des deux endpoints pour debug
      print('🧪 Test endpoint /objectifs/me/progress...');
      final response1 = await _dio.get(
        '/objectifs/me/progress',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('🧪 /objectifs/me/progress: ${response1.data.length} objectifs');
      
      print('🧪 Test endpoint /objectifs/debug/my-objectifs...');
      final response2 = await _dio.get(
        '/objectifs/debug/my-objectifs',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('🧪 /objectifs/debug/my-objectifs: ${response2.data.length} objectifs');

      // Utiliser l'endpoint normal
      final response = await _dio.get(
        '/objectifs/me/progress',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('🔍 ObjectifService: Status = ${response.statusCode}');
      print('🔍 ObjectifService: Data complet =  [33m${response.data} [0m');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('🔍 ObjectifService: Nombre d\'éléments dans la réponse: ${data.length}');
        
        if (data.isNotEmpty) {
          print('🔍 ObjectifService: Premier élément: ${data.first}');
        }
        
        final objectifs = data.map((json) {
          try {
            return ObjectifModel.fromJson(json);
          } catch (e) {
            print('❌ ObjectifService: Erreur parsing objectif $json: $e');
            rethrow;
          }
        }).toList();
        
        print('🔍 ObjectifService: ${objectifs.length} objectifs parsés avec succès');
        
        // Log de chaque objectif pour debug
        for (int i = 0; i < objectifs.length; i++) {
          final obj = objectifs[i];
          print('📋 ObjectifService Objectif $i: ${obj.mission} - Cible: ${obj.montantCible}€ - Réalisé: ${obj.ventes}€ - Atteint: ${obj.atteint}');
          print('DEBUG Objectif: mission=${obj.mission}, dateDebut=${obj.dateDebut}, dateFin=${obj.dateFin}');
        }
        
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

  // Méthode de test pour comparer les endpoints
  Future<void> testEndpoints() async {
    final token = box.read('token');
    print('🧪 Test des endpoints...');
    
    try {
      // Test endpoint /objectifs/me/progress
      final response1 = await _dio.get(
        '/objectifs/me/progress',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('🧪 /objectifs/me/progress: ${response1.data.length} objectifs');
      
      // Test endpoint /objectifs
      final response2 = await _dio.get(
        '/objectifs',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('🧪 /objectifs: ${response2.data.length} objectifs');
      
    } catch (e) {
      print('❌ Erreur test endpoints: $e');
    }
  }
} 