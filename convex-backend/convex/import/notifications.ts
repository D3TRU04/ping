import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const insertNotificationBatch = mutation({
  args: {
    notifications: v.array(v.any()),
  },
  handler: async (ctx, { notifications }) => {
    let inserted = 0;

    for (const n of notifications) {
      // Resolve recipient
      const recipient = await ctx.db
        .query("users")
        .withIndex("by_supabase_id", (q) => q.eq("supabaseId", n.recipient_id))
        .first();

      if (!recipient) {
        continue;
      }

      // Resolve sender (optional)
      let sender = undefined;
      if (n.sender_id) {
        sender = await ctx.db
          .query("users")
          .withIndex("by_supabase_id", (q) => q.eq("supabaseId", n.sender_id))
          .first();
      }

      await ctx.db.insert("notifications", {
        recipientId: recipient._id,
        senderId: sender?._id,
        type: n.type,
        title: n.title,
        message: n.message,
        metadata: n.metadata,
        isRead: n.is_read ?? false,
        createdAt: n.created_at ? Date.parse(n.created_at) : Date.now(),
      });

      inserted++;
    }

    return { inserted };
  },
});
