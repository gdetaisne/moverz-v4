# t002 — Fix: Table AnalyticsEvent manquante en production

## Contexte

Depuis le 3 novembre 2025, les logs CapRover montrent une erreur récurrente :
```
Invalid `prisma.analyticsEvent.create()` invocation:
The table `public.AnalyticsEvent` does not exist in the current database.
Code: P2021
```

Cette erreur apparaît à chaque tentative de tracking d'événement analytics.

## Objectifs

1. Identifier pourquoi la table `AnalyticsEvent` n'existe pas en prod
2. Appliquer la migration manquante
3. Vérifier que l'analytics fonctionne
4. Documenter le process de migration pour éviter ce problème à l'avenir

## Périmètre

### Fichiers concernés
- `prisma/schema.prisma` : Vérifier le modèle AnalyticsEvent
- `prisma/migrations/` : Identifier les migrations non appliquées
- Documentation déploiement

### Actions à réaliser
1. Vérifier le schéma Prisma local vs prod
2. Appliquer `prisma migrate deploy` ou `prisma db push` en prod
3. Tester le tracking analytics après fix
4. Ajouter un check de migration dans le process de déploiement

### Hors périmètre
- Refactoring du système analytics
- Ajout de nouvelles métriques
- Migration vers un autre système

## Implémentation

### Phase 1 : Diagnostic ✅ TERMINÉ
- [x] Vérifier le modèle AnalyticsEvent dans schema.prisma
  - ✅ Le modèle existe dans `schema.prisma`
  - ✅ Structure complète avec userId, eventType, metadata, timestamps
- [x] Lister les migrations Prisma existantes
  - ✅ 6 migrations trouvées dans `prisma/migrations/`
  - ✅ Fichier isolé `analytics_event.sql` NON intégré dans les migrations
- [x] Identifier la migration manquante
  - ✅ Cause racine : `analytics_event.sql` créé manuellement hors du système Prisma
  - ✅ Solution : Créer une migration baseline contenant TOUT le schéma actuel

**Diagnostic détaillé :**
Le fichier `prisma/migrations/analytics_event.sql` contient le CREATE TABLE pour AnalyticsEvent, mais ce fichier n'était pas dans une migration valide. Prisma ne l'a donc jamais appliqué en production.

**Solution implémentée :**
Création d'une migration baseline `20251110145330_baseline` qui contient :
- Tous les CREATE TABLE du schéma actuel
- Tous les CREATE INDEX
- La table AnalyticsEvent manquante
- Les autres tables (Asset, Job, Batch, AiMetric, etc.)

### Phase 2 : Application migration — ⏳ EN ATTENTE PRODUCTION
- [ ] Se connecter à CapRover (action manuelle requise)
- [ ] Exécuter le script `scripts/apply-migrations-prod.sh`
  - OU : `pnpm prisma migrate deploy` directement
- [ ] Vérifier que toutes les migrations sont appliquées

**Préparation locale ✅ :**
- [x] Baseline migration créée
- [x] Migration marquée comme appliquée en local
- [x] DB locale testée et fonctionnelle
- [x] Script d'application créé : `scripts/apply-migrations-prod.sh`

### Phase 3 : Vérification
- [ ] Après application en prod, tester un événement analytics
- [ ] Vérifier les logs CapRover (plus d'erreur P2021)
- [ ] Vérifier les données : `psql $DATABASE_URL -c 'SELECT COUNT(*) FROM "AnalyticsEvent";'`

### Phase 4 : Prévention ✅ PRÉPARÉ
- [x] Documenter le process : `docs/migrations-production.md`
- [x] Script automatique créé : `scripts/apply-migrations-prod.sh`
- [ ] Mettre à jour `deploy-caprover.sh` pour ajouter `prisma migrate deploy`

## État d'avancement

**Statut : ⏳ Prêt pour application en production**

Checklist :
- [x] Diagnostic (cause identifiée)
- [x] Migration baseline créée
- [x] DB locale testée
- [x] Scripts et documentation préparés
- [ ] **ACTION REQUISE** : Appliquer en production
- [ ] Tests de vérification post-migration

## Commits liés

(Voir `.cursor/tasks/commits/t002.md`)

## Notes futures

### Impact utilisateur
- **Gravité** : CRITIQUE ⚠️
- **Fréquence** : À chaque événement analytics
- **Depuis** : 3 novembre 2025
- **Users affectés** : Tous

### Logs d'erreur
```
2025-11-10T03:51:27.425062648Z prisma:error
Invalid `prisma.analyticsEvent.create()` invocation:
The table `public.AnalyticsEvent` does not exist in the current database.
```

### Commandes utiles
```bash
# Se connecter à CapRover
ssh captain@[server]

# Vérifier les tables en DB
psql $DATABASE_URL -c "\dt"

# Appliquer les migrations
pnpm prisma migrate deploy
```

---

## 🚀 PROCHAINES ÉTAPES (Action manuelle requise)

### Ce qui a été fait automatiquement

✅ **Diagnostic complet**
- Cause identifiée : fichier `analytics_event.sql` non intégré aux migrations Prisma
- Solution : migration baseline créée avec tout le schéma

✅ **Préparation locale**
- Migration `20251110145330_baseline` créée et testée
- DB locale PostgreSQL configurée et fonctionnelle
- Scripts prêts pour la production

✅ **Documentation**
- Guide complet : `docs/migrations-production.md`
- Script automatique : `scripts/apply-migrations-prod.sh`

### Ce qu'il reste à faire (nécessite accès CapRover)

#### Option 1 : Via script (RECOMMANDÉ) 🎯

```bash
# 1. SSH vers CapRover
ssh captain@[ton-serveur-caprover]

# 2. Aller dans le répertoire de l'app
cd /captain/apps/moverz-v4

# 3. Exécuter le script
./scripts/apply-migrations-prod.sh
```

#### Option 2 : Manuelle

```bash
# 1. SSH vers CapRover
ssh captain@[ton-serveur-caprover]

# 2. Aller dans l'app
cd /captain/apps/moverz-v4

# 3. Appliquer
pnpm prisma migrate deploy

# 4. Vérifier
pnpm prisma migrate status
```

### Vérification après application

```bash
# Vérifier que la table existe
psql $DATABASE_URL -c "\dt AnalyticsEvent"

# Devrait afficher :
#          List of relations
#  Schema |      Name        | Type  |  Owner
# --------+------------------+-------+----------
#  public | AnalyticsEvent   | table | monitoring
```

### Vérifier les logs CapRover

- Dashboard CapRover > Apps > moverz-v4 > View Logs
- **Avant** : Erreur `P2021` récurrente
- **Après** : Plus d'erreur liée à AnalyticsEvent

---

### Support

En cas de problème, consulter `docs/migrations-production.md` pour :
- Troubleshooting détaillé
- Options de rollback
- Commandes de diagnostic

