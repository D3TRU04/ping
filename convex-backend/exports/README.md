# Supabase Data Exports

Place your Supabase JSON export files in this directory.

## Required Files

1. `profiles.json` - User profiles
2. `follows.json` - Follow relationships
3. `groups.json` - Groups
4. `group_members.json` - Group memberships
5. `messages.json` - Messages
6. `notifications.json` - Notifications
7. `notification_settings.json` - User notification preferences
8. `user_place_visits.json` - User place visit history

### Place Category Files (7 files)
9. `food_drink.json`
10. `nature_outdoors.json`
11. `social_nightlife.json`
12. `recreation_fitness.json`
13. `shopping.json`
14. `creative_arts.json`
15. `indoor_activities.json`

## How to Export from Supabase

### Method 1: Supabase Dashboard (Easiest)

1. Go to Supabase Dashboard → SQL Editor
2. Run query: `SELECT * FROM profiles;`
3. Click "Download as JSON"
4. Save as `profiles.json` in this directory
5. Repeat for all tables

### Method 2: Supabase CLI

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Export data (requires project setup)
# This is more complex - use Method 1 for simplicity
```

### Method 3: Direct Database Connection

If you have direct PostgreSQL access:

```sql
-- In psql or any PostgreSQL client
COPY (SELECT * FROM profiles) TO '/path/to/exports/profiles.json' WITH (FORMAT json);
```

## Expected JSON Format

Each file should be a JSON array of objects:

```json
[
  {
    "id": "uuid-1",
    "username": "john_doe",
    "full_name": "John Doe",
    "created_at": "2024-01-01T00:00:00Z"
  },
  {
    "id": "uuid-2",
    "username": "jane_smith",
    "full_name": "Jane Smith",
    "created_at": "2024-01-02T00:00:00Z"
  }
]
```

## Test with Sample Data

For testing, you can create minimal sample files:

**profiles.json:**
```json
[
  {
    "id": "test-user-1",
    "username": "testuser",
    "full_name": "Test User",
    "created_at": "2024-01-01T00:00:00Z"
  }
]
```

Then run: `npm run import:users`

## After Exporting

Once all files are in this directory, run:

```bash
npm run import:all
```

This will import all data in the correct dependency order.
