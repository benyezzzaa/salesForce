// app_api.dart

class AppApi {
  // Base URL
  static const String baseUrl = "http://192.168.1.168:4000";
  static const String loginUrl = "$baseUrl/auth/login";
  static const String getCommandeUrl = "$baseUrl/commandes";
  static const String getClientsUrl = "$baseUrl/client";
  static const String createClientUrl = "$baseUrl/client";
  static const String getTodayCircuitUrl = "$baseUrl/circuits/me/today";
  // reset password
}
