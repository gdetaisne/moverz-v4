#!/bin/bash
# Script pour forcer le rebuild et déploiement sur CapRover
# Cela déclenchera automatiquement l'application des migrations via le Dockerfile

set -e

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║     🚀 DÉPLOIEMENT MOVERZ-V4 SUR CAPROVER + MIGRATIONS AUTO          ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# Variables
APP_NAME="moverz-v4"
CAPROVER_NAME="captain-01"

echo "📦 Application: $APP_NAME"
echo "🎯 CapRover: captain.gslv.cloud ($CAPROVER_NAME)"
echo ""

# Vérifier que les changements sont commitées
if [[ -n $(git status --porcelain) ]]; then
    echo "⚠️  Changements non commités détectés:"
    git status --short
    echo ""
    read -p "Voulez-vous commit et push automatiquement ? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add -A
        git commit -m "deploy: Force rebuild pour application migrations baseline"
        git push origin main
        echo "✅ Changements commités et pushés"
    else
        echo "❌ Annulé. Committez vos changements avant de déployer."
        exit 1
    fi
fi

echo "✅ Git est à jour"
echo ""

echo "🔧 Déploiement sur CapRover..."
echo ""
echo "⚠️  Note: Le CLI CapRover a des problèmes dans cet environnement."
echo "   Je vais te donner les instructions pour le faire via le Dashboard."
echo ""

cat <<'EOF'
┌────────────────────────────────────────────────────────────────────────┐
│ 📋 ÉTAPES À SUIVRE (Manuel - 2 minutes)                               │
└────────────────────────────────────────────────────────────────────────┘

1️⃣  Ouvrir le Dashboard CapRover :
   → https://captain.gslv.cloud/
   → Login: captain42

2️⃣  Aller dans l'app :
   → Apps → moverz-v4

3️⃣  Force Rebuild :
   → Onglet "Deployment"
   → Cliquer sur "Force Rebuild" (bouton rouge/orange)
   → Attendre le build (~3-5 minutes)

4️⃣  Surveiller les logs :
   → Pendant le build, onglet "App Logs"
   → Chercher ces lignes importantes :

   ✔ Generated Prisma Client (to ./node_modules/@prisma/client)
   Running migrate deploy...
   Applying migration `20251110145330_baseline`
   The following migration(s) have been applied:
   migrations/
     └─ 20251110145330_baseline/
   ✅ Migration success!
   Server is running on http://0.0.0.0:3001

┌────────────────────────────────────────────────────────────────────────┐
│ ✅ VÉRIFICATION POST-DÉPLOIEMENT                                       │
└────────────────────────────────────────────────────────────────────────┘

Dans les logs CapRover (App Logs) :

AVANT LE FIX:
  ❌ The table `public.AnalyticsEvent` does not exist
  ❌ Code: P2021

APRÈS LE FIX:
  ✅ Plus d'erreur P2021
  ✅ Table AnalyticsEvent créée avec succès

EOF

echo ""
echo "🎯 Prêt pour le déploiement manuel !"
echo ""
echo "Une fois le Force Rebuild terminé, reviens me voir pour vérifier que tout fonctionne."

