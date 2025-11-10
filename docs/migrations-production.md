# Guide: Appliquer les migrations Prisma en production

## Contexte

Les migrations Prisma n'ont pas été appliquées sur la base de production CapRover, causant l'erreur :
```
The table `public.AnalyticsEvent` does not exist in the current database.
```

## Prérequis

1. Accès SSH à CapRover
2. Variables d'environnement configurées
3. Backup de la DB (recommandé)

## Étapes d'application

### Option 1 : Via script automatique (RECOMMANDÉ)

```bash
# 1. Se connecter à CapRover via SSH
ssh captain@[votre-serveur]

# 2. Aller dans le répertoire de l'app
cd /captain/apps/moverz-v4

# 3. Exécuter le script
./scripts/apply-migrations-prod.sh
```

### Option 2 : Manuellement

```bash
# 1. SSH vers CapRover
ssh captain@[votre-serveur]

# 2. Aller dans l'app
cd /captain/apps/moverz-v4

# 3. Vérifier le statut
pnpm prisma migrate status

# 4. Appliquer les migrations
pnpm prisma migrate deploy

# 5. Vérifier que tout est appliqué
pnpm prisma migrate status
```

### Option 3 : Via tunnel SSH (depuis ton Mac)

```bash
# 1. Créer un tunnel SSH vers la DB PostgreSQL
ssh -L 5433:srv-captain--postgres-monitoring:5432 captain@[serveur]

# 2. Dans un autre terminal, avec DATABASE_URL pointant sur localhost:5433
DATABASE_URL="postgresql://monitoring:monitoring123@localhost:5433/monitoring" \
  pnpm prisma migrate deploy
```

## Vérification

### 1. Vérifier que la table existe

```bash
psql $DATABASE_URL -c "\dt AnalyticsEvent"
```

Devrait afficher :
```
         List of relations
 Schema |      Name        | Type  |  Owner
--------+------------------+-------+----------
 public | AnalyticsEvent   | table | monitoring
```

### 2. Vérifier les logs CapRover

Aller sur CapRover Dashboard > Apps > moverz-v4 > View Logs

**Avant le fix** : Erreur `P2021` récurrente  
**Après le fix** : Plus d'erreur P2021

### 3. Tester le tracking analytics

```bash
curl -X POST https://[votre-domaine]/api/analytics/track \
  -H "content-type: application/json" \
  -H "x-user-id: test-user" \
  -d '{"eventType":"test","metadata":{}}'
```

## Migrations appliquées

Voici les migrations qui seront appliquées :

1. **20251008061154_init_postgres_from_sqlite** : Migration initiale
2. **20251008071731_add_ai_metrics_observability** : Table AiMetric
3. **20251008074600_add_asset_job_s3_upload** : Tables Asset + Job
4. **20251008082722_lot10_add_photo_analysis_fields** : Champs analysis
5. **20251008084103_lot11_add_batch_orchestration** : Table Batch
6. **20251110145330_baseline** : Baseline complète (inclut AnalyticsEvent)

## En cas de problème

### Erreur: "Migration already applied"

C'est normal si certaines migrations sont déjà appliquées. Prisma les skip automatiquement.

### Erreur: "Database schema drift detected"

```bash
# Option A : Forcer avec db push (perd l'historique)
pnpm prisma db push --accept-data-loss

# Option B : Reset complet (DANGER - perte de données)
# NE PAS FAIRE EN PROD sans backup !
```

### Rollback

Si un problème survient, contactez l'équipe. Le rollback nécessite une migration inverse manuelle.

## Prévention future

### Ajouter dans le process de déploiement

**Dans deploy-caprover.sh** (ou équivalent), ajouter :

```bash
echo "📦 Application des migrations Prisma..."
pnpm prisma migrate deploy

echo "🚀 Démarrage de l'application..."
# ... rest of deploy
```

### Check pre-deploy

```bash
# Avant chaque deploy, vérifier localement
pnpm prisma migrate status

# S'assurer qu'aucune migration n'est en attente
```

## Support

En cas de problème :
1. Vérifier les logs CapRover
2. Vérifier la connexion DATABASE_URL
3. Consulter la task t002 pour le contexte complet

