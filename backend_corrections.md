# 🔧 Corrections Backend pour Commandes Modifiées

## 1. Correction du contrôleur (commande.controller.ts)

```typescript
// ✅ Ajout des endpoints manquants
@Get('modifiees')
@SetRoles('commercial')
@ApiOperation({ summary: 'Récupérer les commandes modifiées par l\'admin' })
async getCommandesModifiees(@Req() req) {
  return this.commandeService.getCommandesModifieesPourCommercial(req.user.id);
}

@Get('modifiees/details/:id')
@SetRoles('commercial')
@ApiOperation({ summary: 'Récupérer les détails d\'une commande modifiée' })
async getDetailsCommandeModifiee(@Param('id') id: number, @Req() req) {
  return this.commandeService.getDetailsCommandeModifiee(id, req.user.id);
}

@Put('notifications/:id/vu')
@SetRoles('commercial')
@ApiOperation({ summary: 'Marquer une notification comme vue' })
async marquerNotificationCommeVue(@Param('id') id: number, @Req() req) {
  return this.commandeService.marquerNotificationCommeVue(id, req.user.id);
}

@Get('notifications/count')
@SetRoles('commercial')
@ApiOperation({ summary: 'Compter les notifications non vues' })
async getNombreNotificationsNonVues(@Req() req) {
  return this.commandeService.getNombreNotificationsNonVues(req.user.id);
}
```

## 2. Ajout des méthodes manquantes dans le service (commande.service.ts)

```typescript
// ✅ Méthode pour récupérer les détails d'une commande modifiée
async getDetailsCommandeModifiee(commandeId: number, commercialId: number) {
  const commande = await this.commandeRepository.findOne({
    where: { 
      id: commandeId,
      commercial: { id: commercialId },
      estModifieParAdmin: true 
    },
    relations: ['client', 'lignesCommande', 'lignesCommande.produit', 'promotion'],
  });

  if (!commande) {
    throw new NotFoundException('Commande modifiée introuvable');
  }

  // Récupérer l'historique des modifications
  const historique = await this.historiqueCommandeRepository.find({
    where: { commande: { id: commandeId } },
    relations: ['modifiePar'],
    order: { dateModification: 'DESC' },
  });

  return {
    commande,
    modifications: historique,
    nombreModifications: historique.length,
  };
}

// ✅ Méthode pour marquer une notification comme vue
async marquerNotificationCommeVue(historiqueId: number, commercialId: number) {
  const historique = await this.historiqueCommandeRepository.findOne({
    where: { 
      id: historiqueId,
      commande: { commercial: { id: commercialId } }
    },
  });

  if (!historique) {
    throw new NotFoundException('Notification introuvable');
  }

  historique.vuParCommercial = true;
  await this.historiqueCommandeRepository.save(historique);

  return { success: true, message: 'Notification marquée comme vue' };
}

// ✅ Méthode pour compter les notifications non vues
async getNombreNotificationsNonVues(commercialId: number) {
  const count = await this.historiqueCommandeRepository.count({
    where: {
      vuParCommercial: false,
      commande: { commercial: { id: commercialId } }
    },
  });

  return { count };
}

// ✅ Méthode améliorée pour récupérer les commandes modifiées
async getCommandesModifieesPourCommercial(commercialId: number) {
  const commandes = await this.commandeRepository.find({
    where: {
      commercial: { id: commercialId },
      estModifieParAdmin: true,
    },
    relations: ['client', 'lignesCommande', 'lignesCommande.produit', 'promotion'],
    order: { dateCreation: 'DESC' },
  });

  // Pour chaque commande, vérifier si elle a des notifications non vues
  const commandesAvecNotifications = await Promise.all(
    commandes.map(async (commande) => {
      const notificationsNonVues = await this.historiqueCommandeRepository.count({
        where: {
          commande: { id: commande.id },
          vuParCommercial: false,
        },
      });

      return {
        ...commande,
        notificationsNonVues,
        vu: notificationsNonVues === 0,
      };
    })
  );

  return commandesAvecNotifications;
}
```

## 3. Correction de l'entité HistoriqueCommande

