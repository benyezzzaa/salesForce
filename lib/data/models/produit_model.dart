class ProduitModel {
  final int id;
  final String nom;
  final String description;
  final double prix;
  final int stock;
  final String categorie;
  final String unite;
  final List<String> images;

  ProduitModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.stock,
    required this.categorie,
    required this.unite,
    required this.images,
  });

  factory ProduitModel.fromJson(Map<String, dynamic> json) {
    return ProduitModel(
      id: json['id'],
      nom: json['nom'],
      description: json['description'] ?? '',
      prix: double.tryParse(json['prix'].toString()) ?? 0.0,
      stock: json['stock'] ?? 0,
      categorie: json['categorie']?['nom'] ?? 'Inconnue',
      unite: json['unite']?['nom'] ?? 'Inconnue',
      images: List<String>.from(json['images'] ?? []),
    );
  }
}