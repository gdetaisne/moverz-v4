# 🚀 Guide de Déploiement CapRover - t002

## ✅ Situation actuelle

- ✅ Migration baseline créée : `20251110145330_baseline`
- ✅ Code commité et pushé sur GitHub (commit `dee5803`)
- ✅ Dockerfile configuré pour appliquer les migrations automatiquement
- ⏳ **Action requise : Force Rebuild sur CapRover**

---

## 📋 Instructions Pas-à-Pas

### Étape 1 : Ouvrir CapRover Dashboard

1. Ouvre ton navigateur
2. Va sur : **https://captain.gslv.cloud/**
3. Entre le mot de passe : `captain42`
4. Clique sur "Login"

### Étape 2 : Accéder à l'app moverz-v4

1. Dans le menu de gauche, clique sur **"Apps"**
2. Dans la liste, trouve et clique sur **"moverz-v4"**

### Étape 3 : Lancer le Force Rebuild

1. En haut de la page, tu verras plusieurs onglets : **App Configs, Deployment, HTTP Settings, App Logs**
2. Clique sur l'onglet **"Deployment"**
3. Tu verras une section avec :
   - Method: Choose from GitHub, GitLab, etc.
   - Branch: (probablement `main`)
4. Cherche le bouton **"Force Rebuild"** (il est généralement orange ou rouge)
5. **Clique sur "Force Rebuild"**
6. Une confirmation apparaîtra → Confirme

### Étape 4 : Surveiller le build

1. Le build va commencer (durée estimée : 3-5 minutes)
2. Clique sur l'onglet **"App Logs"** pour voir les logs en temps réel
3. Cherche les lignes importantes :

```
Step X/Y : RUN npx prisma generate
✔ Generated Prisma Client (to ./node_modules/@prisma/client)

...

sh -c npx prisma migrate deploy || echo 'Migration warning'; node server.js
Prisma schema loaded from prisma/schema.prisma
Datasource "db": PostgreSQL database "monitoring", schema "public" at "..."

Applying migration `20251110145330_baseline`

The following migration(s) have been applied:

migrations/
  └─ 20251110145330_baseline/
    └─ migration.sql

Your database is now in sync with your schema.

✅ Server is running on http://0.0.0.0:3001
```

### Étape 5 : Vérifier que l'erreur P2021 a disparu

1. Reste dans l'onglet **"App Logs"**
2. Laisse les logs défiler pendant 1-2 minutes
3. Vérifie qu'il n'y a **PLUS** cette erreur :

```
❌ AVANT (erreur) :
Invalid `prisma.analyticsEvent.create()` invocation:
The table `public.AnalyticsEvent` does not exist in the current database.
Code: P2021
```

4. Si tu ne vois plus cette erreur → **✅ C'est réussi !**

---

## ✅ Vérification finale

Si tu veux être sûr à 100% que la table existe :

1. Dans CapRover, va dans **"One-Click Apps/Databases"**
2. Trouve ton PostgreSQL
3. Ouvre un terminal PostgreSQL (si disponible)
4. Exécute :

```sql
\dt AnalyticsEvent
```

Tu devrais voir :

```
         List of relations
 Schema |      Name        | Type  |  Owner
--------+------------------+-------+----------
 public | AnalyticsEvent   | table | monitoring
```

---

## 🆘 En cas de problème

### Problème 1 : Je ne trouve pas le bouton "Force Rebuild"

**Solution :** 
- Vérifie que tu es bien dans l'onglet "Deployment"
- Le bouton peut s'appeler "Trigger Build" ou "Redeploy"
- Prends une capture d'écran et montre-moi

### Problème 2 : Le build échoue

**Solution :**
- Copie les dernières lignes des logs (les lignes en rouge)
- Colle-les ici et je t'aiderai à débugger

### Problème 3 : L'erreur P2021 persiste après le déploiement

**Solution :**
- Copie-colle les logs complets du démarrage
- Vérifie que la ligne "Applying migration `20251110145330_baseline`" apparaît bien
- Si elle n'apparaît pas, il y a peut-être un problème de DATABASE_URL

### Problème 4 : "Migration already applied"

**Ce n'est PAS une erreur !**
- Si Prisma dit que la migration est déjà appliquée, c'est parfait
- Ça veut dire que tout est déjà à jour

---

## 📞 Prêt ?

Une fois que tu as fait le Force Rebuild et vérifié les logs :

**Reviens me dire :**
- ✅ "C'est bon, plus d'erreur P2021 !"
- ❌ "J'ai une erreur : [colle les logs]"
- ❓ "Je suis bloqué à l'étape X"

Je suis là pour t'aider ! 😊

