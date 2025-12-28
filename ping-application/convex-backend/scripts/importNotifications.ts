import { client, logProgress } from "./shared";
import fs from "fs";
import path from "path";
import { api } from "../convex/_generated/api";

async function importNotifications() {
  console.log("🚀 Starting notifications import...\n");

  const filePath = path.join(process.cwd(), "exports", "notifications.json");
  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }

  const notifications = JSON.parse(fs.readFileSync(filePath, "utf8"));
  console.log(`📂 Loaded ${notifications.length} notifications from notifications.json\n`);

  const BATCH_SIZE = 100;
  let imported = 0;

  for (let i = 0; i < notifications.length; i += BATCH_SIZE) {
    const batch = notifications.slice(i, i + BATCH_SIZE);

    const result = await client.mutation(api.import.notifications.insertNotificationBatch, {
      notifications: batch,
    });

    imported += result.inserted;
    logProgress(imported, notifications.length, "notifications imported");
  }

  console.log(`\n✅ Notifications import complete! Total: ${imported}\n`);
}

importNotifications()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Import failed:", err);
    process.exit(1);
  });
