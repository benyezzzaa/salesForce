import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:pfe/core/routes/app_routes.dart';



void main() {
  runApp(
  const MyApp(),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.loginPage ,
      getPages: AppPages.routes,
      
    
     
     
    );
  }
}
