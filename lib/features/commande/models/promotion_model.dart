class Promotion {
  final int id;
  final String titre;
  final String description;
  final double tauxReduction;
  final String dateDebut;
  final String dateFin;
  final bool isActive;

  Promotion({
    required this.id,
    required this.titre,
    required this.description,
    required this.tauxReduction,
    required this.dateDebut,
    required this.dateFin,
    required this.isActive,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'],
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      tauxReduction: (json['tauxReduction'] as num?)?.toDouble() ?? 0.0,
      dateDebut: json['dateDebut'] ?? '',
      dateFin: json['dateFin'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
} 