```typescript
// historique-commande.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn } from 'typeorm';
import { Commande } from './commande.entity';
import { User } from '../users/users.entity';

@Entity({ name: 'historique_commande' })
export class HistoriqueCommande {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Commande, commande => commande.historique)
  commande: Commande;

  @Column()
  champModifie: string;

  @Column()
  ancienneValeur: string;

  @Column()
  nouvelleValeur: string;

  @ManyToOne(() => User)
  modifiePar: User;

  @Column({ default: false })
  vuParCommercial: boolean;

  @CreateDateColumn()
  dateModification: Date;
}
```

## 4. Correction de l'entité Commande

```typescript
// commande.entity.ts - Ajout de la relation manquante
@OneToMany(() => HistoriqueCommande, h => h.commande, { cascade: true })
historique: HistoriqueCommande[];
```

## 5. Endpoints complets pour le frontend

### Endpoints disponibles :
- `GET /commandes/modifiees` - Liste des commandes modifiées
- `GET /commandes/modifiees/details/:id` - Détails d'une commande modifiée
- `GET /commandes/notifications` - Notifications de modifications
- `GET /commandes/notifications/count` - Nombre de notifications non vues
- `PUT /commandes/notifications/:id/vu` - Marquer une notification comme vue
- `PATCH /commandes/historique/vue` - Marquer toutes comme vues

## 6. Structure de réponse pour les commandes modifiées

```json
{
  "id": 1,
  "numero_commande": "CMD-123456789",
  "dateCreation": "2024-01-15T10:30:00Z",
  "prix_total_ttc": 150.00,
  "prix_hors_taxe": 142.18,
  "statut": "validee",
  "estModifieParAdmin": true,
  "notificationsNonVues": 2,
  "vu": false,
  "client": {
    "id": 1,
    "nom": "Dupont",
    "prenom": "Jean"
  },
  "lignesCommande": [
    {
      "id": 1,
      "quantite": 2,
      "prixUnitaire": 25.00,
      "total": 50.00,
      "produit": {
        "id": 1,
        "nom": "Produit A"
      }
    }
  ],
  "promotion": null
}
```

## 7. Structure de réponse pour les détails des modifications

```json
{
  "commande": { /* données de la commande */ },
  "modifications": [
    {
      "id": 1,
      "champModifie": "Quantité - Produit A",
      "ancienneValeur": "1",
      "nouvelleValeur": "2",
      "dateModification": "2024-01-15T10:30:00Z",
      "modifiePar": {
        "id": 1,
        "nom": "Admin",
        "prenom": "User"
      },
      "vuParCommercial": false
    }
  ],
  "nombreModifications": 1
}
```

## 8. Migration SQL pour ajouter les colonnes manquantes

```sql
-- Ajouter la colonne estModifieParAdmin si elle n'existe pas
ALTER TABLE commande ADD COLUMN IF NOT EXISTS est_modifie_par_admin BOOLEAN DEFAULT FALSE;

-- Créer la table historique_commande si elle n'existe pas
CREATE TABLE IF NOT EXISTS historique_commande (
  id SERIAL PRIMARY KEY,
  commande_id INTEGER REFERENCES commande(id),
  champ_modifie VARCHAR(255) NOT NULL,
  ancienne_valeur TEXT NOT NULL,
  nouvelle_valeur TEXT NOT NULL,
  modifie_par_id INTEGER REFERENCES users(id),
  vu_par_commercial BOOLEAN DEFAULT FALSE,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 9. Test des endpoints

### Test avec curl :
```bash
# Récupérer les commandes modifiées
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:4000/commandes/modifiees

# Récupérer les détails d'une commande modifiée
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:4000/commandes/modifiees/details/1

# Compter les notifications non vues
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:4000/commandes/notifications/count

# Marquer une notification comme vue
curl -X PUT -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:4000/commandes/notifications/1/vu
```

## 10. Intégration avec le frontend

Le frontend que nous avons créé est déjà compatible avec ces endpoints. Il suffit de s'assurer que :

1. Les URLs dans `app_api.dart` correspondent aux endpoints du backend
2. Les structures de données correspondent entre frontend et backend
3. Les tokens d'authentification sont bien envoyés

## 🚀 Prochaines étapes

1. **Implémenter les corrections** dans votre backend
2. **Tester les endpoints** avec Postman ou curl
3. **Vérifier l'intégration** avec le frontend
4. **Ajouter des logs** pour le débogage
5. **Implémenter la pagination** si nécessaire 