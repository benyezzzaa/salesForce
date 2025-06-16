// app_api.dart

class AppApi {
  // Base URL
  static const String baseUrl = "http://10.10.30.225:4000";
  static const String loginUrl = "$baseUrl/auth/login";
  static const String getCommandeUrl = "$baseUrl/commandes";
  static const String getClientsUrl = "$baseUrl/client";
  static const String createClientUrl = "$baseUrl/client";
  static const String getTodayCircuitUrl = "$baseUrl/circuits/me/today";
  static const String getPromotionsUrl = "$baseUrl/promotions";
  static const String getClientsOfCurrentCommercial = '$baseUrl/client/mes-clients';
  static const mesObjectifs = "/objectifs/me/progress";
  // reset password
}
