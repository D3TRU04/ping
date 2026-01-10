import { client, logProgress } from "./shared";
import fs from "fs";
import path from "path";
import { api } from "../convex/_generated/api";

async function importFollows() {
  console.log("🚀 Starting follows import...\n");

  const filePath = path.join(process.cwd(), "exports", "follows.json");
  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }

  const follows = JSON.parse(fs.readFileSync(filePath, "utf8"));
  console.log(`📂 Loaded ${follows.length} follows from follows.json\n`);

  const BATCH_SIZE = 100;
  let imported = 0;

  for (let i = 0; i < follows.length; i += BATCH_SIZE) {
    const batch = follows.slice(i, i + BATCH_SIZE);

    const result = await client.mutation(api.import.follows.insertFollowBatch, {
      follows: batch,
    });

    imported += result.inserted;
    logProgress(imported, follows.length, "follows imported");
  }

  console.log(`\n✅ Follows import complete! Total: ${imported}\n`);
}

importFollows()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Import failed:", err);
    process.exit(1);
  });
