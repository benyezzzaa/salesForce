class VenteParCategorie {
  final String categorie;
  final int totalQuantite;

  VenteParCategorie({
    required this.categorie,
    required this.totalQuantite,
  });

  factory VenteParCategorie.fromJson(Map<String, dynamic> json) {
    return VenteParCategorie(
      categorie: json['categorie'],
      totalQuantite: int.parse(json['totalQuantite']),
    );
  }
}
 