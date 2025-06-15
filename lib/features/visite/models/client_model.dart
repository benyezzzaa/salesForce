class ClientModel {
  final int id;
  final double? latitude;
  final double? longitude;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String adresse;
  bool isActive; // 👈 modifiable pour switch

  ClientModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.isActive,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      adresse: json['adresse'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  /// 💡 Utilitaire : nom complet
  String get fullName => '$prenom $nom';
}
