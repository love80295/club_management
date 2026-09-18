#!/bin/bash

BASE="http://127.0.0.1:8000/api"

echo "════════════════════════════════════════════"
echo "🧪 TESTING NEW FEATURES"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
# Step 1: Register new user
# ─────────────────────────────────────────────
echo "📝 Step 1: Register new user"

USERNAME="newuser_$(date +%s)"
EMAIL="${USERNAME}@university.edu"

REGISTER=$(curl -s -X POST "$BASE/auth/register/" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"$USERNAME\",
    \"email\": \"$EMAIL\",
    \"password\": \"Test@123456\",
    \"confirm_password\": \"Test@123456\",
    \"first_name\": \"New\",
    \"last_name\": \"User\",
    \"department\": \"Computer Science\",
    \"year\": \"2nd Year\"
  }")

echo "$REGISTER" | python3 -m json.tool 2>/dev/null | head -20

# Extract token
TOKEN=$(echo "$REGISTER" | python3 -c "import sys, json; print(json.load(sys.stdin).get('access', ''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "❌ Registration failed!"
    echo "$REGISTER"
    exit 1
fi

echo ""
echo "✅ Registered: $USERNAME"
echo "🔑 Token: ${TOKEN:0:40}..."
echo ""

# ─────────────────────────────────────────────
# Step 2: Create club with Instagram + Email
# ─────────────────────────────────────────────
echo "📝 Step 2: Create club with new fields"

CLUB_NAME="AI Club $RANDOM"

CLUB_RESPONSE=$(curl -s -X POST "$BASE/clubs/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"$CLUB_NAME\",
    \"description\": \"For AI enthusiasts to learn and build together\",
    \"category\": \"Technical\",
    \"instagram_handle\": \"@ai_club\",
    \"club_email\": \"ai@university.edu\"
  }")

echo "$CLUB_RESPONSE" | python3 -m json.tool
echo ""

# ─────────────────────────────────────────────
# Step 3: Get club ID from response
# ─────────────────────────────────────────────
CLUB_ID=$(echo "$CLUB_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('club', {}).get('id', ''))" 2>/dev/null)

if [ -z "$CLUB_ID" ]; then
    echo "⚠️  Club creation failed or no ID found"
    exit 1
fi

echo "✅ Club created: $CLUB_NAME (ID: $CLUB_ID)"
echo ""
echo "👉 Now approve it in Django Admin:"
echo "   http://127.0.0.1:8000/admin/clubs/club/$CLUB_ID/change/"
echo ""
echo "   Set Status = Approved, then press Enter here..."
read -p ""

# ─────────────────────────────────────────────
# Step 4: Create event as coordinator
# ─────────────────────────────────────────────
echo ""
echo "📝 Step 4: Create event as coordinator"

curl -s -X POST "$BASE/events/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"AI Workshop 2026\",
    \"description\": \"Learn AI fundamentals and build your first model\",
    \"date\": \"2026-12-15\",
    \"time\": \"10:00:00\",
    \"venue\": \"Computer Science Building\",
    \"category\": \"Workshop\",
    \"club\": $CLUB_ID,
    \"max_participants\": 50
  }" | python3 -m json.tool

echo ""
echo "════════════════════════════════════════════"
echo "✅ ALL TESTS DONE"
echo "════════════════════════════════════════════"
