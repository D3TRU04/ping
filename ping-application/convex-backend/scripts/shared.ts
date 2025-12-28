import { ConvexHttpClient } from "convex/browser";
import dotenv from "dotenv";

dotenv.config({ path: ".env.local" });

if (!process.env.CONVEX_URL) {
  console.error("❌ CONVEX_URL not found in .env.local");
  console.log("\nTo fix this:");
  console.log("1. Run: npx convex dev");
  console.log("2. Copy the deployment URL");
  console.log("3. Add to .env.local: CONVEX_URL=<your-url>");
  process.exit(1);
}

export const client = new ConvexHttpClient(process.env.CONVEX_URL);

export function logProgress(current: number, total: number, label: string) {
  const percentage = ((current / total) * 100).toFixed(1);
  console.log(`   ✓ ${current}/${total} ${label} (${percentage}%)`);
}
