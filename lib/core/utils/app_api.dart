// app_api.dart

class AppApi {
  // Base URL
  static const String baseUrl = "http://10.240.159.70:4000";
  
  static const String loginUrl = "$baseUrl/auth/login";
  static const String getCommandeUrl = "$baseUrl/commandes";
  static const String getCommandesModifieesUrl = "$baseUrl/commandes/modifiees";
  static const String getCommandesModifieesDetailsUrl = "$baseUrl/commandes/modifiees/details";
  static const String getNotificationsCountUrl = "$baseUrl/commandes/notifications/count";
  static const String getClientsUrl = "$baseUrl/client";
  static const String createClientUrl = "$baseUrl/client";
  static const String getTodayCircuitUrl = "$baseUrl/circuits/me/today";
  static const String getPromotionsUrl = "$baseUrl/promotions";
  static const String getClientsOfCurrentCommercial = "$baseUrl/client/mes-clients";
  static const String mesObjectifs = "$baseUrl/objectifs/me/progress";
  static const String forgotPasswordUrl = "$baseUrl/auth/forgot-password";
  static const String resetPasswordUrl = "$baseUrl/auth/reset-password";
  
  // Visites et Circuits - Endpoints spécifiques au commercial connecté
  static const String getMyVisitesUrl = "$baseUrl/visites/me";
  static const String getMyCircuitsUrl = "$baseUrl/circuits/me";
  static const String getVisitesUrl = "$baseUrl/visites";
  static const String getCircuitsUrl = "$baseUrl/circuits";
}
