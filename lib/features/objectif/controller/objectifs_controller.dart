// 📁 lib/features/objectifs/controller/objectifs_controller.dart

import 'package:get/get.dart';
import '../models/objectif_model.dart';
import '../services/objectif_service.dart';

class ObjectifsController extends GetxController {
  var objectifs = <ObjectifModel>[].obs;
  var isLoading = false.obs;
  final ObjectifService _objectifService = ObjectifService();

  @override
  void onInit() {
    super.onInit();
    print('🔍 ObjectifsController: onInit appelé');
    fetchObjectifs();
  }

  Future<void> fetchObjectifs() async {
    try {
      isLoading(true);
      print('🔍 ObjectifsController: Début de fetchObjectifs');
      final objectifsList = await _objectifService.fetchObjectifs();
      objectifs.assignAll(objectifsList);
      print('🔍 ObjectifsController: ${objectifs.length} objectifs assignés');
    } catch (e) {
      print("❌ ObjectifsController: Erreur lors du chargement des objectifs: $e");
    } finally {
      isLoading(false);
    }
  }
}
