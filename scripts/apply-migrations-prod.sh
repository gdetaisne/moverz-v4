#!/bin/bash
# Script pour appliquer les migrations Prisma manquantes en production
# Task: t002 - Fix Analytics Table

set -e

echo "🔧 Application des migrations Prisma en production"
echo "=================================================="
echo ""

# Vérifier que DATABASE_URL est configuré
if [ -z "$DATABASE_URL" ]; then
    echo "❌ Erreur: DATABASE_URL non configuré"
    echo "Configurez-le avec la connexion à la DB production CapRover"
    exit 1
fi

echo "✅ DATABASE_URL configuré"
echo ""

# Afficher le statut actuel
echo "📊 Statut des migrations avant application:"
pnpm prisma migrate status || true
echo ""

# Appliquer les migrations
echo "🚀 Application des migrations..."
pnpm prisma migrate deploy

echo ""
echo "✅ Migrations appliquées avec succès!"
echo ""

# Vérifier le statut final
echo "📊 Statut final:"
pnpm prisma migrate status

echo ""
echo "🎉 Terminé!"
echo ""
echo "⚠️  N'oubliez pas de:"
echo "  1. Vérifier les logs CapRover (plus d'erreur P2021)"
echo "  2. Tester un événement analytics"
echo "  3. Vérifier la table: psql \$DATABASE_URL -c 'SELECT COUNT(*) FROM \"AnalyticsEvent\";'"

