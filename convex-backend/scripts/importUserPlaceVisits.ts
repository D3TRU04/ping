import { client, logProgress } from "./shared";
import fs from "fs";
import path from "path";
import { api } from "../convex/_generated/api";

async function importUserPlaceVisits() {
  console.log("🚀 Starting user place visits import...\n");

  const filePath = path.join(process.cwd(), "exports", "user_place_visits.json");
  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }

  const visits = JSON.parse(fs.readFileSync(filePath, "utf8"));
  console.log(`📂 Loaded ${visits.length} visits from user_place_visits.json\n`);

  const BATCH_SIZE = 100;
  let imported = 0;

  for (let i = 0; i < visits.length; i += BATCH_SIZE) {
    const batch = visits.slice(i, i + BATCH_SIZE);

    const result = await client.mutation(api.import.userPlaceVisits.insertVisitBatch, {
      visits: batch,
    });

    imported += result.inserted;
    logProgress(imported, visits.length, "visits imported");
  }

  console.log(`\n✅ User place visits import complete! Total: ${imported}\n`);
}

importUserPlaceVisits()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Import failed:", err);
    process.exit(1);
  });
