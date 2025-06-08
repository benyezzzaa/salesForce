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
        print('API call successful, status 201.');
        if (response.data is Map && response.data.containsKey('access_token')) {
          final String? token = response.data['access_token'] as String?;
          if (token != null && token.isNotEmpty) {
            print('Access token found. Saving token.');
            StorageService.saveToken(token);
            print('Token saved. Navigating to home page.');
            Get.offAllNamed(AppRoutes.homePage);
          } else {
            print('Error: Access token is null or empty in response data.');
            Get.snackbar('Login Error', 'Invalid token received from server.');
          }
        } else {
          print('Error: Response data is not a Map or does not contain access_token.');
          Get.snackbar('Login Error', 'Invalid response format from server.');
        }
      } else {
        print('API call failed with status: ${response.statusCode}');
        final errorMessage = (response.data is Map && response.data.containsKey('message'))
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
