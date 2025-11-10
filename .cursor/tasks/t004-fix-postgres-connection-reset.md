# t004 — Fix: Connexions PostgreSQL perdues (Connection reset by peer)

## Contexte

Erreurs récurrentes de perte de connexion à la base de données PostgreSQL :

```
prisma:error Error in PostgreSQL connection: 
Error { kind: Io, cause: Some(Os { code: 104, kind: ConnectionReset, message: "Connection reset by peer" }) }
```

Ces erreurs apparaissent de manière sporadique, plusieurs fois par jour.

## Objectifs

1. Identifier la cause des déconnexions (timeout, pool mal configuré, ressources)
2. Configurer correctement le connection pool Prisma
3. Ajouter un retry logic si nécessaire
4. Monitorer les connexions pour éviter les fuites

## Périmètre

### Fichiers à modifier
- `prisma/schema.prisma` : Configuration datasource
- `lib/db.ts` ou `packages/core/src/db.ts` : Client Prisma
- Variables d'environnement (DATABASE_URL)
- Potentiellement config PostgreSQL sur CapRover

### Investigation nécessaire
- Vérifier les limites de connexions PostgreSQL
- Analyser la fréquence des erreurs
- Identifier si c'est un timeout ou un max connections atteint

### Hors périmètre
- Migration vers un autre système de DB
- Ajout d'un connection pooler externe (PgBouncer)

## Implémentation

### Phase 1 : Diagnostic
- [ ] Analyser les logs pour trouver le pattern des déconnexions
- [ ] Vérifier la config PostgreSQL actuelle (max_connections, idle_timeout)
- [ ] Vérifier la config Prisma actuelle (connection_limit, pool_timeout)
- [ ] Identifier si c'est lié aux pics de trafic

### Phase 2 : Configuration Prisma
- [ ] Ajouter `connection_limit` dans DATABASE_URL
- [ ] Ajouter `pool_timeout` et `connect_timeout`
- [ ] Configurer le retry logic
- [ ] Tester localement avec simulation de charge

### Phase 3 : Monitoring
- [ ] Ajouter des logs pour tracker les connexions
- [ ] Monitorer le nombre de connexions actives
- [ ] Vérifier les métriques PostgreSQL

### Phase 4 : Déploiement
- [ ] Appliquer la config en prod
- [ ] Monitorer pendant 48h
- [ ] Ajuster si nécessaire

## État d'avancement

**Statut : 📋 À faire**

Checklist :
- [ ] Diagnostic effectué
- [ ] Configuration Prisma optimisée
- [ ] Tests de charge
- [ ] Déployé en prod
- [ ] Monitoring 48h

## Commits liés

(À compléter)

## Notes futures

### Impact utilisateur
- **Gravité** : MOYEN ⚠️
- **Fréquence** : Sporadique (plusieurs fois par jour)
- **Depuis** : 3 novembre 2025
- **Users affectés** : Potentiellement tous (requêtes échouées)

### Logs d'erreur
```
2025-11-09T15:01:50.835192081Z prisma:error Error in PostgreSQL connection: 
Error { kind: Io, cause: Some(Os { code: 104, kind: ConnectionReset, message: "Connection reset by peer" }) }
```

### Configuration recommandée

**DATABASE_URL avec pool config** :
```bash
DATABASE_URL="postgresql://user:pass@host:5432/db?connection_limit=10&pool_timeout=20&connect_timeout=10"
```

**Dans schema.prisma** :
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

**Initialisation du client Prisma avec retry** :
```typescript
import { PrismaClient } from '@prisma/client'

export const prisma = new PrismaClient({
  log: ['error', 'warn'],
  errorFormat: 'pretty',
})

// Graceful shutdown
process.on('beforeExit', async () => {
  await prisma.$disconnect()
})
```

### Ressources
- [Prisma Connection Management](https://www.prisma.io/docs/guides/performance-and-optimization/connection-management)
- [PostgreSQL max_connections](https://www.postgresql.org/docs/current/runtime-config-connection.html)

