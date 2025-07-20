class ObjectifModel {
  final int id;
  final String categorie;
  final double objectif;
  final double? realise;
  final bool atteint;

  ObjectifModel({
    required this.id,
    required this.categorie,
    required this.objectif,
    this.realise,
    required this.atteint,
  });

  factory ObjectifModel.fromJson(Map<String, dynamic> json) {
    return ObjectifModel(
      id: json['id'] as int,
      categorie: json['categorie'] as String,
      objectif: (json['objectif'] as num).toDouble(),
      realise: json['realise'] != null ? (json['realise'] as num).toDouble() : null,
      atteint: json['atteint'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categorie': categorie,
      'objectif': objectif,
      'realise': realise,
      'atteint': atteint,
    };
  }
} 