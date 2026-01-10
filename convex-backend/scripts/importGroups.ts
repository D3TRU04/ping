import { client, logProgress } from "./shared";
import fs from "fs";
import path from "path";
import { api } from "../convex/_generated/api";

async function importGroups() {
  console.log("🚀 Starting groups import...\n");

  // Import groups
  const groupsPath = path.join(process.cwd(), "exports", "groups.json");
  if (!fs.existsSync(groupsPath)) {
    throw new Error(`File not found: ${groupsPath}`);
  }

  const groups = JSON.parse(fs.readFileSync(groupsPath, "utf8"));
  console.log(`📂 Loaded ${groups.length} groups from groups.json\n`);

  const BATCH_SIZE = 100;
  let groupsImported = 0;

  for (let i = 0; i < groups.length; i += BATCH_SIZE) {
    const batch = groups.slice(i, i + BATCH_SIZE);

    const result = await client.mutation(api.import.groups.insertGroupBatch, {
      groups: batch,
    });

    groupsImported += result.inserted;
    logProgress(groupsImported, groups.length, "groups imported");
  }

  console.log(`\n✅ Groups imported: ${groupsImported}\n`);

  // Import group members
  const membersPath = path.join(process.cwd(), "exports", "group_members.json");
  if (!fs.existsSync(membersPath)) {
    console.log("⚠️  group_members.json not found - skipping members\n");
    return;
  }

  const members = JSON.parse(fs.readFileSync(membersPath, "utf8"));
  console.log(`📂 Loaded ${members.length} group members from group_members.json\n`);

  let membersImported = 0;

  for (let i = 0; i < members.length; i += BATCH_SIZE) {
    const batch = members.slice(i, i + BATCH_SIZE);

    const result = await client.mutation(api.import.groups.insertGroupMemberBatch, {
      members: batch,
    });

    membersImported += result.inserted;
    logProgress(membersImported, members.length, "members imported");
  }

  console.log(`\n✅ Group members imported: ${membersImported}\n`);
}

importGroups()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Import failed:", err);
    process.exit(1);
  });
