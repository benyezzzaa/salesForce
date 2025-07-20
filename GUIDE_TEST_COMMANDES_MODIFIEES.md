# 🧪 Guide de Test - Commandes Modifiées par l'Admin

## 🎯 Objectif

Vérifier que le commercial peut voir les commandes modifiées par l'administrateur dans la page des documents.

## 📋 Prérequis

### Backend
- ✅ Serveur backend démarré sur `http://localhost:4000`
- ✅ Base de données configurée avec les tables nécessaires
- ✅ Endpoints implémentés selon les corrections fournies
- ✅ Authentification JWT fonctionnelle

### Frontend
- ✅ Application Flutter compilée et installée
- ✅ Commercial connecté avec un compte valide
- ✅ Page des documents accessible

## 🚀 Tests à effectuer

### Test 1 : Vérification des endpoints backend

#### 1.1 Test de l'endpoint des commandes modifiées
```bash
# Récupérer les commandes modifiées
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:4000/commandes/modifiees
```

**Résultat attendu :**
```json
[
  {
    "id": 1,
    "numero_commande": "CMD-123456789",
    "estModifieParAdmin": true,
    "notificationsNonVues": 2,
    "vu": false,
    "client": { "nom": "Dupont", "prenom": "Jean" },
    "prix_total_ttc": 150.00
  }
]
```

#### 1.2 Test du comptage des notifications
```bash
# Compter les notifications non vues
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:4000/commandes/notifications/count
```

**Résultat attendu :**
```json
{
  "count": 2
}
```

#### 1.3 Test des détails d'une commande modifiée
```bash
# Récupérer les détails d'une commande modifiée
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:4000/commandes/modifiees/details/1
```

**Résultat attendu :**
```json
{
  "commande": { /* données de la commande */ },
  "modifications": [
    {
      "champModifie": "Quantité - Produit A",
      "ancienneValeur": "1",
      "nouvelleValeur": "2",
      "dateModification": "2024-01-15T10:30:00Z",
      "modifiePar": { "nom": "Admin", "prenom": "User" }
    }
  ]
}
```

### Test 2 : Test de l'interface utilisateur

#### 2.1 Accès à la page des documents
1. **Se connecter** en tant que commercial
2. **Aller dans le menu** → Documents
3. **Vérifier** que la page s'affiche avec deux onglets :
   - "Commandes Validées"
   - "Modifiées" (avec badge rouge si des modifications existent)

#### 2.2 Test de l'onglet "Modifiées"
1. **Cliquer sur l'onglet "Modifiées"**
2. **Vérifier** que la liste des commandes modifiées s'affiche
3. **Vérifier** les indicateurs visuels :
   - Bordure orange pour les commandes non consultées
   - Badge "Nouveau" pour les modifications récentes
   - Icône d'édition pour les commandes modifiées

#### 2.3 Test de la recherche et du filtrage
1. **Utiliser la barre de recherche** pour filtrer par numéro de commande
2. **Sélectionner une date** pour filtrer par date
3. **Vérifier** que les résultats se mettent à jour

#### 2.4 Test des actions sur les commandes
1. **Cliquer sur "Voir les modifications"**
   - Vérifier la navigation vers la page de détails
   - Vérifier l'affichage des modifications avant/après
2. **Cliquer sur "Marquer vu"**
   - Vérifier que la bordure orange disparaît
   - Vérifier que le badge de notification se met à jour

### Test 3 : Test du flux complet

#### 3.1 Création d'une modification par l'admin
1. **Se connecter** en tant qu'administrateur
2. **Modifier une commande** existante (quantité, prix, etc.)
3. **Vérifier** que la modification est enregistrée dans l'historique

#### 3.2 Vérification côté commercial
1. **Se connecter** en tant que commercial
2. **Aller dans Documents** → Onglet "Modifiées"
3. **Vérifier** que la commande modifiée apparaît avec :
   - Badge rouge mis à jour
   - Bordure orange (non consultée)
   - Badge "Nouveau"

#### 3.3 Consultation des modifications
1. **Cliquer sur "Voir les modifications"**
2. **Vérifier** l'affichage des détails :
   - Comparaison avant/après
   - Informations sur qui a modifié
   - Date de modification
3. **Cliquer sur "Marquer comme vue"**
4. **Retourner** à la liste et vérifier que la bordure orange a disparu

## 🔍 Points de vérification

### Backend
- [ ] Endpoint `/commandes/modifiees` retourne les bonnes données
- [ ] Endpoint `/commandes/notifications/count` compte correctement
- [ ] Endpoint `/commandes/modifiees/details/:id` retourne les détails
- [ ] Endpoint `PUT /commandes/notifications/:id/vu` marque comme vue
- [ ] Authentification fonctionne correctement
- [ ] Relations entre entités sont correctes

### Frontend
- [ ] Page des documents s'affiche correctement
- [ ] Onglets fonctionnent et basculent correctement
- [ ] Badge de notification s'affiche et se met à jour
- [ ] Recherche et filtrage fonctionnent
- [ ] Navigation vers les détails fonctionne
- [ ] Marquage comme vue fonctionne
- [ ] Indicateurs visuels s'affichent correctement

### Base de données
- [ ] Table `commande` a la colonne `est_modifie_par_admin`
- [ ] Table `historique_commande` existe avec les bonnes colonnes
- [ ] Relations entre tables sont correctes
- [ ] Données de test sont présentes

## 🐛 Dépannage

### Problèmes courants

#### 1. Erreur 404 sur les endpoints
**Cause :** Endpoints non implémentés dans le backend
**Solution :** Vérifier que tous les endpoints sont ajoutés au contrôleur

#### 2. Erreur d'authentification
**Cause :** Token JWT invalide ou expiré
**Solution :** Se reconnecter et vérifier le token

#### 3. Données vides
**Cause :** Aucune commande modifiée dans la base de données
**Solution :** Créer des modifications de test via l'admin

#### 4. Badge de notification ne se met à jour pas
**Cause :** Endpoint de comptage ne fonctionne pas
**Solution :** Vérifier l'implémentation de `getNombreNotificationsNonVues`

#### 5. Navigation vers les détails ne fonctionne pas
**Cause :** Route non définie ou paramètres incorrects
**Solution :** Vérifier les routes dans `app_routes.dart`

## 📊 Logs de débogage

### Backend
Vérifier les logs du serveur pour :
- Requêtes reçues
- Erreurs de base de données
- Problèmes d'authentification

### Frontend
Vérifier les logs de l'application pour :
- Appels API
- Erreurs de navigation
- Problèmes de parsing des données

## ✅ Critères de succès

Le test est réussi si :
1. ✅ Le commercial peut voir les commandes modifiées par l'admin
2. ✅ Les notifications s'affichent correctement avec un badge
3. ✅ La navigation vers les détails fonctionne
4. ✅ Le marquage comme vue fonctionne
5. ✅ Les indicateurs visuels s'affichent correctement
6. ✅ La recherche et le filtrage fonctionnent
7. ✅ L'interface est responsive et intuitive

## 🚀 Prochaines étapes après validation

1. **Tests de charge** : Vérifier les performances avec beaucoup de données
2. **Tests de sécurité** : Vérifier les permissions d'accès
3. **Tests d'intégration** : Vérifier l'intégration avec d'autres modules
4. **Documentation utilisateur** : Créer un guide pour les utilisateurs finaux
5. **Formation** : Former les utilisateurs à la nouvelle fonctionnalité 