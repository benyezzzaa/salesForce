// 📁 lib/features/objectifs/controller/objectifs_controller.dart

import 'package:get/get.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/core/utils/app_services.dart';

class ObjectifsController extends GetxController {
  var objectifs = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchObjectifs();
  }

  Future<void> fetchObjectifs() async {
    try {
      isLoading(true);
      final response = await ApiService().get(AppApi.mesObjectifs);
      objectifs.assignAll(List<Map<String, dynamic>>.from(response.data));
    } catch (e) {
      print("Erreur lors du chargement des objectifs: $e");
    } finally {
      isLoading(false);
    }
  }
}
