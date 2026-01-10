import { query } from "./_generated/server";

export const getCounts = query({
  handler: async (ctx) => {
    const tables = [
      "users",
      "places",
      "follows",
      "groups",
      "groupMembers",
      "messages",
      "notifications",
      "notificationSettings",
      "userPlaceVisits",
    ];

    const counts: Record<string, number> = {};

    for (const table of tables) {
      const docs = await ctx.db.query(table as any).collect();
      counts[table] = docs.length;
    }

    return counts;
  },
});
