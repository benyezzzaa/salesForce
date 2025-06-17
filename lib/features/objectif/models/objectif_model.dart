class ObjectifModel {
  final int id;
  final String categorie;
  final double objectif;
  final double realise;
  final bool atteint;

  ObjectifModel({
    required this.id,
    required this.categorie,
    required this.objectif,
    required this.realise,
    required this.atteint,
  });

  factory ObjectifModel.fromJson(Map<String, dynamic> json) {
    return ObjectifModel(
      id: json['id'] as int,
      categorie: json['categorie'] as String,
      objectif: (json['objectif'] as num).toDouble(),
      realise: (json['realise'] as num).toDouble(),
      atteint: json['atteint'] as bool,
    );
  }
} 