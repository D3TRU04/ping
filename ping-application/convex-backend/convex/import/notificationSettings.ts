import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const insertSettingBatch = mutation({
  args: {
    settings: v.array(v.any()),
  },
  handler: async (ctx, { settings }) => {
    let inserted = 0;

    for (const s of settings) {
      // Resolve user
      const user = await ctx.db
        .query("users")
        .withIndex("by_supabase_id", (q) => q.eq("supabaseId", s.user_id))
        .first();

      if (!user) {
        continue;
      }

      // Check if already exists
      const existing = await ctx.db
        .query("notificationSettings")
        .withIndex("by_user", (q) => q.eq("userId", user._id))
        .first();

      if (existing) {
        continue;
      }

      await ctx.db.insert("notificationSettings", {
        userId: user._id,
        pushEnabled: s.push_enabled ?? false,
        emailEnabled: s.email_enabled ?? false,
        followNotifications: s.follow_notifications ?? false,
        messageNotifications: s.message_notifications ?? false,
        groupNotifications: s.group_notifications ?? false,
      });

      inserted++;
    }

    return { inserted };
  },
});
