import { client, logProgress } from "./shared";
import fs from "fs";
import path from "path";
import { api } from "../convex/_generated/api";

async function importNotificationSettings() {
  console.log("🚀 Starting notification settings import...\n");

  const filePath = path.join(process.cwd(), "exports", "notification_settings.json");
  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }

  const settings = JSON.parse(fs.readFileSync(filePath, "utf8"));
  console.log(`📂 Loaded ${settings.length} settings from notification_settings.json\n`);

  const BATCH_SIZE = 100;
  let imported = 0;

  for (let i = 0; i < settings.length; i += BATCH_SIZE) {
    const batch = settings.slice(i, i + BATCH_SIZE);

    const result = await client.mutation(api.import.notificationSettings.insertSettingBatch, {
      settings: batch,
    });

    imported += result.inserted;
    logProgress(imported, settings.length, "settings imported");
  }

  console.log(`\n✅ Notification settings import complete! Total: ${imported}\n`);
}

importNotificationSettings()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Import failed:", err);
    process.exit(1);
  });
