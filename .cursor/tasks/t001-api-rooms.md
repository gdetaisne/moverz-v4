# t001 — Implémentation de l'API /api/rooms avec authentification dev

## Contexte

Le projet moverz-v4 nécessite une API fonctionnelle pour gérer les "rooms" (pièces/espaces de déménagement). L'application utilise actuellement Next.js avec des API routes, mais une migration vers Express sur port 3001 est prévue.

Pour l'instant, nous devons rendre l'API `/api/rooms` fonctionnelle avec :
- Authentification simple par `x-user-id` (dev)
- Routes POST et GET
- Validation avec Zod
- Base de données Prisma (PostgreSQL)

## Objectifs

1. ✅ Implémenter POST `/api/rooms` pour créer une room
2. ✅ Implémenter GET `/api/rooms` pour lister les rooms d'un utilisateur
3. ✅ Ajouter middleware d'authentification simple (x-user-id)
4. ✅ Valider les données avec Zod
5. ✅ Gérer les erreurs proprement (JSON + logging)
6. ✅ Vérifier avec curl que tout fonctionne

## Périmètre

### Fichiers à créer/modifier
- `/app/api/rooms/route.ts` : Handlers POST et GET
- `/lib/schemas.ts` : Schéma Zod pour validation (ou nouveau fichier)
- `/middleware.ts` (ou équivalent) : Middleware auth dev
- `/prisma/schema.prisma` : Vérifier/ajouter le modèle Room si absent

### Spécifications techniques

#### Auth middleware
- Accepter header `x-user-id` (case-insensitive)
- En DEV, accepter aussi query param `?userId=`
- Attacher `req.userId` au request
- Appliquer sur toutes les routes `/api/*`

#### POST /api/rooms
- Body : `{ name: string }` (min 1 caractère)
- Validation Zod
- Créer via Prisma : `{ name, userId }`
- Retour : 201 + JSON de la room créée

#### GET /api/rooms
- Query param : `userId` (requis en dev)
- Lister toutes les rooms de cet userId
- Retour : 200 + array JSON

#### Error handling
- Handler global qui retourne JSON `{ message }`
- Logger la stack en dev
- Ne jamais faire planter le process

### Hors périmètre
- Backend Express standalone (prévu plus tard)
- JWT/Auth production
- Optimisations avancées

## Implémentation

### Phase 1 : Analyse de l'existant
- [ ] Vérifier si le modèle Room existe dans schema.prisma
- [ ] Vérifier l'état actuel de /app/api/rooms/route.ts
- [ ] Identifier les fichiers de validation existants
- [ ] Identifier le système d'auth actuel

### Phase 2 : Schéma Prisma
- [ ] Ajouter/vérifier le modèle Room avec userId
- [ ] Créer la migration si nécessaire
- [ ] Appliquer la migration

### Phase 3 : Validation Zod
- [ ] Créer le schéma Zod pour createRoom
- [ ] Valider dans le handler POST

### Phase 4 : Routes API
- [ ] Implémenter POST /api/rooms
- [ ] Implémenter GET /api/rooms
- [ ] Ajouter error handling

### Phase 5 : Middleware Auth
- [ ] Créer/adapter le middleware auth dev
- [ ] Tester avec x-user-id

### Phase 6 : Tests
- [ ] Test curl POST avec x-user-id
- [ ] Test curl GET avec userId
- [ ] Vérifier les retours 201 et 200
- [ ] Vérifier la structure JSON

## État d'avancement

**Statut : 🔄 En cours**

Checklist :
- [ ] Analyse existant
- [ ] Schéma Prisma
- [ ] Validation Zod
- [ ] Routes API
- [ ] Middleware Auth
- [ ] Tests curl

## Commits liés

(À compléter au fur et à mesure)

## Notes futures

### Critères d'acceptation (must)
1. `curl -sS -X POST http://localhost:3001/api/rooms -H "content-type: application/json" -H "x-user-id: test-user-123" -d '{"name":"Salon"}' → 201`
2. `curl -sS "http://localhost:3001/api/rooms?userId=test-user-123" → 200` et contient "Salon"

### Points à documenter
- Architecture middleware choisie
- Structure de validation Zod
- Pattern error handling retenu

### Tasks futures identifiées
- Migration vers Express standalone (t002 ?)
- Authentification JWT production (t003 ?)
- Tests automatisés (t004 ?)

