class ClientModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String adresse;
  final bool isActive;
  final double? latitude;
  final double? longitude;

  ClientModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.isActive,
    this.latitude,
    this.longitude,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'] ?? json['tel'], // ✅ Priorité à 'telephone' (réponse backend)
      adresse: json['adresse'],
      isActive: json['isActive'] ?? true,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone, // ✅ Utilise 'telephone' comme dans la réponse backend
      'adresse': adresse,
      'isActive': isActive,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullName => "$prenom $nom";
}
