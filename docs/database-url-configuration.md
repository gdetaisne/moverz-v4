# Configuration DATABASE_URL pour résoudre "Connection reset by peer"

## 🎯 Objectif

Ajouter les paramètres de connection pooling à l'URL PostgreSQL pour résoudre les erreurs de connexion.

## 📋 Variables CapRover à modifier

### 1. DATABASE_URL (actuelle)

**Avant :**
```
postgresql://monitoring:monitoring123@srv-captain--postgres-monitoring:5432/monitoring
```

**Après (à configurer sur CapRover) :**
```
postgresql://monitoring:monitoring123@srv-captain--postgres-monitoring:5432/monitoring?connection_limit=10&pool_timeout=20&connect_timeout=15&socket_timeout=60
```

### 2. DIRECT_URL (à ajouter si manquante)

**Valeur :**
```
postgresql://monitoring:monitoring123@srv-captain--postgres-monitoring:5432/monitoring?connection_limit=10&connect_timeout=15
```

## 🔧 Paramètres expliqués

### connection_limit=10
- **Rôle** : Nombre maximum de connexions simultanées par instance Prisma
- **Pourquoi** : Évite de saturer PostgreSQL (défaut: 100 connexions max)
- **Valeur** : 10 est un bon compromis pour une app Next.js

### pool_timeout=20
- **Rôle** : Temps max (secondes) pour attendre une connexion disponible du pool
- **Pourquoi** : Évite les blocages si toutes les connexions sont occupées
- **Valeur** : 20 secondes laisse le temps aux requêtes de se terminer

### connect_timeout=15
- **Rôle** : Temps max (secondes) pour établir une nouvelle connexion
- **Pourquoi** : Évite les blocages réseau prolongés
- **Valeur** : 15 secondes est suffisant pour PostgreSQL local (CapRover)

### socket_timeout=60
- **Rôle** : Temps max (secondes) avant de considérer une connexion idle comme morte
- **Pourquoi** : PostgreSQL ferme les connexions idle après un certain temps
- **Valeur** : 60 secondes permet des requêtes longues (analyse IA)

## 📍 Comment appliquer sur CapRover

### Option A : Via Dashboard (Recommandé)

1. **Connexion** : https://captain.gslv.cloud/ (MDP: `captain42`)
2. **Navigation** : Apps → `moverz-v4` (ou `movers-test`)
3. **Configuration** : App Configs → Environment Variables
4. **Modifier DATABASE_URL** :
   - Cliquer sur l'icône ✏️ à côté de `DATABASE_URL`
   - Remplacer par la nouvelle valeur avec paramètres
   - Cliquer sur "Update"
5. **Ajouter DIRECT_URL** (si manquante) :
   - Cliquer sur "Add new env variable"
   - Key: `DIRECT_URL`
   - Value: (voir valeur ci-dessus)
   - Cliquer sur "Add"
6. **Redémarrer** : Cliquer sur "Save & Update" en haut à droite

### Option B : Via CLI (Alternative)

```bash
# Installer CLI si nécessaire
npm install -g caprover

# Login
caprover login

# Configurer les variables
caprover env:set DATABASE_URL="postgresql://monitoring:monitoring123@srv-captain--postgres-monitoring:5432/monitoring?connection_limit=10&pool_timeout=20&connect_timeout=15&socket_timeout=60" -a moverz-v4

caprover env:set DIRECT_URL="postgresql://monitoring:monitoring123@srv-captain--postgres-monitoring:5432/monitoring?connection_limit=10&connect_timeout=15" -a moverz-v4
```

## ✅ Vérification après déploiement

### Logs à surveiller

**Signes positifs :**
```
✅ Database connections closed (lors du shutdown)
✅ Plus d'erreur "Connection reset by peer"
✅ Requêtes DB répondent normalement
```

**Signes d'alerte :**
```
❌ Connection reset by peer (erreur persiste)
❌ Timeout waiting for connection from pool
❌ Too many connections (augmenter max_connections PostgreSQL)
```

### Test rapide

```bash
# Via logs CapRover
curl -sS https://movers-test.gslv.cloud/inventaire-ia/api/ai-status

# Devrait répondre sans erreur
```

## 🔄 Rollback si problème

Si les nouvelles valeurs causent des problèmes, revenir à l'ancienne configuration :

```
DATABASE_URL=postgresql://monitoring:monitoring123@srv-captain--postgres-monitoring:5432/monitoring
```

Et supprimer `DIRECT_URL`.

## 📚 Ressources

- [Prisma Connection Management](https://www.prisma.io/docs/guides/performance-and-optimization/connection-management)
- [PostgreSQL Connection Pooling](https://www.postgresql.org/docs/current/runtime-config-connection.html)

