import 'package:get_storage/get_storage.dart';

class StorageService {
  static final box = GetStorage();

  static Future<void> saveToken(String token) async {
    print('🔐 Saving token: ${token.substring(0, 20)}...');
    await box.write('token', token);
    // Forcer la synchronisation
    await box.save();
    print('✅ Token saved successfully');
    
    // Vérifier que le token a bien été sauvegardé
    final savedToken = box.read('token');
    print('🔍 Verification - Token saved: ${savedToken != null}');
  }
  
  static String? getToken() {
    final token = box.read('token');
    print('🔍 Getting token: ${token != null ? 'EXISTS' : 'NULL'}');
    if (token != null) {
      print('🔍 Token length: ${token.length}');
    }
    return token;
  }
  
  static void clearToken() {
    print('🗑️ Clearing token');
    box.remove('token');
    box.save();
  }

  static Future<void> saveUser(Map<String, dynamic> userData) async {
    print('👤 Saving user data: $userData');
    await box.write('user', userData);
    // Forcer la synchronisation
    await box.save();
    print('✅ User data saved successfully');
    
    // Vérifier que les données ont bien été sauvegardées
    final savedUser = box.read('user');
    print('🔍 Verification - User saved: ${savedUser != null}');
  }

  static Map<String, dynamic>? getUser() {
    final user = box.read('user');
    print('👤 Getting user data: ${user != null ? 'EXISTS' : 'NULL'}');
    return user;
  }
  
  // Session management
  static bool isLoggedIn() {
    final token = getToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    print('🔐 Is logged in: $isLoggedIn');
    return isLoggedIn;
  }

  static void clearSession() {
    print('🧹 Clearing entire session');
    clearToken();
    box.remove('user');
    box.save();
    print('✅ Session cleared');
  }

  // Session timestamp for token expiration check
  static void saveLoginTimestamp() {
    print('⏰ Saving login timestamp');
    box.write('login_timestamp', DateTime.now().millisecondsSinceEpoch);
    box.save();
  }

  static DateTime? getLoginTimestamp() {
    final timestamp = box.read('login_timestamp');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
  
  // Méthode pour forcer la synchronisation
  static Future<void> forceSync() async {
    print('💾 Forcing storage sync...');
    await box.save();
    print('✅ Storage synced');
  }
}
