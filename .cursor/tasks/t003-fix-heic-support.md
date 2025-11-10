# t003 — Fix: Support format HEIC pour photos iPhone

## Contexte

Les photos au format HEIC (format par défaut iPhone) ne sont pas traitées en production. Erreur récurrente depuis le 3 novembre :

```
heif: Error while loading plugin: Support for this compression format has not been built in (11.6003)
source: bad seek to [various positions]
```

**Conséquence** : Les photos sont sauvegardées mais l'analyse retourne "pièce inconnue" avec confiance 0.1.

## Objectifs

1. Ajouter le support HEIC dans l'image Docker de production
2. Vérifier que Sharp peut traiter les fichiers HEIC
3. Tester avec de vraies photos iPhone
4. S'assurer de la conversion HEIC → JPEG pour l'IA

## Périmètre

### Fichiers à modifier
- `Dockerfile` : Ajouter libheif et dépendances
- `Dockerfile.worker` (si existe) : Même chose
- `lib/imageUtils.ts` ou équivalent : Vérifier la conversion
- Tests de validation

### Technologies impliquées
- **Sharp** : Bibliothèque de traitement d'images Node.js
- **libheif** : Décodeur HEIC/HEIF
- **Docker** : Image de production

### Hors périmètre
- Conversion côté client (reste côté serveur)
- Support d'autres formats exotiques
- Optimisation de la taille d'image

## Implémentation

### Phase 1 : Recherche solution
- [ ] Vérifier la version de Sharp installée
- [ ] Identifier les packages système nécessaires pour HEIC
- [ ] Consulter la doc Sharp pour HEIC support
- [ ] Vérifier si libheif est disponible dans Alpine Linux

### Phase 2 : Modification Dockerfile
- [ ] Ajouter `libheif` et `libheif-dev` dans les dépendances
- [ ] Rebuilder l'image Docker localement
- [ ] Tester avec un fichier HEIC

### Phase 3 : Tests
- [ ] Uploader une photo HEIC en local
- [ ] Vérifier la conversion HEIC → JPEG
- [ ] Tester l'analyse IA sur HEIC
- [ ] Vérifier les logs (plus d'erreur "bad seek")

### Phase 4 : Déploiement
- [ ] Commiter les changements Dockerfile
- [ ] Redéployer sur CapRover
- [ ] Tester en prod avec photo iPhone
- [ ] Monitorer les logs

## État d'avancement

**Statut : 📋 À faire**

Checklist :
- [ ] Recherche solution
- [ ] Dockerfile modifié
- [ ] Tests locaux
- [ ] Déployé en prod
- [ ] Vérifié en prod

## Commits liés

(À compléter)

## Notes futures

### Impact utilisateur
- **Gravité** : CRITIQUE ⚠️ (utilisateurs iPhone impactés)
- **Fréquence** : À chaque photo HEIC uploadée
- **Depuis** : 3 novembre 2025
- **Users affectés** : Tous les utilisateurs iPhone (majorité)

### Logs d'erreur
```
2025-11-03T14:19:59.658209511Z Erreur lors de la détection de pièce: Error: source: bad seek to 2311142
heif: Error while loading plugin: Support for this compression format has not been built in (11.6003)
✅ [TIMING] Détection pièce IA: 580ms - Type: pièce inconnue, Confiance: 0.1
```

### Solution technique probable

**Dockerfile (Alpine)** :
```dockerfile
# Ajouter avant l'installation des dépendances Node
RUN apk add --no-cache \
    libheif \
    libheif-dev \
    libde265 \
    x265
```

**Dockerfile (Debian/Ubuntu)** :
```dockerfile
RUN apt-get update && apt-get install -y \
    libheif-dev \
    libheif1
```

### Ressources
- [Sharp HEIC support](https://sharp.pixelplumbing.com/install#heif)
- [libheif GitHub](https://github.com/strukturag/libheif)

