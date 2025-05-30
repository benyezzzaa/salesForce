// 📁 lib/models/objectif_model.dart
class ObjectifModel {
  final int annee;
  final double objectif;
  final double realise;

  ObjectifModel({required this.annee, required this.objectif, required this.realise});

  factory ObjectifModel.fromJson(Map<String, dynamic> json) {
    return ObjectifModel(
      annee: json['annee'],
      objectif: (json['objectif'] ?? 0).toDouble(),
      realise: (json['realise'] ?? 0).toDouble(),
    );
  }
}
