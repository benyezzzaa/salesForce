class ClientModel {
  final int id;
  final double latitude;
  final double longitude;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String adresse;
  final bool isActive;

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
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      isActive: json['isActive'],
    );
  }

  String get fullName => '$prenom $nom';
} 