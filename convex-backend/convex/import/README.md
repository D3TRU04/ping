# Convex Import Scripts - Migration Guide

Production-grade import mutations for migrating from Supabase to Convex.

## Features

- **Idempotent**: Safe to run multiple times, skips existing data
- **Progress Logging**: Real-time tracking of processed/skipped/errors
- **Error Handling**: Continues on error, reports summary at end
- **Foreign Key Resolution**: Automatically maps Supabase UUIDs to Convex IDs
- **Validation**: Checks required fields and file existence

## Prerequisites

1. Export your Supabase data to JSON files in `exports/` directory
2. Required files:
   - `exports/profiles.json`
   - `exports/food_drink.json` (and 6 other place categories)
   - `exports/follows.json`
   - `exports/groups.json`
   - `exports/group_members.json`
   - `exports/notifications.json`
   - `exports/user_place_visits.json`

## Import Order (CRITICAL)

Run imports in this exact order due to foreign key dependencies:

```bash
# 1. Base data (no dependencies)
npx convex run import/users:importUsers
npx convex run import/places:importPlaces

# 2. User relationships (requires users)
npx convex run import/follows:importFollows

# 3. Groups (requires users)
npx convex run import/groups:importGroups

# 4. Notifications (requires users)
npx convex run import/notifications:importNotifications

# 5. User place visits (requires users + places)
npx convex run import/userPlaceVisits:importUserPlaceVisits
```

## Run All Imports

Use the provided shell script to run all imports in order:

```bash
chmod +x convex/import/run-all.sh
./convex/import/run-all.sh
```

Or manually run each command above in sequence.

## Idempotency

All imports are fully idempotent:

- **First run**: Imports all data, creates UUID mappings
- **Subsequent runs**: Skips existing records using mappings
- **Partial failures**: Re-running continues from where it left off

This means you can safely:
- Re-run failed imports
- Run imports multiple times
- Resume interrupted migrations

## Error Handling

Each import:
1. Logs errors with record details
2. Continues processing remaining records
3. Throws error at end if any failures occurred
4. Prints summary: processed/skipped/errors

Review logs to identify and fix problematic records.

## UUID Mapping

Supabase UUIDs are mapped to Convex `_id`s in the `idMappings` table:

```ts
{
  supabaseId: "uuid-from-supabase",
  convexId: "convex-generated-id",
  tableName: "users" | "places" | ...
}
```

This enables:
- Foreign key resolution (e.g., follower_id → Convex user _id)
- Idempotent imports (skip if mapping exists)
- Audit trail of migrated records

## Troubleshooting

### "File not found" error
Ensure JSON files exist in `exports/` directory with correct names.

### "User not found for Supabase ID" error
Run `import/users:importUsers` first before other imports.

### "Place not found for name" error
Run `import/places:importPlaces` before `import/userPlaceVisits:importUserPlaceVisits`.

### Import hangs or times out
Large datasets may timeout. Consider:
- Splitting JSON files into smaller batches
- Increasing Convex timeout limits
- Running imports during off-peak hours

## Schema Notes

- **Supabase Auth preserved**: `profiles.id` matches `auth.subject`
- **No UUID reuse**: Supabase UUIDs are NOT used as Convex `_id`s
- **Places merged**: 7 Supabase tables → 1 Convex collection
- **Denormalized data**: Some fields duplicated for performance (e.g., placeName in userPlaceVisits)

## Need Help?

- Check logs for specific error messages
- Verify JSON export format matches expected structure
- Ensure all dependencies are imported in correct order
- Test with small subset of data first
