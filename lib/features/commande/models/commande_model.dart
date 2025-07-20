class CommandeModel {
  final int id;
  final String numeroCommande;
  final String dateCreation;
  final double prixTotalTTC;
  final double prixHorsTaxe;
  final String statut;
  final String clientNom;
  final String? clientAdresse;
  final String? clientEmail;
  final String? clientTelephone;
  final List<LigneCommande> lignes;
  final Map<String, dynamic>? promotion; 
  CommandeModel({
    required this.id,
    required this.numeroCommande,
    required this.dateCreation,
    required this.prixTotalTTC,
    required this.prixHorsTaxe,
    this.clientEmail,
    this.clientTelephone,
    required this.statut,
    required this.clientNom,
    required this.lignes,
    this.clientAdresse,
    this.promotion,
  });

  factory CommandeModel.fromJson(Map<String, dynamic> json) {
    return CommandeModel(
      id: json['id'],
      numeroCommande: json['numero_commande'],
      dateCreation: json['dateCreation'],
      clientEmail: json['client']?['email'], 
      clientTelephone: json['client']?['telephone'],
      prixTotalTTC: double.tryParse(json['prix_total_ttc'].toString()) ?? 0,
      prixHorsTaxe: double.tryParse(json['prix_hors_taxe'].toString()) ?? 0,
      promotion: json['promotion'], 
      statut: json['statut'] ?? 'en_attente',
      clientNom: '${json['client']?['prenom'] ?? ''} ${json['client']?['nom'] ?? 'Inconnu'}'.trim(),
      clientAdresse: json['client']?['adresse'] ?? '',
      lignes: (json['lignesCommande'] as List<dynamic>? ?? [])
          .map((e) => LigneCommande.fromJson(e))
          .toList(),
    );
  }
}

class LigneCommande {
  final int id;
  final String produitNom;
  final String produitDescription;
  final int quantite;
  final double prixUnitaire;
  final double total;
  final String? produitImage;

  LigneCommande({
    required this.id,
    required this.produitNom,
    required this.produitDescription,
    required this.quantite,
    required this.prixUnitaire,
    required this.total,
    this.produitImage,
  });

  factory LigneCommande.fromJson(Map<String, dynamic> json) {
    final produit = json['produit'] as Map<String, dynamic>? ?? {};
    return LigneCommande(
      id: json['id'] ?? 0,
      produitNom: produit['nom'] ?? 'Produit inconnu',
      produitDescription: produit['description'] ?? '',
      quantite: json['quantite'] ?? 0,
      prixUnitaire: double.tryParse(json['prixUnitaire'].toString()) ?? 0,
      total: double.tryParse(json['total'].toString()) ?? 0,
      produitImage: (produit['images'] as List<dynamic>? ?? []).isNotEmpty 
          ? produit['images'][0] 
          : null,
    );
  }
}
