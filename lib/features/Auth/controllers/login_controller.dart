import 'package:get/get.dart';
import 'package:pfe/core/routes/app_routes.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/core/utils/app_services.dart';
import 'package:pfe/core/utils/storage_services.dart';


class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;

  final ApiService _apiService = ApiService();

  void updateEmail(String value) => email.value = value;
  void updatePassword(String value) => password.value = value;

  Future<void> login() async {
    isLoading.value = true;
    try {
      final response = await _apiService.post(AppApi.loginUrl, {
        'email': email.value,
        'password': password.value,
      }, useToken: false);

      if (response.statusCode == 201) {
        StorageService.saveToken(response.data['access_token']);
        Get.offAllNamed(AppRoutes.homePage);
      } else {
        Get.snackbar('Error', 'Login failed');
      }
    } catch (e) {
          print(e);
      Get.snackbar('Error', 'An error occurred');
    } finally {
      isLoading.value = false;
    }
  }
}
