# Structure du projet Moverz v4

## Arborescence

```
moverz-v4/
├── .cursor/                        # Système de tasks et traçabilité
│   ├── README.md                   # Documentation structure .cursor
│   ├── tasks/                      # Tasks actives
│   │   ├── tXXX-type-details.md   # Spec de task
│   │   └── commits/                # Historique des commits
│   │       └── tXXX.md            # Journal commits par task
│   └── task_archives/              # Tasks terminées
│       └── tXXX-type-details.md   # Task archivée
│
├── docs/                           # Documentation projet
│   ├── CURSOR_LOAD.md             # Instructions de chargement Cursor (9 règles)
│   ├── CONTEXT.md                 # Vision et contexte business Moverz
│   ├── TASKS_RULES.md             # Règles de gestion des tasks
│   ├── STRUCTURE.md               # Ce fichier
│   ├── architecture/              # Documentation architecture
│   ├── deployment/                # Documentation déploiement
│   └── getting-started/           # Guide démarrage
│
├── scripts/                        # Scripts d'automatisation
│   └── tasks/                     # Gestion des tasks
│       ├── README.md
│       └── complete-task.sh       # Archivage automatique
│
├── app/                            # Next.js App Router
│   ├── api/                       # API routes
│   └── [pages]/                   # Pages Next.js
│
├── components/                     # React components
├── lib/                           # Utilities & services
├── services/                      # Business logic services
├── prisma/                        # Database schema & migrations
├── packages/                      # Monorepo packages
│   ├── ai/                        # AI services
│   ├── core/                      # Core utilities
│   └── ui/                        # UI components
└── [config files]                 # Config à la racine
```

## Dossiers principaux

### `.cursor/`
Contient le système de gestion des tasks et la traçabilité complète.

**Métadonnées uniquement, pas d'exécutables.**

- `tasks/` : Tasks actives en cours de travail
- `task_archives/` : Archive des tasks terminées
- `tasks/commits/` : Historique détaillé de tous les commits

### `scripts/`
Scripts d'automatisation du projet.

**Séparé de `.cursor/`** pour respecter le principe : `.cursor/` = données, `/scripts` = exécutables.

- `tasks/` : Scripts de gestion des tasks (complete-task.sh)

### `docs/`
Documentation générale du projet, règles et conventions.

**Fichiers clés** :
- `CURSOR_LOAD.md` : À lire en début de session
- `CONTEXT.md` : Vision business Moverz
- `TASKS_RULES.md` : Workflow strict des tasks

### `app/`
Next.js App Router avec API routes

### `packages/`
Monorepo structure :
- `ai/` : Services d'intelligence artificielle
- `core/` : Utilitaires core partagés
- `ui/` : Composants UI partagés

## Workflow

### Démarrage session
```bash
# 1. Lire la documentation
cat docs/CURSOR_LOAD.md

# 2. Lister les tasks actives
ls -la .cursor/tasks/*.md

# 3. Ouvrir la task concernée
cat .cursor/tasks/tXXX-type-details.md
```

### Créer une nouvelle task
```bash
# Créer dans .cursor/tasks/
nano .cursor/tasks/t001-feature-example.md

# Créer le journal de commits
nano .cursor/tasks/commits/t001.md
```

### Archiver une task terminée

**Méthode automatique (recommandée)** :
```bash
# Utiliser le script d'archivage
./scripts/tasks/complete-task.sh tXXX
```

Le script automatise :
- Vérification du statut "Terminé"
- Archivage dans task_archives
- Création du commit
- Mise à jour du journal

**Méthode manuelle** :
```bash
# Déplacer la task
mv .cursor/tasks/tXXX-type-details.md .cursor/task_archives/

# Le journal de commits reste dans tasks/commits/
```

## Principes

1. **Traçabilité totale** : Tout changement est documenté dans une task
2. **Indépendance** : `.cursor/tasks` est lisible sans le code source
3. **Périmètre strict** : Une task = un périmètre défini
4. **Archivage** : Les tasks terminées sont archivées, pas supprimées
5. **Commits liés** : Chaque commit est tracé dans son fichier `.cursor/tasks/commits/tXXX.md`

