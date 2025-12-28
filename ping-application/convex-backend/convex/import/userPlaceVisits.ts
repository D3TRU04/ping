import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const insertVisitBatch = mutation({
  args: {
    visits: v.array(v.any()),
  },
  handler: async (ctx, { visits }) => {
    let inserted = 0;

    for (const v of visits) {
      // Resolve user
      const user = await ctx.db
        .query("users")
        .withIndex("by_supabase_id", (q) => q.eq("supabaseId", v.user_id))
        .first();

      if (!user) {
        continue;
      }

      // Find place by name
      const place = await ctx.db
        .query("places")
        .withIndex("by_name", (q) => q.eq("name", v.place_name))
        .first();

      if (!place) {
        continue;
      }

      // Check if already exists
      const existing = await ctx.db
        .query("userPlaceVisits")
        .withIndex("by_pair", (q) =>
          q.eq("userId", user._id).eq("placeId", place._id)
        )
        .first();

      if (existing) {
        continue;
      }

      await ctx.db.insert("userPlaceVisits", {
        userId: user._id,
        placeId: place._id,
        placeName: v.place_name,
        placeImage: v.place_image,
        visitDate: v.visit_date ? Date.parse(v.visit_date) : Date.now(),
        createdAt: v.created_at ? Date.parse(v.created_at) : Date.now(),
      });

      inserted++;
    }

    return { inserted };
  },
});
