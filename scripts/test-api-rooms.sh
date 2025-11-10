#!/bin/bash
# Script de test pour t001 - API /api/rooms
# Usage: ./scripts/test-api-rooms.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

API_BASE="http://localhost:4000"
TEST_USER="test-user-123"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test API /api/rooms (t001)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Vérifier que le serveur tourne
echo -e "${YELLOW}Vérification serveur...${NC}"
if ! curl -s -f "${API_BASE}" > /dev/null 2>&1; then
    echo -e "${RED}❌ Serveur non accessible sur ${API_BASE}${NC}"
    echo ""
    echo "Démarrez le serveur avec:"
    echo "  PORT=4000 pnpm dev"
    exit 1
fi
echo -e "${GREEN}✅ Serveur actif${NC}"
echo ""

# Test 1: POST /api/rooms
echo -e "${BLUE}Test 1: POST /api/rooms${NC}"
echo "Création d'une room 'Salon'..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${API_BASE}/api/rooms" \
  -H "content-type: application/json" \
  -H "x-user-id: ${TEST_USER}" \
  -d '{"name":"Salon","roomType":"living_room"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Status: $HTTP_CODE"
echo "Response: $BODY"

if [ "$HTTP_CODE" = "201" ]; then
    echo -e "${GREEN}✅ POST réussi (201)${NC}"
    ROOM_ID=$(echo "$BODY" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    echo "Room ID: $ROOM_ID"
else
    echo -e "${RED}❌ POST échoué (attendu 201, reçu $HTTP_CODE)${NC}"
fi
echo ""

# Test 2: GET /api/rooms
echo -e "${BLUE}Test 2: GET /api/rooms${NC}"
echo "Récupération des rooms de l'utilisateur..."

RESPONSE=$(curl -s -w "\n%{http_code}" "${API_BASE}/api/rooms?userId=${TEST_USER}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Status: $HTTP_CODE"
echo "Response: $BODY"

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ GET réussi (200)${NC}"
    
    # Vérifier que "Salon" est dans la réponse
    if echo "$BODY" | grep -q "Salon"; then
        echo -e "${GREEN}✅ La room 'Salon' est présente${NC}"
    else
        echo -e "${RED}❌ La room 'Salon' n'est pas trouvée${NC}"
    fi
else
    echo -e "${RED}❌ GET échoué (attendu 200, reçu $HTTP_CODE)${NC}"
fi
echo ""

# Test 3: POST avec x-user-id en majuscules (case-insensitive)
echo -e "${BLUE}Test 3: Header case-insensitive${NC}"
echo "Test avec X-User-Id (majuscules)..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${API_BASE}/api/rooms" \
  -H "content-type: application/json" \
  -H "X-User-Id: ${TEST_USER}" \
  -d '{"name":"Cuisine","roomType":"kitchen"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "201" ]; then
    echo -e "${GREEN}✅ Header case-insensitive fonctionne${NC}"
else
    echo -e "${RED}❌ Header case-insensitive échoué${NC}"
fi
echo ""

# Test 4: Validation Zod (champ manquant)
echo -e "${BLUE}Test 4: Validation Zod${NC}"
echo "Test sans roomType (doit échouer)..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${API_BASE}/api/rooms" \
  -H "content-type: application/json" \
  -H "x-user-id: ${TEST_USER}" \
  -d '{"name":"Chambre"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "400" ]; then
    echo -e "${GREEN}✅ Validation fonctionne (400)${NC}"
    echo "Message: $BODY"
else
    echo -e "${RED}❌ Validation devrait retourner 400, reçu $HTTP_CODE${NC}"
fi
echo ""

# Test 5: Auth manquante
echo -e "${BLUE}Test 5: Auth requise${NC}"
echo "Test sans x-user-id (doit échouer)..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${API_BASE}/api/rooms" \
  -H "content-type: application/json" \
  -d '{"name":"Bureau","roomType":"office"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "401" ]; then
    echo -e "${GREEN}✅ Auth requise fonctionne (401)${NC}"
else
    echo -e "${RED}❌ Auth devrait retourner 401, reçu $HTTP_CODE${NC}"
fi
echo ""

# Résumé
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Résumé des tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Critères d'acceptation t001:"
echo "1. POST /api/rooms avec x-user-id → 201"
echo "2. GET /api/rooms?userId=... → 200 + contient les rooms"
echo ""
echo -e "${GREEN}Tests terminés !${NC}"

