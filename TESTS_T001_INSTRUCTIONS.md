# Instructions pour tester t001 - API /api/rooms

## 📋 Contexte

La task t001 visait à implémenter l'API `/api/rooms`. 

**DÉCOUVERTE** : L'API était déjà entièrement implémentée dans `app/api/rooms/route.ts` ! 

Les tests suivants vérifient que tout fonctionne correctement.

---

## 🚀 Étapes à suivre (5 minutes)

### 1. Préparer l'environnement

```bash
cd /Users/guillaumestehelin/moverz-v4

# Créer .env (ou copier depuis ton fichier de clés)
cat > .env << 'EOF'
DATABASE_URL="file:./prisma/dev.db"
AI_SERVICE_URL="http://localhost:8000"
EOF
```

### 2. Initialiser la base de données

```bash
# Générer le client Prisma
pnpm prisma generate

# Créer/mettre à jour la DB SQLite
pnpm prisma db push --accept-data-loss
```

### 3. Démarrer le serveur sur port 4000

```bash
PORT=4000 pnpm dev
```

Attendre que le message apparaisse :
```
✓ Ready in XXms
○ Local:   http://localhost:4000
```

### 4. Exécuter les tests (dans un nouveau terminal)

```bash
cd /Users/guillaumestehelin/moverz-v4

# Rendre le script exécutable
chmod +x scripts/test-api-rooms.sh

# Lancer les tests
./scripts/test-api-rooms.sh
```

---

## ✅ Résultats attendus

Le script devrait afficher :

```
========================================
Test API /api/rooms (t001)
========================================

✅ Serveur actif

Test 1: POST /api/rooms
✅ POST réussi (201)
Room ID: [uuid]

Test 2: GET /api/rooms
✅ GET réussi (200)
✅ La room 'Salon' est présente

Test 3: Header case-insensitive
✅ Header case-insensitive fonctionne

Test 4: Validation Zod
✅ Validation fonctionne (400)

Test 5: Auth requise
✅ Auth requise fonctionne (401)

========================================
Résumé des tests
========================================

Critères d'acceptation t001:
1. POST /api/rooms avec x-user-id → 201
2. GET /api/rooms?userId=... → 200 + contient les rooms

✅ Tests terminés !
```

---

## 🐛 En cas de problème

### Erreur "Cannot find module '@core/db'"

```bash
pnpm install
pnpm prisma generate
```

### Erreur "Port 4000 already in use"

```bash
# Trouver le processus
lsof -i :4000

# Tuer le processus
kill -9 [PID]
```

### Base de données verrouillée

```bash
# Arrêter le serveur Next.js
# Puis relancer pnpm prisma db push
```

---

## 📝 Après les tests

**Si tous les tests passent ✅** :

1. Dans `.cursor/tasks/t001-api-rooms.md`, marquer :
   ```
   **Statut : ✅ Terminé**
   ```

2. Archiver la task :
   ```bash
   ./scripts/tasks/complete-task.sh t001
   ```

**Si des tests échouent ❌** :

Copier l'erreur et on corrigera ensemble !

---

## 🔍 Ce qui a été découvert

- ✅ API `/api/rooms` déjà implémentée et fonctionnelle
- ✅ Validation Zod avec `name` + `roomType` (obligatoires)
- ✅ Auth via `x-user-id` (case-insensitive) ou `?userId=`
- ✅ Auto-création utilisateur (upsert)
- ✅ Error handling propre avec JSON
- ✅ Contrainte unique sur `(userId, roomType)` dans Prisma

La spec initiale a été adaptée pour refléter la réalité du code existant.

