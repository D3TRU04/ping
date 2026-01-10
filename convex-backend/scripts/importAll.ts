import { execSync } from "child_process";

const imports = [
  { name: "users", script: "import:users" },
  { name: "places", script: "import:places" },
  { name: "follows", script: "import:follows" },
  { name: "groups", script: "import:groups" },
  { name: "messages", script: "import:messages" },
  { name: "notifications", script: "import:notifications" },
  { name: "notification settings", script: "import:settings" },
  { name: "user place visits", script: "import:visits" },
];

console.log("╔═══════════════════════════════════════════════════════╗");
console.log("║  Supabase → Convex Migration                         ║");
console.log("║  Running all imports in dependency order             ║");
console.log("╚═══════════════════════════════════════════════════════╝\n");

const startTime = Date.now();

for (const { name, script } of imports) {
  console.log(`\n${"═".repeat(60)}`);
  console.log(`Starting: ${name}`);
  console.log("═".repeat(60));

  try {
    execSync(`npm run ${script}`, { stdio: "inherit" });
  } catch (error) {
    console.error(`\n❌ Failed to import ${name}`);
    process.exit(1);
  }
}

const duration = ((Date.now() - startTime) / 1000).toFixed(1);

console.log("\n" + "═".repeat(60));
console.log("✅ ALL IMPORTS COMPLETE!");
console.log("═".repeat(60));
console.log(`Total time: ${duration}s\n`);
