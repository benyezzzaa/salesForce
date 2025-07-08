import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/core/routes/app_routes.dart';
import 'package:pfe/core/utils/storage_services.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      final token = StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        Get.offAllNamed(AppRoutes.bottomNavWrapper);
      } else {
        Get.offAllNamed(AppRoutes.loginPage);
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
} 