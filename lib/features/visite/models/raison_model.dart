class RaisonModel {
  final int id;
  final String nom;
  final bool isActive;

  RaisonModel({
    required this.id,
    required this.nom,
    required this.isActive,
  });

  factory RaisonModel.fromJson(Map<String, dynamic> json) {
    return RaisonModel(
      id: json['id'],
      nom: json['nom'],
      isActive: json['isActive'],
    );
  }
} 