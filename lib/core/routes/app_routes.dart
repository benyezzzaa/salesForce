
import 'package:get/get.dart';
import 'package:pfe/features/Auth/screens/login_page.dart';

class AppRoutes {
  static const loginPage = '/loginPage';

}

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.loginPage, page: () => const LoginPage()),
    // GetPage(
    //   // GetPage connecte une route à une page
    //   name: AppRoutes.appBottomBar,
    //   page: () {
    //     final index =
    //         Get.arguments ??
    //         0; // Get.arguments	Permet de passer des données lors de la navigation
    //     return AppBottomBar(initialIndex: index);
    //   },
    // ),
  ];}