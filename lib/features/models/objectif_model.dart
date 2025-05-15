class ObjectifModel {
  final double? montantCible;
  final double? montantActuel; // <-- ajoute ça si ce n’est pas encore défini

  ObjectifModel({this.montantCible, this.montantActuel});

  double get tauxProgression {
    if (montantCible == null || montantCible == 0 || montantActuel == null) {
      return 0.0;
    }
    return (montantActuel! / montantCible!).clamp(0.0, 1.0);
  }

  // Ajoute aussi le fromJson/fromMap si ce n’est pas encore fait
  factory ObjectifModel.fromJson(Map<String, dynamic> json) {
    return ObjectifModel(
      montantCible: json['montantCible']?.toDouble(),
      montantActuel: json['montantActuel']?.toDouble(),
    );
  }
}