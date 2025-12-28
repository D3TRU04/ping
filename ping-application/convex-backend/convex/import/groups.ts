import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const insertGroupBatch = mutation({
  args: {
    groups: v.array(v.any()),
  },
  handler: async (ctx, { groups }) => {
    let inserted = 0;

    for (const g of groups) {
      // Resolve creator
      const creator = await ctx.db
        .query("users")
        .withIndex("by_supabase_id", (q) => q.eq("supabaseId", g.created_by))
        .first();

      if (!creator) {
        continue;
      }

      // Check if already exists (by supabaseId)
      const existing = await ctx.db
        .query("groups")
        .withIndex("by_supabase_id", (q) => q.eq("supabaseId", g.id))
        .first();

      if (existing) {
        continue;
      }

      await ctx.db.insert("groups", {
        supabaseId: g.id,
        name: g.name,
        createdBy: creator._id,
        createdAt: g.created_at ? Date.parse(g.created_at) : Date.now(),
      });

      inserted++;
    }

    return { inserted };
  },
});

export const insertGroupMemberBatch = mutation({
  args: {
    members: v.array(v.any()),
  },
  handler: async (ctx, { members }) => {
    let inserted = 0;

    for (const m of members) {
      // Resolve group
      const group = await ctx.db
        .query("groups")
        .withIndex("by_supabase_id", (q) => q.eq("supabaseId", m.group_id))
        .first();

      // Resolve user
      const user = await ctx.db
        .query("users")
        .withIndex("by_supabase_id", (q) => q.eq("supabaseId", m.user_id))
        .first();

      if (!group || !user) {
        continue;
      }

      // Check if already exists
      const existing = await ctx.db
        .query("groupMembers")
        .withIndex("by_pair", (q) =>
          q.eq("groupId", group._id).eq("userId", user._id)
        )
        .first();

      if (existing) {
        continue;
      }

      await ctx.db.insert("groupMembers", {
        groupId: group._id,
        userId: user._id,
        role: m.role ?? undefined,
        joinedAt: m.joined_at ? Date.parse(m.joined_at) : Date.now(),
      });

      inserted++;
    }

    return { inserted };
  },
});
