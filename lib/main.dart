import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pfe/core/routes/app_routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
   await Geolocator.requestPermission();


  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Define a light color scheme
  final lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF3F51B5), // A shade of Indigo
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFC5CAE9),
    onPrimaryContainer: Color(0xFF1A237E),
    secondary: Color(0xFF607D8B), // Blue Grey
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFCFD8DC),
    onSecondaryContainer: Color(0xFF263238),
    tertiary: Color(0xFF009688), // Teal
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFA7FFEB),
    onTertiaryContainer: Color(0xFF004D40),
    error: Color(0xFFB00020), // Red for errors
    onError: Colors.white,
    errorContainer: Color(0xFFFEEAE6),
    onErrorContainer: Color(0xFF410E0B),
    outline: Color(0xFF757575), // Grey
    background: Color(0xFFF5F5F5), // Light Grey Background
    onBackground: Color(0xFF212121), // Dark Grey Text
    surface: Color(0xFFFFFFFF), // White Surface
    onSurface: Color(0xFF212121), // Dark Grey Text
    surfaceVariant: Color(0xFFEEEEEE), // Lighter Grey Surface Variant
    onSurfaceVariant: Color(0xFF424242), // Medium Grey Text
    inverseSurface: Color(0xFF303030), // Dark Grey Inverse Surface
    onInverseSurface: Color(0xFFFAFAFA), // White Inverse Surface Text
    inversePrimary: Color(0xFF9FA8DA), // Lighter Indigo Inverse Primary
    shadow: Color(0xFF000000), // Black Shadow
    surfaceTint: Color(0xFF3F51B5),
    outlineVariant: Color(0xFFBDBDBD), // Light Grey Outline Variant
    scrim: Color(0xFF000000), // Black Scrim
  );

  // Define a dark color scheme
  final darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF7986CB), // Lighter Indigo
    onPrimary: Colors.black,
    primaryContainer: Color(0xFF303F9F),
    onPrimaryContainer: Color(0xFFC5CAE9),
    secondary: Color(0xFF90A4AE), // Lighter Blue Grey
    onSecondary: Colors.black,
    secondaryContainer: Color(0xFF455A64),
    onSecondaryContainer: Color(0xFFCFD8DC),
    tertiary: Color(0xFF4DB6AC), // Lighter Teal
    onTertiary: Colors.black,
    tertiaryContainer: Color(0xFF00796B),
    onTertiaryContainer: Color(0xFFA7FFEB),
    error: Color(0xFFCF6679), // Light Red for errors
    onError: Colors.black,
    errorContainer: Color(0xFFB00020),
    onErrorContainer: Color(0xFFFEEAE6),
    outline: Color(0xFF9E9E9E), // Grey
    background: Color(0xFF121212), // Dark Background
    onBackground: Color(0xFFE0E0E0), // Light Grey Text
    surface: Color(0xFF1E1E1E), // Dark Surface
    onSurface: Color(0xFFE0E0E0), // Light Grey Text
    surfaceVariant: Color(0xFF424242), // Medium Grey Surface Variant
    onSurfaceVariant: Color(0xFFBDBDBD), // Light Grey Text
    inverseSurface: Color(0xFFE0E0E0), // Light Grey Inverse Surface
    onInverseSurface: Color(0xFF121212), // Dark Inverse Surface Text
    inversePrimary: Color(0xFF3F51B5), // Indigo Inverse Primary
    shadow: Color(0xFF000000), // Black Shadow
    surfaceTint: Color(0xFF7986CB),
    outlineVariant: Color(0xFF757575), // Grey Outline Variant
    scrim: Color(0xFF000000), // Black Scrim
  );

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.loginPage,
      getPages: AppPages.routes,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: lightColorScheme,
      ),
      darkTheme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
      themeMode: ThemeMode.system, // Use system theme (light or dark)
    );
  }
}
