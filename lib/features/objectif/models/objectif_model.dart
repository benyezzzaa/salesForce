class ObjectifModel {
  final int id;
  final String mission;
  final DateTime dateDebut;
  final DateTime dateFin;
  final double prime;
  final double ventes;
  final double montantCible;
  final bool atteint;
  final bool isGlobal; // Nouveau champ pour distinguer les objectifs globaux

  ObjectifModel({
    required this.id,
    required this.mission,
    required this.dateDebut,
    required this.dateFin,
    required this.prime,
    required this.ventes,
    required this.montantCible,
    required this.atteint,
    this.isGlobal = false, // Par défaut false
  });

  factory ObjectifModel.fromJson(Map<String, dynamic> json) {
    print('🔍 ObjectifModel.fromJson: Parsing $json');
    
    // Fonction helper pour convertir en double de manière sécurisée
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('❌ Erreur parsing double: $value');
          return 0.0;
        }
      }
      print('❌ Type inattendu pour double: ${value.runtimeType} = $value');
      return 0.0;
    }
    
    // Fonction helper pour convertir en DateTime de manière sécurisée
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('❌ Erreur parsing date: $value');
          return DateTime.now();
        }
      }
      print('❌ Type inattendu pour date: ${value.runtimeType} = $value');
      return DateTime.now();
    }
    
    return ObjectifModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      mission: json['mission']?.toString() ?? 'Objectif sans description',
      dateDebut: parseDate(json['dateDebut']),
      dateFin: parseDate(json['dateFin']),
      prime: parseDouble(json['prime']),
      ventes: parseDouble(json['ventes']),
      montantCible: parseDouble(json['montantCible']),
      atteint: json['atteint'] is bool ? json['atteint'] : json['atteint']?.toString().toLowerCase() == 'true',
      isGlobal: json['isGlobal'] is bool ? json['isGlobal'] : json['isGlobal']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mission': mission,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
      'prime': prime,
      'ventes': ventes,
      'montantCible': montantCible,
      'atteint': atteint,
      'isGlobal': isGlobal,
    };
  }

  // Getters pour compatibilité avec l'interface existante
  String get categorie => mission;
  double get objectif => montantCible;
  double? get realise => ventes;
  
  // Calcul du pourcentage de réalisation
  double get pourcentageRealise {
    if (montantCible == 0) return 0;
    return (ventes / montantCible) * 100;
  }
} 