class ClientModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String adresse;
  bool isActive; // Ajout du champ

  ClientModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.adresse,
    required this.isActive, // Inclure dans le constructeur
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      adresse: json['adresse'] ?? '',
      isActive: json['isActive'] ?? true, // Valeur par défaut true si absente
    );
  }
}
