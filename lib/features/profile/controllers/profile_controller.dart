import 'package:get/get.dart';
import 'package:pfe/core/utils/storage_services.dart';

class ProfileController extends GetxController {
  var nom = ''.obs;
  var prenom = ''.obs;
  var email = ''.obs;
  var tel = ''.obs;
  var role = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    final user = StorageService.getUser();
    if (user != null) {
      nom.value = user['nom'] ?? '';
      prenom.value = user['prenom'] ?? '';
      email.value = user['email'] ?? '';
      tel.value = user['tel'] ?? '';
      role.value = user['role'] ?? '';
    }
  }
}
