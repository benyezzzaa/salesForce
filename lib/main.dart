import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pfe/core/routes/app_routes.dart';
import 'package:pfe/core/utils/storage_services.dart';
import 'package:pfe/core/widgets/app_main.dart';
import 'package:pfe/core/widgets/splash_decider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Geolocator.requestPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Define a modern light color scheme with gradients
  final lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF667eea), // Modern blue
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFe0e7ff),
    onPrimaryContainer: Color(0xFF1e293b),
    secondary: Color(0xFF764ba2), // Purple
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFf3e8ff),
    onSecondaryContainer: Color(0xFF581c87),
    tertiary: Color(0xFFf59e0b), // Amber
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFfef3c7),
    onTertiaryContainer: Color(0xFF92400e),
    error: Color(0xFFef4444), // Red
    onError: Colors.white,
    errorContainer: Color(0xFFfef2f2),
    onErrorContainer: Color(0xFF991b1b),
    outline: Color(0xFF6b7280),
    background: Color(0xFFf8fafc), // Light gray background
    onBackground: Color(0xFF1e293b),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1e293b),
    surfaceVariant: Color(0xFFf1f5f9),
    onSurfaceVariant: Color(0xFF475569),
    inverseSurface: Color(0xFF334155),
    onInverseSurface: Color(0xFFf8fafc),
    inversePrimary: Color(0xFFa5b4fc),
    shadow: Color(0xFF000000),
    surfaceTint: Color(0xFF667eea),
    outlineVariant: Color(0xFFcbd5e1),
    scrim: Color(0xFF000000),
  );

  // Define a modern dark color scheme with gradients
  final darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF818cf8), // Lighter blue
    onPrimary: Color(0xFF1e293b),
    primaryContainer: Color(0xFF3730a3),
    onPrimaryContainer: Color(0xFFe0e7ff),
    secondary: Color(0xFFa78bfa), // Lighter purple
    onSecondary: Color(0xFF1e293b),
    secondaryContainer: Color(0xFF581c87),
    onSecondaryContainer: Color(0xFFf3e8ff),
    tertiary: Color(0xFFfbbf24), // Lighter amber
    onTertiary: Color(0xFF1e293b),
    tertiaryContainer: Color(0xFF92400e),
    onTertiaryContainer: Color(0xFFfef3c7),
    error: Color(0xFFf87171), // Lighter red
    onError: Color(0xFF1e293b),
    errorContainer: Color(0xFF991b1b),
    onErrorContainer: Color(0xFFfef2f2),
    outline: Color(0xFF9ca3af),
    background: Color(0xFF0f172a), // Dark blue background
    onBackground: Color(0xFFf1f5f9),
    surface: Color(0xFF1e293b),
    onSurface: Color(0xFFf1f5f9),
    surfaceVariant: Color(0xFF334155),
    onSurfaceVariant: Color(0xFFcbd5e1),
    inverseSurface: Color(0xFFf1f5f9),
    onInverseSurface: Color(0xFF1e293b),
    inversePrimary: Color(0xFF667eea),
    shadow: Color(0xFF000000),
    surfaceTint: Color(0xFF818cf8),
    outlineVariant: Color(0xFF475569),
    scrim: Color(0xFF000000),
  );

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // initialRoute: AppRoutes.loginPage,
      // getPages: AppPages.routes,
      home: const SplashDecider(),
      getPages: AppPages.routes,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: lightColorScheme,
        // Global button theme for light mode
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightColorScheme.primary,
            foregroundColor: Colors.white, // White text for buttons
            elevation: 4,
            shadowColor: lightColorScheme.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white, // Ensure white text
            ),
          ),
        ),
        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: lightColorScheme.primary,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Outlined button theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: lightColorScheme.primary,
            side: BorderSide(color: lightColorScheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // App bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // Card theme
        cardTheme: CardTheme(
          color: lightColorScheme.surface,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightColorScheme.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightColorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: darkColorScheme,
        // Global button theme for dark mode
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkColorScheme.primary,
            foregroundColor: darkColorScheme.onPrimary,
            elevation: 4,
            shadowColor: darkColorScheme.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkColorScheme.onPrimary,
            ),
          ),
        ),
        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: darkColorScheme.primary,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Outlined button theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: darkColorScheme.primary,
            side: BorderSide(color: darkColorScheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // App bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: darkColorScheme.primary,
          foregroundColor: darkColorScheme.onPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkColorScheme.onPrimary,
          ),
        ),
        // Card theme
        cardTheme: CardTheme(
          color: darkColorScheme.surface,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkColorScheme.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: darkColorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      themeMode: ThemeMode.system, // Use system theme (light or dark)
    );
  }
}
