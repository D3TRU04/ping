import { client, logProgress } from "./shared";
import fs from "fs";
import path from "path";
import { api } from "../convex/_generated/api";

async function importMessages() {
  console.log("🚀 Starting messages import...\n");

  const filePath = path.join(process.cwd(), "exports", "messages.json");
  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }

  const messages = JSON.parse(fs.readFileSync(filePath, "utf8"));
  console.log(`📂 Loaded ${messages.length} messages from messages.json\n`);

  const BATCH_SIZE = 100;
  let imported = 0;

  for (let i = 0; i < messages.length; i += BATCH_SIZE) {
    const batch = messages.slice(i, i + BATCH_SIZE);

    const result = await client.mutation(api.import.messages.insertMessageBatch, {
      messages: batch,
    });

    imported += result.inserted;
    logProgress(imported, messages.length, "messages imported");
  }

  console.log(`\n✅ Messages import complete! Total: ${imported}\n`);
}

importMessages()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Import failed:", err);
    process.exit(1);
  });
