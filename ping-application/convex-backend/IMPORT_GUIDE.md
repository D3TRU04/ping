# Supabase → Convex Migration Guide

## 🎯 Overview

This guide helps you migrate all data from Supabase to Convex using local Node.js scripts that read JSON exports and call Convex mutations.

## 📋 Prerequisites

1. ✅ Convex backend initialized (`npx convex dev`)
2. ✅ All Supabase data exported to `exports/*.json` files
3. ✅ Schema deployed to Convex

## 🚀 Quick Start

### Step 1: Install Dependencies

```bash
npm install
```

### Step 2: Configure Environment

Create `.env.local` in the project root:

```bash
CONVEX_URL=https://your-deployment.convex.cloud
```

**To get your Convex URL:**
1. Run `npx convex dev`
2. Copy the deployment URL from the output
3. Paste into `.env.local`

### Step 3: Run All Imports

```bash
npm run import:all
```

This runs all imports in the correct dependency order:
1. Users
2. Places (7 categories)
3. Follows
4. Groups + Members
5. Messages
6. Notifications
7. Notification Settings
8. User Place Visits

---

## 📦 Individual Imports

Run imports one at a time:

```bash
npm run import:users              # Import users from profiles.json
npm run import:places             # Import places from 7 category files
npm run import:follows            # Import follows
npm run import:groups             # Import groups + members
npm run import:messages           # Import messages
npm run import:notifications      # Import notifications
npm run import:settings           # Import notification settings
npm run import:visits             # Import user place visits
```

---

## 📁 Required Export Files

Place these files in `exports/` directory:

```
exports/
├── profiles.json
├── food_drink.json
├── nature_outdoors.json
├── social_nightlife.json
├── recreation_fitness.json
├── shopping.json
├── creative_arts.json
├── indoor_activities.json
├── follows.json
├── groups.json
├── group_members.json
├── messages.json
├── notifications.json
├── notification_settings.json
└── user_place_visits.json
```

---

## 🔄 Idempotency

All imports are **fully idempotent**:

- ✅ Safe to run multiple times
- ✅ Skips existing records automatically
- ✅ Can resume after failures
- ✅ No duplicates created

**Example:**
```bash
# First run: imports 1000 users
npm run import:users

# Second run: skips all 1000, imports 0
npm run import:users
```

---

## 🗺️ Data Mappings

### Users
- `profiles.id` → `users.supabaseId` (preserved for auth)
- `profiles.username` → `users.username`
- `profiles.full_name` → `users.fullName`
- All fields mapped with proper camelCase

### Places
- 7 tables merged into one `places` table
- `category` field identifies original table
- `subcategory` extracted from category-specific fields

### Foreign Keys
- Supabase UUIDs resolved to Convex `_id`s
- Missing references skipped (not imported)
- Logs warnings for unresolved references

---

## 🐛 Troubleshooting

### "File not found" Error

```
❌ File not found: /path/to/exports/profiles.json
```

**Fix:** Ensure JSON files exist in `exports/` directory

---

### "CONVEX_URL not found" Error

```
❌ CONVEX_URL not found in .env.local
```

**Fix:**
1. Run `npx convex dev`
2. Copy deployment URL
3. Add to `.env.local`: `CONVEX_URL=https://...`

---

### "User not found" Errors

```
⚠️ Skipping follow: user not found
```

**Fix:** Run `npm run import:users` first before importing follows, groups, etc.

---

### Import Hangs

**Fix:**
- Large datasets may take time (100 records per batch)
- Check network connection to Convex
- Monitor progress logs

---

## 📊 Progress Logging

Each import shows real-time progress:

```
🚀 Starting users import...

📂 Loaded 2500 users from profiles.json

   ✓ 100/2500 users imported (4.0%)
   ✓ 200/2500 users imported (8.0%)
   ...
   ✓ 2500/2500 users imported (100.0%)

✅ Users import complete! Total: 2500
```

---

## 🔐 Auth Preservation

Supabase Auth is **fully preserved**:

- `profiles.id` stored as `users.supabaseId`
- Matches `auth.subject` from Supabase Auth
- No changes needed to auth configuration

---

## ⚙️ Technical Details

### Architecture

```
Local Script (Node.js)
    ↓ reads
JSON Files (exports/)
    ↓ sends via
Convex Client (HTTP)
    ↓ calls
Convex Mutations
    ↓ inserts
Convex Database
```

### Batch Processing

- **Batch size:** 100 records per mutation call
- **Why batching:** Avoids Convex timeout limits
- **Trade-off:** Speed vs. reliability

### Foreign Key Resolution

1. Load all users/groups into memory
2. Build `Map<supabaseId, convexId>`
3. Resolve foreign keys during insert
4. Skip records with missing references

---

## 📝 Next Steps

After successful import:

1. ✅ Verify data in Convex dashboard
2. ✅ Test queries/mutations
3. ✅ Update client code to use Convex
4. ✅ Decommission Supabase (if applicable)

---

## 🆘 Support

If you encounter issues:

1. Check logs for specific error messages
2. Verify JSON export format matches expected structure
3. Ensure all dependencies imported in correct order
4. Test with small subset first

---

## 📄 License

This migration tooling is part of your Convex backend.
