# Fonctionnalité Circuit avec Carte

## Description

Après la création d'une visite, l'application affiche automatiquement le circuit sur une carte interactive avec le trajet tracé entre tous les points de visite.

## Fonctionnalités

### 🗺️ Affichage de la carte
- **Carte Google Maps interactive** avec tous les clients du circuit
- **Marqueurs numérotés** pour chaque client (1, 2, 3, etc.)
- **Marqueur bleu** pour votre position actuelle
- **Marqueurs rouges** pour les clients à visiter

### 🛣️ Trajet tracé
- **Ligne bleue** reliant tous les points du circuit
- **Trajet optimisé** partant de votre position actuelle
- **Affichage automatique** de tous les clients avec coordonnées GPS

### 📱 Interface utilisateur
- **Carte plein écran** avec contrôles de navigation
- **Carte d'information** en haut avec détails du circuit
- **Bouton d'ajustement** pour voir tout le circuit
- **Bouton d'information** pour voir les détails complets

### 📋 Détails du circuit
- **Date du circuit**
- **Informations du commercial**
- **Nombre de clients**
- **Liste complète des clients** avec adresses
- **Indicateurs de localisation** (vert = coordonnées disponibles)

## Comment utiliser

1. **Créer une visite** :
   - Allez dans la section "Visites"
   - Cliquez sur "Nouvelle visite"
   - Sélectionnez la date, le client et la raison
   - Cliquez sur "Créer la visite"

2. **Visualiser le circuit** :
   - Après la création, l'application affiche automatiquement la carte
   - Le circuit est tracé avec tous les clients
   - Votre position actuelle est indiquée par un marqueur bleu

3. **Navigation sur la carte** :
   - **Zoom** : Pincez pour zoomer/dézoomer
   - **Déplacement** : Glissez pour vous déplacer
   - **Ajuster la vue** : Cliquez sur l'icône d'ajustement
   - **Voir les détails** : Cliquez sur l'icône d'information

4. **Informations détaillées** :
   - Cliquez sur l'icône d'information (ℹ️) dans la barre d'outils
   - Une fenêtre s'ouvre avec tous les détails du circuit
   - Liste complète des clients avec leurs adresses

## Permissions requises

L'application nécessite les permissions suivantes :
- **Localisation précise** : Pour afficher votre position sur la carte
- **Localisation approximative** : Pour les fonctionnalités de base

## Configuration technique

### Dépendances utilisées
- `google_maps_flutter: ^2.12.2` - Carte Google Maps
- `geolocator: ^14.0.1` - Géolocalisation

### Configuration Android
- Clé API Google Maps configurée
- Permissions de localisation ajoutées

## Fonctionnalités avancées

### Gestion des erreurs
- **Pas de localisation** : Message d'erreur explicite
- **Pas de clients** : Affichage d'un message informatif
- **Erreurs réseau** : Gestion gracieuse des erreurs

### Optimisations
- **Chargement asynchrone** : Interface réactive pendant le chargement
- **Gestion mémoire** : Nettoyage automatique des ressources
- **Performance** : Optimisation pour les circuits avec de nombreux clients

## Support

Si vous rencontrez des problèmes :
1. Vérifiez que les permissions de localisation sont accordées
2. Assurez-vous d'avoir une connexion internet pour Google Maps
3. Vérifiez que les clients ont des coordonnées GPS valides

## Mise à jour

Cette fonctionnalité est automatiquement incluse dans l'application. Aucune mise à jour manuelle n'est nécessaire. 