# t005 — Config: Ajouter ADMIN_BYPASS_TOKEN manquant

## Contexte

Logs récents (10 novembre) montrent que la variable d'environnement `ADMIN_BYPASS_TOKEN` n'est pas configurée en production :

```
[Admin Auth] ADMIN_BYPASS_TOKEN non configuré
```

Cette variable est nécessaire pour accéder aux fonctionnalités admin sans authentification complète (mode bypass pour debugging/ops).

## Objectifs

1. Identifier où `ADMIN_BYPASS_TOKEN` est utilisé dans le code
2. Générer un token sécurisé
3. Ajouter la variable dans CapRover
4. Documenter son usage

## Périmètre

### Fichiers concernés
- Middleware admin (à identifier)
- Configuration CapRover (variables d'environnement)
- Documentation

### Actions à réaliser
1. Rechercher l'usage de `ADMIN_BYPASS_TOKEN` dans le code
2. Comprendre son rôle exact
3. Générer un token fort
4. L'ajouter dans les env vars CapRover
5. Tester l'accès admin

### Hors périmètre
- Refactoring complet du système d'auth admin
- Ajout d'autres tokens
- Migration vers JWT admin

## Implémentation

### Phase 1 : Analyse
- [ ] Rechercher `ADMIN_BYPASS_TOKEN` dans le codebase
- [ ] Identifier les routes/middlewares qui l'utilisent
- [ ] Comprendre les cas d'usage (debug, ops, tests)
- [ ] Vérifier si c'est critique ou optionnel

### Phase 2 : Génération token
- [ ] Générer un token sécurisé (32+ caractères)
- [ ] Utiliser un générateur cryptographique
- [ ] Le sauvegarder dans un gestionnaire de secrets

### Phase 3 : Configuration
- [ ] Ajouter dans CapRover App Config > Env Variables
- [ ] Redémarrer l'app
- [ ] Vérifier les logs (plus de warning)

### Phase 4 : Documentation
- [ ] Documenter le token dans le README ou docs/
- [ ] Ajouter dans le template .env.example
- [ ] Expliquer quand l'utiliser

## État d'avancement

**Statut : 📋 À faire**

Checklist :
- [ ] Usage identifié
- [ ] Token généré
- [ ] Ajouté dans CapRover
- [ ] Testé
- [ ] Documenté

## Commits liés

(À compléter)

## Notes futures

### Impact utilisateur
- **Gravité** : MINEUR ℹ️
- **Fréquence** : À chaque requête admin sans auth
- **Depuis** : 10 novembre 2025
- **Users affectés** : Équipe admin/ops uniquement

### Logs d'erreur
```
2025-11-10T03:50:40.552966871Z [Admin Auth] ADMIN_BYPASS_TOKEN non configuré
2025-11-10T03:50:40.569823702Z [Admin Auth] ADMIN_BYPASS_TOKEN non configuré
2025-11-10T03:50:40.584253167Z [Admin Auth] ADMIN_BYPASS_TOKEN non configuré
```

### Génération token sécurisé

```bash
# Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# OpenSSL
openssl rand -hex 32

# Python
python3 -c "import secrets; print(secrets.token_hex(32))"
```

### Configuration CapRover

1. CapRover Dashboard
2. Apps > moverz-v4
3. App Configs > Environment Variables
4. Ajouter :
   ```
   ADMIN_BYPASS_TOKEN=<token_généré>
   ```
5. Save & Update
6. Restart app

### Usage probable dans le code

```typescript
// Middleware admin auth
const bypass = req.headers.get('x-admin-token')
if (bypass === process.env.ADMIN_BYPASS_TOKEN) {
  return next() // Bypass auth
}
// Sinon, auth normale
```

