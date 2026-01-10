/**
 * List all tables in your Supabase database
 *
 * This helps verify which tables actually exist
 *
 * Run: tsx scripts/listSupabaseTables.ts
 */

import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";

dotenv.config({ path: ".env.local" });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("❌ Missing Supabase credentials in .env.local");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function listTables() {
  console.log("🔍 Checking which tables exist in Supabase...\n");

  const tablesToCheck = [
    "profiles",
    "follows",
    "groups",
    "group_members",
    "messages",
    "notifications",
    "notification_settings",
    "user_place_visits",
    "food_drink",
    "nature_outdoors",
    "social_nightlife",
    "recreation_fitness",
    "shopping",
    "creative_arts",
    "indoor_activities",
  ];

  console.log("Table Name                  | Exists | Row Count");
  console.log("---------------------------------------------------");

  for (const table of tablesToCheck) {
    try {
      const { data, error, count } = await supabase
        .from(table)
        .select("*", { count: "exact", head: true });

      if (error) {
        console.log(`${table.padEnd(27)} | ❌ NO  | Error: ${error.message}`);
      } else {
        const rowCount = count ?? 0;
        const status = rowCount > 0 ? "✅ YES" : "⚠️  YES";
        console.log(`${table.padEnd(27)} | ${status} | ${rowCount} rows`);
      }
    } catch (err) {
      console.log(`${table.padEnd(27)} | ❌ NO  | Not accessible`);
    }
  }

  console.log("\n---------------------------------------------------");
  console.log("\nLegend:");
  console.log("✅ YES = Table exists with data");
  console.log("⚠️  YES = Table exists but is empty");
  console.log("❌ NO  = Table doesn't exist or not accessible");
}

listTables()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Failed:", err);
    process.exit(1);
  });
