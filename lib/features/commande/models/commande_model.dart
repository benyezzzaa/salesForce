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
  final List<LigneCommande> lignes;

  CommandeModel({
    required this.id,
    required this.numeroCommande,
    required this.dateCreation,
    required this.prixTotalTTC,
    required this.prixHorsTaxe,
    this.clientEmail,
    required this.statut,
    required this.clientNom,
    required this.lignes,
    this.clientAdresse,
  });

  factory CommandeModel.fromJson(Map<String, dynamic> json) {
    return CommandeModel(
      id: json['id'],
      numeroCommande: json['numero_commande'],
      dateCreation: json['date_creation'],
      clientEmail: json['client']['email'], 
      prixTotalTTC: double.tryParse(json['prix_total_ttc'].toString()) ?? 0,
      prixHorsTaxe: double.tryParse(json['prix_hors_taxe'].toString()) ?? 0,
      statut: json['statut'] ?? 'en_attente',
      clientNom: json['client']?['nom'] ?? 'Inconnu',
      clientAdresse: json['client']?['adresse'] ?? '',
      lignes: (json['lignesCommande'] as List<dynamic>? ?? [])
          .map((e) => LigneCommande.fromJson(e))
          .toList(),
    );
  }
}

class LigneCommande {
  final String produit;
  final int quantite;
  final double prix;

  LigneCommande({required this.produit, required this.quantite, required this.prix});

  factory LigneCommande.fromJson(Map<String, dynamic> json) {
    return LigneCommande(
      produit: json['produit']?['nom'] ?? 'Produit inconnu',
      quantite: json['quantite'] ?? 0,
      prix: double.tryParse(json['prixUnitaire'].toString()) ?? 0,
    );
  }
}
