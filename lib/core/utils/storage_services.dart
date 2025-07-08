import 'package:get_storage/get_storage.dart';

class StorageService {
  static final box = GetStorage();

  static Future<void> saveToken(String token) async => await box.write('token', token);
  static String? getToken() => box.read('token');
  static void clearToken() => box.remove('token');

   static Future<void> saveUser(Map<String, dynamic> userData) async {
    await box.write('user', userData);
  }

  static Map<String, dynamic>? getUser() {
    return box.read('user');
  }
    // Session management
  static bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  static void clearSession() {
    clearToken();
    box.remove('user');
  }

  // Session timestamp for token expiration check
  static void saveLoginTimestamp() {
    box.write('login_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  static DateTime? getLoginTimestamp() {
    final timestamp = box.read('login_timestamp');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
}
