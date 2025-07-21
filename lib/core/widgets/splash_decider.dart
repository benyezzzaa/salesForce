import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/core/routes/app_routes.dart';
import 'package:pfe/core/utils/storage_services.dart';
import 'package:pfe/core/widgets/app_main.dart';

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLoginStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('🔄 App lifecycle state changed: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App resumed - checking session...');
        _checkLoginStatus();
        break;
      case AppLifecycleState.paused:
        print('⏸️ App paused - session preserved');
        break;
      case AppLifecycleState.detached:
        print('❌ App detached - clearing session (forced close detected)');
        // Nettoyer la session si l'app est fermée de force
        StorageService.clearSession();
        print('✅ Session cleared due to forced app closure');
        break;
      default:
        break;
    }
  }

  void _checkLoginStatus() async {
    print('\n=== SPLASH DECIDER - SESSION CHECK ===');
    
    // Attendre un peu pour que l'interface se charge
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Vérifier si l'utilisateur est connecté
    final isLoggedIn = StorageService.isLoggedIn();
    final token = StorageService.getToken();
    final user = StorageService.getUser();
    
    print('🔍 Token exists: ${token != null}');
    print('🔍 Token length: ${token?.length ?? 0}');
    print('🔍 Token preview: ${token != null ? '${token.substring(0, 20)}...' : 'NULL'}');
    print('🔍 User data exists: ${user != null}');
    print('🔍 User data: $user');
    print('🔍 Is logged in: $isLoggedIn');
    
    if (isLoggedIn && token != null && token.isNotEmpty) {
      print('✅ Utilisateur connecté - Redirection vers BottomNavWrapper');
      Get.offAll(() => const BottomNavWrapper(initialIndex: 0));
    } else {
      print('❌ Utilisateur non connecté - Redirection vers Login');
      Get.offAllNamed(AppRoutes.loginPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF667eea),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou icône
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.business,
                size: 60,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 30),
            
            // Titre
            const Text(
              'Sales Force',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            
            // Sous-titre
            const Text(
              'Vérification de la session...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            
            // Indicateur de chargement
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
} 