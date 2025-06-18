# Guide : Affichage des Positions sur la Carte

## 🗺️ Fonctionnalité Ajoutée

Cette fonctionnalité permet d'afficher simultanément sur une carte :
- La position du commercial connecté
- La position du client sélectionné
- La position GPS actuelle (si différente du commercial)
- Le trajet entre le commercial et le client

## 📍 Comment Utiliser

### 1. Après la Création d'une Visite (Automatique)

1. **Créer une visite** : Menu → Visites → Nouvelle Visite
2. **Remplir les informations** : Date, Client, Raison
3. **Cliquer sur "Créer la visite"**
4. **Redirection automatique** : La carte s'ouvre automatiquement avec les positions

### 2. Depuis la Page de Création de Visite (Manuel)

1. **Accéder à la page** : Menu → Visites → Nouvelle Visite
2. **Sélectionner un client** : Choisir un client dans la liste déroulante
3. **Afficher la carte** : Un bouton "Voir les positions sur la carte" apparaît automatiquement
4. **Cliquer sur le bouton** : La carte s'ouvre avec les positions affichées

### 3. Depuis la Page des Clients

1. **Accéder à la page** : Menu → Clients
2. **Trouver un client** : Utiliser la barre de recherche si nécessaire
3. **Voir la position** : Cliquer sur l'icône de carte à côté du switch d'activation
4. **Afficher la carte** : La carte s'ouvre avec les positions du commercial et du client

## 🎯 Fonctionnalités de la Carte

### Marqueurs Colorés
- **🔵 Bleu** : Position du commercial connecté
- **🔴 Rouge** : Position du client sélectionné
- **🟢 Vert** : Position GPS actuelle (si différente du commercial)

### Informations Affichées
- **Message de succès** : Confirmation de la création de visite
- **En-tête** : Nom du commercial et du client avec leurs adresses
- **Marqueurs** : Infobulles avec noms et adresses au clic
- **Trajet** : Ligne bleue reliant le commercial au client

### Contrôles de la Carte
- **Zoom automatique** : La carte s'ajuste pour afficher tous les points
- **Bouton ma position** : Recentrer sur la position GPS actuelle
- **Contrôles de zoom** : Zoomer/dézoomer manuellement
- **Barre d'outils** : Options supplémentaires de navigation

### Boutons d'Action (AppBar)
- **➕ Nouvelle visite** : Créer une autre visite
- **🛣️ Voir le circuit** : Afficher le circuit complet de la journée

## ⚠️ Conditions d'Affichage

### Position du Commercial
- ✅ Affichée si les coordonnées sont disponibles dans le profil
- ❌ Masquée si les coordonnées sont manquantes

### Position du Client
- ✅ Affichée si les coordonnées sont disponibles
- ❌ Masquée si les coordonnées sont manquantes
- 💡 Le bouton de carte n'apparaît que si le client a des coordonnées

### Position GPS Actuelle
- ✅ Affichée si différente de plus de 100m du commercial
- 🔄 Demande automatique des permissions de localisation
- ❌ Masquée si les permissions sont refusées

## 🔧 Configuration Requise

### Permissions
- **Localisation** : Nécessaire pour la position GPS actuelle
- **Internet** : Pour charger les tuiles de carte Google Maps

### Données
- **Profil commercial** : Doit contenir latitude/longitude
- **Profil client** : Doit contenir latitude/longitude
- **Token d'authentification** : Pour récupérer les données utilisateur

## 🎨 Interface Utilisateur

### Page de Création de Visite
```
┌─────────────────────────────────┐
│ Date de visite                  │
│ [Sélectionner une date]        │
├─────────────────────────────────┤
│ Client                          │
│ [Sélectionner un client]       │
│ [Voir les positions sur la carte] │
├─────────────────────────────────┤
│ Raison de visite               │
│ [Sélectionner une raison]      │
├─────────────────────────────────┤
│ [Créer la visite]              │
└─────────────────────────────────┘
```

### Page des Clients
```
┌─────────────────────────────────┐
│ [🔍 Rechercher]                 │
├─────────────────────────────────┤
│ 👤 Client 1                     │
│    email@example.com            │
│    Adresse du client            │
│    [🗺️] [⚪/🔴]                 │
├─────────────────────────────────┤
│ 👤 Client 2                     │
│    email2@example.com           │
│    Adresse du client 2          │
│    [🗺️] [⚪/🔴]                 │
└─────────────────────────────────┘
```

### Page de Carte (Après Création de Visite)
```
┌─────────────────────────────────┐
│ Positions sur la carte [+][🛣️]  │
├─────────────────────────────────┤
│ ✅ Visite créée avec succès !   │
│ Commercial: Jean Dupont         │
│ Client: Marie Martin            │
│ Adresse: 123 Rue de la Paix     │
├─────────────────────────────────┤
│                                 │
│        🗺️ Carte Google          │
│                                 │
│                                 │
├─────────────────────────────────┤
│ 🔵 Commercial  🔴 Client        │
│ 🟢 Position GPS  ──── Trajet    │
└─────────────────────────────────┘
```

## 🚀 Avantages

1. **Visualisation immédiate** : Voir rapidement la distance entre commercial et client
2. **Confirmation visuelle** : Confirmer que la visite a été créée avec succès
3. **Planification optimisée** : Identifier les clients les plus proches
4. **Navigation facilitée** : Avoir les coordonnées précises pour le GPS
5. **Gestion efficace** : Organiser les visites par proximité géographique
6. **Workflow fluide** : Redirection automatique après création

## 🔄 Flux de Travail

### Création de Visite → Carte des Positions
1. **Créer la visite** → Validation automatique
2. **Redirection** → Page des positions s'ouvre automatiquement
3. **Visualisation** → Voir commercial et client sur la carte
4. **Actions** → Créer une nouvelle visite ou voir le circuit

### Navigation depuis la Carte
- **Bouton +** : Créer une nouvelle visite
- **Bouton 🛣️** : Voir le circuit complet de la journée
- **Retour** : Retourner à la page précédente

## 🔄 Mise à Jour des Positions

- **Commercial** : Mise à jour lors de la connexion
- **Client** : Mise à jour lors de la modification du profil client
- **GPS** : Mise à jour en temps réel lors de l'utilisation

## 📱 Compatibilité

- ✅ Android
- ✅ iOS
- ✅ Web (avec limitations GPS)
- ✅ Desktop (avec limitations GPS)

## 🆘 Dépannage

### Carte ne s'affiche pas
- Vérifier la connexion internet
- Vérifier les permissions de localisation
- Redémarrer l'application

### Positions manquantes
- Vérifier que le profil commercial a des coordonnées
- Vérifier que le client a des coordonnées
- Contacter l'administrateur pour mettre à jour les données

### Erreur de permission
- Aller dans Paramètres → Applications → Votre App → Permissions
- Activer la localisation
- Redémarrer l'application

### Redirection ne fonctionne pas
- Vérifier que le token d'authentification est valide
- Vérifier que les données du commercial sont disponibles
- Redémarrer l'application 