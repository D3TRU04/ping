import { client } from "./shared";
import { api } from "../convex/_generated/api";
import { execSync } from "child_process";

async function clearTable(tableName: string) {
  let totalDeleted = 0;
  let hasMore = true;

  while (hasMore) {
    const result = await client.mutation(api.clearData.clearTable, {
      table: tableName,
      batchSize: 100,
    } as any);

    totalDeleted += result.deleted;
    hasMore = result.hasMore;

    if (result.deleted > 0) {
      process.stdout.write(`\r   Cleared ${totalDeleted} records from ${tableName}...`);
    }
  }

  if (totalDeleted > 0) {
    console.log(`\r   ✅ Cleared ${totalDeleted} records from ${tableName}`);
  } else {
    console.log(`   ⚠️  ${tableName} was already empty`);
  }
}

async function clearAndImport() {
  console.log("🗑️  Clearing all existing data...\n");

  const tables = [
    "userPlaceVisits",
    "notificationSettings",
    "notifications",
    "messages",
    "groupMembers",
    "groups",
    "follows",
    "places",
    "users",
    "idMappings",
  ];

  try {
    for (const table of tables) {
      await clearTable(table);
    }
    console.log("\n✅ All data cleared!\n");
  } catch (err) {
    console.error("\n❌ Failed to clear data:", err);
    process.exit(1);
  }

  console.log("🚀 Starting fresh import...\n");

  try {
    execSync("npm run import:all", { stdio: "inherit" });
  } catch (err) {
    console.error("❌ Import failed:", err);
    process.exit(1);
  }
}

clearAndImport()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Failed:", err);
    process.exit(1);
  });
