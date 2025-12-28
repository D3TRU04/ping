#!/bin/bash

# Convex Import Runner - Executes all imports in correct dependency order
#
# Usage:
#   chmod +x convex/import/run-all.sh
#   ./convex/import/run-all.sh

set -e  # Exit on error

echo "═══════════════════════════════════════════════════════════"
echo "  Convex Migration: Supabase → Convex"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Track start time
START_TIME=$(date +%s)

# Function to run import and handle errors
run_import() {
  local name=$1
  local command=$2

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▶ Running: $name"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if eval "$command"; then
    echo "✅ $name completed successfully"
  else
    echo "❌ $name failed!"
    exit 1
  fi

  echo ""
}

# Pre-flight checks
echo "🔍 Pre-flight checks..."

if [ ! -d "exports" ]; then
  echo "❌ Error: exports/ directory not found"
  echo "   Please create exports/ and add your Supabase JSON exports"
  exit 1
fi

if [ ! -f "exports/profiles.json" ]; then
  echo "⚠️  Warning: exports/profiles.json not found"
  echo "   Users import will fail. Continue? (y/n)"
  read -r response
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

echo "✅ Pre-flight checks passed"
echo ""

# ========== PHASE 1: Base Data (No Dependencies) ==========
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  PHASE 1: Base Data (users, places)                      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

run_import "Users" "npx convex run import/users:importUsers"
run_import "Places" "npx convex run import/places:importPlaces"

# ========== PHASE 2: Relationships (Requires Users) ==========
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  PHASE 2: User Relationships (follows)                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

run_import "Follows" "npx convex run import/follows:importFollows"

# ========== PHASE 3: Groups (Requires Users) ==========
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  PHASE 3: Groups & Members                               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

run_import "Groups & Members" "npx convex run import/groups:importGroups"

# ========== PHASE 4: Messages (Requires Users + Groups) ==========
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  PHASE 4: Messages                                       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

run_import "Messages" "npx convex run import/messages:importMessages"

# ========== PHASE 5: Notifications (Requires Users) ==========
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  PHASE 5: Notifications                                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

run_import "Notifications" "npx convex run import/notifications:importNotifications"

# ========== PHASE 6: User Place Visits (Requires Users + Places) ==========
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  PHASE 6: User Place Visits                              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

run_import "User Place Visits" "npx convex run import/userPlaceVisits:importUserPlaceVisits"

# ========== COMPLETE ==========
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo "═══════════════════════════════════════════════════════════"
echo "  ✅ MIGRATION COMPLETE!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "⏱️  Total time: ${MINUTES}m ${SECONDS}s"
echo ""
echo "Next steps:"
echo "  1. Verify data in Convex dashboard"
echo "  2. Test application with Convex backend"
echo "  3. Update client code to use Convex queries/mutations"
echo ""
