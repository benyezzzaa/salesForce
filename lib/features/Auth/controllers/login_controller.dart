import 'package:get/get.dart';
import 'package:pfe/core/routes/app_routes.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/core/utils/app_services.dart';
import 'package:pfe/core/utils/storage_services.dart';
import 'package:pfe/features/home/controller/commercial_controller.dart';
import 'package:pfe/core/widgets/app_main.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;

  final ApiService _apiService = ApiService();

  void updateEmail(String value) => email.value = value;
  void updatePassword(String value) => password.value = value;

  Future<void> login() async {
    isLoading.value = true;
    print('Login attempt started for email: ${email.value}');
    try {
      print('Making API call to: ${AppApi.loginUrl}');
      final response = await _apiService.post(AppApi.loginUrl, {
        'email': email.value,
        'password': password.value,
      }, useToken: false);

      print('API response received - Status: ${response.statusCode}');
      print('API response received - Data: ${response.data}');

      if (response.statusCode == 201) {
   
        final String? token = response.data['access_token'] as String?;
        final userData = response.data['user'];

        if (token != null && token.isNotEmpty && userData != null) {
          // Enregistrement du token
          await StorageService.saveToken(token);

          // Enregistrement des données utilisateur
          await StorageService.saveUser(userData);

          // Supprimer tous les controllers pour forcer une reconstruction propre
          Get.deleteAll(force: true);

          print('Token and user data saved. Navigating to BottomNavWrapper.');
          Get.offAll(() => const BottomNavWrapper(initialIndex: 0));

        } else {
          Get.snackbar('Login Error', 'Missing token or user data.');
        }
      } else {
        print('API call failed with status: ${response.statusCode}');
        final errorMessage =
            (response.data is Map && response.data.containsKey('message'))
                ? response.data['message']
                : 'Login failed';
        Get.snackbar('Login Failed', errorMessage.toString());
      }
    } catch (e) {
      print('Exception during login: $e');
      Get.snackbar('Error', 'An error occurred during login.');
    } finally {
      isLoading.value = false;
      print('Login attempt finished.');
    }
  }
}
