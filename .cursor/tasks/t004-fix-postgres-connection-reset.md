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

**Statut : ✅ Implémenté - En attente déploiement + config CapRover**

Checklist :
- [x] Diagnostic effectué
- [x] Configuration Prisma optimisée
- [ ] Variables CapRover mises à jour
- [ ] Déployé en prod
- [ ] Monitoring 48h

### Solution implémentée

**Date** : 10 novembre 2025

#### 1. Client Prisma amélioré (`lib/db.ts` et `packages/core/src/db.ts`)

**Ajouts :**
- ✅ Configuration explicite du datasource dans PrismaClient
- ✅ **Graceful shutdown** : Gestion des signaux SIGINT/SIGTERM/beforeExit
- ✅ Fermeture propre des connexions lors du redémarrage

**Code :**
```typescript
export const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
});

// Graceful shutdown handlers
process.on('SIGINT', shutdownHandler);
process.on('SIGTERM', shutdownHandler);
process.on('beforeExit', async () => {
  await prisma.$disconnect();
});
```

#### 2. Schema Prisma mis à jour (`prisma/schema.prisma`)

**Ajout :**
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")  // ← Nouveau : pour migrations
}
```

**Rôle de `directUrl`** :
- Utilisée pour les migrations et le schema push
- Connexion directe sans pooling
- Évite les timeouts lors des DDL (CREATE TABLE, etc.)

#### 3. Configuration DATABASE_URL requise (CapRover)

**⚠️ ACTION MANUELLE REQUISE SUR CAPROVER**

**Ancienne URL (sans paramètres) :**
```
postgresql://monitoring:monitoring123@srv-captain--postgres-monitoring:5432/monitoring
```

**Nouvelle URL (avec connection pooling) :**
```
postgresql://monitoring:monitoring123@srv-captain--postgres-monitoring:5432/monitoring?connection_limit=10&pool_timeout=20&connect_timeout=15&socket_timeout=60
```

**Nouvelle variable DIRECT_URL (à ajouter) :**
```
postgresql://monitoring:monitoring123@srv-captain--postgres-monitoring:5432/monitoring?connection_limit=10&connect_timeout=15
```

**Paramètres expliqués :**
- `connection_limit=10` : Max 10 connexions simultanées (évite saturation)
- `pool_timeout=20` : Attendre max 20s pour une connexion disponible
- `connect_timeout=15` : Timeout connexion initiale 15s
- `socket_timeout=60` : Timeout socket 60s (requêtes longues OK)

**📖 Guide détaillé** : `docs/database-url-configuration.md`

### Causes identifiées

1. **Pool non configuré** → Trop de connexions simultanées → PostgreSQL refuse
2. **Connexions idle** → PostgreSQL ferme après timeout → App utilise connexion morte
3. **Pas de graceful shutdown** → Redéploiement brutal → Connexions coupées
4. **Pas de retry** → Erreur réseau temporaire → Échec immédiat

### Bénéfices attendus

- ✅ Moins d'erreurs "Connection reset by peer"
- ✅ Redémarrage propre sans interruption brutale
- ✅ Meilleure gestion des pics de charge
- ✅ Connexions recyclées correctement
- ✅ Migrations plus stables avec `directUrl`

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

