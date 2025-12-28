import { client, logProgress } from "./shared";
import fs from "fs";
import path from "path";
import { api } from "../convex/_generated/api";

async function importUsers() {
  console.log("🚀 Starting users import...\n");

  const filePath = path.join(process.cwd(), "exports", "profiles.json");
  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }

  const profiles = JSON.parse(fs.readFileSync(filePath, "utf8"));
  console.log(`📂 Loaded ${profiles.length} profiles from profiles.json\n`);

  const BATCH_SIZE = 100;
  let imported = 0;

  for (let i = 0; i < profiles.length; i += BATCH_SIZE) {
    const batch = profiles.slice(i, i + BATCH_SIZE);

    await client.mutation(api.import.users.insertUserBatch, {
      profiles: batch,
    });

    imported += batch.length;
    logProgress(imported, profiles.length, "users imported");
  }

  console.log(`\n✅ Users import complete! Total: ${imported}\n`);
}

importUsers()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Import failed:", err);
    process.exit(1);
  });
