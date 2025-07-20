import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pfe/core/utils/app_api.dart';

class CommandesModifieesService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppApi.baseUrl));
  final box = GetStorage();

  /// Récupérer toutes les commandes modifiées par l'admin
  Future<List<dynamic>> getCommandesModifiees() async {
    final token = box.read('token');

    try {
      print('📡 CommandesModifieesService: Récupération des commandes modifiées');
      
      final response = await _dio.get(
        '/commandes/modifiees',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('📡 CommandesModifieesService: ${data.length} commandes modifiées récupérées');
        return data;
      } else {
        print("❌ Erreur de chargement des commandes modifiées : ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Erreur de récupération des commandes modifiées : $e");
      return [];
    }
  }

  /// Récupérer les notifications de modifications
  Future<List<dynamic>> getNotificationsModifications() async {
    final token = box.read('token');

    try {
      print('📡 CommandesModifieesService: Récupération des notifications');
      
      final response = await _dio.get(
        '/commandes/notifications',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Filtrer uniquement les notifications de modifications
        final modifications = data.where((n) => 
          n['type'] == 'modification' || 
          n['message']?.toString().toLowerCase().contains('modifié') == true
        ).toList();
        print('📡 CommandesModifieesService: ${modifications.length} notifications de modifications trouvées');
        return modifications;
      } else {
        print("❌ Erreur de chargement des notifications : ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Erreur de récupération des notifications : $e");
      return [];
    }
  }

  /// Marquer une commande comme vue
  Future<bool> marquerCommeVue(int commandeId) async {
    final token = box.read('token');

    try {
      print('📡 CommandesModifieesService: Marquage comme vue pour la commande $commandeId');
      
      final response = await _dio.put(
        '/commandes/notifications/$commandeId/vu',
        data: {},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('✅ Commande marquée comme vue avec succès');
        return true;
      } else {
        print("❌ Erreur lors du marquage : ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Erreur lors du marquage comme vue : $e");
      return false;
    }
  }

  /// Marquer toutes les modifications comme vues
  Future<bool> marquerToutesCommeVues() async {
    final token = box.read('token');

    try {
      print('📡 CommandesModifieesService: Marquage de toutes les modifications comme vues');
      
      final response = await _dio.patch(
        '/commandes/historique/vue',
        data: {},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('✅ Toutes les modifications marquées comme vues');
        return true;
      } else {
        print("❌ Erreur lors du marquage global : ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Erreur lors du marquage global : $e");
      return false;
    }
  }

  /// Récupérer les détails d'une commande modifiée
  Future<Map<String, dynamic>?> getDetailsCommandeModifiee(int commandeId) async {
    final token = box.read('token');

    try {
      print('📡 CommandesModifieesService: Récupération des détails de la commande $commandeId');
      
      final response = await _dio.get(
        '/commandes/modifiees/details/$commandeId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('✅ Détails de la commande modifiée récupérés');
        return response.data;
      } else {
        print("❌ Erreur de récupération des détails : ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Erreur de récupération des détails : $e");
      return null;
    }
  }

  /// Compter les commandes modifiées non vues
  Future<int> getNombreModificationsNonVues() async {
    final token = box.read('token');

    try {
      print('📡 CommandesModifieesService: Récupération du nombre de notifications non vues');
      
      final response = await _dio.get(
        '/commandes/notifications/count',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final count = response.data['count'] ?? 0;
        print('📡 CommandesModifieesService: $count notifications non vues');
        return count;
      } else {
        print("❌ Erreur de récupération du comptage : ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      print("❌ Erreur lors du comptage : $e");
      return 0;
    }
  }
} 