/**
 * Export data from Supabase to JSON files
 *
 * Setup:
 * 1. npm install @supabase/supabase-js
 * 2. Add SUPABASE_URL and SUPABASE_KEY to .env.local
 * 3. Run: tsx scripts/exportFromSupabase.ts
 */

import { createClient } from "@supabase/supabase-js";
import fs from "fs";
import path from "path";
import dotenv from "dotenv";

dotenv.config({ path: ".env.local" });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("❌ Missing Supabase credentials in .env.local");
  console.log("\nAdd these to .env.local:");
  console.log("SUPABASE_URL=https://your-project.supabase.co");
  console.log("SUPABASE_SERVICE_KEY=your-service-key");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function exportTable(tableName: string, fileName: string) {
  console.log(`📂 Exporting ${tableName}...`);

  try {
    let allData: any[] = [];
    let from = 0;
    const batchSize = 1000;
    let hasMore = true;

    // Fetch in batches to handle tables with > 1000 records
    while (hasMore) {
      const { data, error, count } = await supabase
        .from(tableName)
        .select("*", { count: "exact" })
        .range(from, from + batchSize - 1);

      if (error) {
        console.error(`   ❌ Error: ${error.message}`);
        return;
      }

      if (data && data.length > 0) {
        allData = allData.concat(data);
        from += batchSize;

        // Show progress for large tables
        if (count && count > batchSize) {
          console.log(`   📊 Fetched ${allData.length}/${count} records...`);
        }

        hasMore = data.length === batchSize;
      } else {
        hasMore = false;
      }
    }

    const filePath = path.join("exports", fileName);
    fs.writeFileSync(filePath, JSON.stringify(allData, null, 2));

    console.log(`   ✅ Exported ${allData.length} records to ${fileName}`);
  } catch (error) {
    console.error(`   ❌ Failed:`, error);
  }
}

async function exportAll() {
  console.log("🚀 Starting Supabase export...\n");

  // Ensure exports directory exists
  if (!fs.existsSync("exports")) {
    fs.mkdirSync("exports");
  }

  // Export all tables
  await exportTable("profiles", "profiles.json");
  await exportTable("follows", "follows.json");
  await exportTable("groups", "groups.json");
  await exportTable("group_members", "group_members.json");
  await exportTable("messages", "messages.json");
  await exportTable("notifications", "notifications.json");
  await exportTable("notification_settings", "notification_settings.json");
  await exportTable("user_place_visits", "user_place_visits.json");

  // Export place categories
  await exportTable("food_drink", "food_drink.json");
  await exportTable("nature_outdoors", "nature_outdoors.json");
  await exportTable("social_nightlife", "social_nightlife.json");
  await exportTable("recreation_fitness", "recreation_fitness.json");
  await exportTable("shopping", "shopping.json");
  await exportTable("creative_arts", "creative_arts.json");
  await exportTable("indoor_activities", "indoor_activities.json");

  console.log("\n✅ Export complete! Files saved to exports/");
  console.log("\nNext steps:");
  console.log("1. Verify JSON files in exports/ directory");
  console.log("2. Run: npm run import:all");
}

exportAll()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Export failed:", err);
    process.exit(1);
  });
