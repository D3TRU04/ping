import { mutation, query } from "../_generated/server";
import { v } from "convex/values";

export const insertFollowBatch = mutation({
  args: {
    follows: v.array(v.any()),
  },
  handler: async (ctx, { follows }) => {
    let inserted = 0;

    for (const f of follows) {
      // Resolve user IDs
      const follower = await ctx.db
        .query("users")
        .withIndex("by_supabase_id", (q) => q.eq("supabaseId", f.follower_id))
        .first();

      const following = await ctx.db
        .query("users")
        .withIndex("by_supabase_id", (q) => q.eq("supabaseId", f.following_id))
        .first();

      if (!follower || !following) {
        continue;
      }

      // Check if already exists
      const existing = await ctx.db
        .query("follows")
        .withIndex("by_pair", (q) =>
          q.eq("followerId", follower._id).eq("followingId", following._id)
        )
        .first();

      if (existing) {
        continue;
      }

      await ctx.db.insert("follows", {
        followerId: follower._id,
        followingId: following._id,
        createdAt: f.followed_at ? Date.parse(f.followed_at) : Date.now(),
      });

      inserted++;
    }

    return { inserted };
  },
});
