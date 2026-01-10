import { client } from "./shared";
import { api } from "../convex/_generated/api";

async function checkCounts() {
  console.log("📊 Checking record counts in Convex...\n");

  const counts = await client.query(api.checkCounts.getCounts, {});

  console.log("Table                      | Count");
  console.log("─────────────────────────────────────");
  console.log(`users                      | ${counts.users}`);
  console.log(`places                     | ${counts.places}`);
  console.log(`follows                    | ${counts.follows}`);
  console.log(`groups                     | ${counts.groups}`);
  console.log(`groupMembers               | ${counts.groupMembers}`);
  console.log(`messages                   | ${counts.messages}`);
  console.log(`notifications              | ${counts.notifications}`);
  console.log(`notificationSettings       | ${counts.notificationSettings}`);
  console.log(`userPlaceVisits            | ${counts.userPlaceVisits}`);
  console.log("─────────────────────────────────────");
}

checkCounts()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Failed:", err);
    process.exit(1);
  });
