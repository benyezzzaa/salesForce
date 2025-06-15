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
      id: json['id'],
      categorie: json['categorie'] ?? 'N/A',
      objectif: (json['objectif'] ?? 0).toDouble(),
      realise: (json['realise'] ?? 0).toDouble(),
      atteint: json['atteint'] ?? false,
    );
  }
}
