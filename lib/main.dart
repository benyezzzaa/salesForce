import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pfe/core/routes/app_routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();


  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.loginPage,
      getPages: AppPages.routes,
      theme: ThemeData(fontFamily: 'Roboto'), // optionnel
    );
  }
}
