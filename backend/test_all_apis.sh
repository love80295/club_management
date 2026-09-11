#!/bin/bash

BASE_URL="http://127.0.0.1:8000/api"

echo "═══════════════════════════════════════════════════════════"
echo "🧪 CAMPUS CONNECT - API TESTING"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════════════════
# TEST 1: LOGIN
# ═══════════════════════════════════════════════════════════
echo "📝 TEST 1: Login"
echo "─────────────────────────────────────────────────────────"

LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login/" \
  -H "Content-Type: application/json" \
  -d '{"username": "love", "password": "1234"}')

echo "$LOGIN_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$LOGIN_RESPONSE"

TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('access', ''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo ""
    echo "❌ Login failed!"
    exit 1
fi

echo ""
echo "✅ Login successful!"
echo "🔑 Token: ${TOKEN:0:50}..."
echo ""

# ═══════════════════════════════════════════════════════════
# TEST 2: GET PROFILE
# ═══════════════════════════════════════════════════════════
echo "📝 TEST 2: Get User Profile"
echo "─────────────────────────────────────────────────────────"
curl -s -X GET "$BASE_URL/auth/profile/" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
echo ""

# ═══════════════════════════════════════════════════════════
# TEST 3: GET ALL CLUBS
# ═══════════════════════════════════════════════════════════
echo "📝 TEST 3: Get All Clubs"
echo "─────────────────────────────────────────────────────────"
curl -s -X GET "$BASE_URL/clubs/" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
echo ""

# ═══════════════════════════════════════════════════════════
# TEST 4: GET ALL EVENTS
# ═══════════════════════════════════════════════════════════
echo "📝 TEST 4: Get All Events"
echo "─────────────────────────────────────────────────────────"
curl -s -X GET "$BASE_URL/events/" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
echo ""

# ═══════════════════════════════════════════════════════════
# TEST 5: GET ALL USERS (Admin only)
# ═══════════════════════════════════════════════════════════
echo "📝 TEST 5: Get All Users (Admin only)"
echo "─────────────────────────────────────────────────────────"
curl -s -X GET "$BASE_URL/auth/users/" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
echo ""

# ═══════════════════════════════════════════════════════════
# TEST 6: GET MY REGISTRATIONS
# ═══════════════════════════════════════════════════════════
echo "📝 TEST 6: Get My Registrations"
echo "─────────────────────────────────────────────────────────"
curl -s -X GET "$BASE_URL/registrations/" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "✅ ALL API TESTS COMPLETED"
echo "═══════════════════════════════════════════════════════════"
