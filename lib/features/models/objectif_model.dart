class ObjectifCommercial {
  final int id;
  final String titre;
  final double valeurCible;
  final String dateDebut;
  final String dateFin;

  ObjectifCommercial({
    required this.id,
    required this.titre,
    required this.valeurCible,
    required this.dateDebut,
    required this.dateFin,
  });

  factory ObjectifCommercial.fromJson(Map<String, dynamic> json) {
    return ObjectifCommercial(
      id: json['id'],
      titre: json['titre'],
      valeurCible: (json['valeurCible'] as num).toDouble(),
      dateDebut: json['dateDebut'],
      dateFin: json['dateFin'],
    );
  }
}
