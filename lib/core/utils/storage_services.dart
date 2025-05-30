import 'package:get_storage/get_storage.dart';

class StorageService {
  static final box = GetStorage();

  static void saveToken(String token) => box.write('token', token);
  static String? getToken() => box.read('token');
  static void clearToken() => box.remove('token');
}
