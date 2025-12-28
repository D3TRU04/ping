import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const insertPlaceBatch = mutation({
  args: {
    places: v.array(
      v.object({
        name: v.string(),
        category: v.string(),
        subcategory: v.optional(v.string()),
        location: v.string(),
        lat: v.number(),
        lng: v.number(),
        rating: v.optional(v.number()),
        priceRange: v.optional(v.string()),
        hours: v.optional(v.string()),
        description: v.optional(v.string()),
        imageUrl: v.optional(v.string()),
        websiteUrl: v.optional(v.string()),
        insertedAt: v.number(),
      })
    ),
  },
  handler: async (ctx, { places }) => {
    for (const place of places) {
      // Insert all places without checking for duplicates
      await ctx.db.insert("places", place);
    }
  },
});
