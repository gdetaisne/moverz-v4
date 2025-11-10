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

### Phase 1 : Diagnostic
- [ ] Vérifier le modèle AnalyticsEvent dans schema.prisma
- [ ] Lister les migrations Prisma existantes
- [ ] Se connecter à la DB prod pour voir les tables existantes
- [ ] Identifier la migration manquante

### Phase 2 : Application migration
- [ ] Se connecter à CapRover
- [ ] Exécuter `pnpm prisma migrate deploy` (ou db push)
- [ ] Vérifier que la table est créée

### Phase 3 : Vérification
- [ ] Tester un événement analytics
- [ ] Vérifier les logs CapRover (plus d'erreur P2021)
- [ ] Vérifier les données dans la table

### Phase 4 : Prévention
- [ ] Documenter le process de migration
- [ ] Ajouter un check pre-deploy
- [ ] Mettre à jour les scripts de déploiement

## État d'avancement

**Statut : 📋 À faire**

Checklist :
- [ ] Diagnostic
- [ ] Migration appliquée
- [ ] Tests validés
- [ ] Documentation

## Commits liés

(À compléter)

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

