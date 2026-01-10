import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const insertMessageBatch = mutation({
  args: {
    messages: v.array(v.any()),
  },
  handler: async (ctx, { messages }) => {
    let inserted = 0;

    for (const m of messages) {
      // Resolve sender
      const sender = await ctx.db
        .query("users")
        .withIndex("by_supabase_id", (q) => q.eq("supabaseId", m.sender_id))
        .first();

      if (!sender) {
        continue;
      }

      // Resolve receiver (optional)
      let receiver = undefined;
      if (m.receiver_id) {
        receiver = await ctx.db
          .query("users")
          .withIndex("by_supabase_id", (q) => q.eq("supabaseId", m.receiver_id))
          .first();
      }

      // Resolve group (optional)
      let group = undefined;
      if (m.group_id) {
        group = await ctx.db
          .query("groups")
          .withIndex("by_supabase_id", (q) => q.eq("supabaseId", m.group_id))
          .first();
      }

      // Extract message text (might be string or object with text property)
      const messageText = typeof m.message === 'string'
        ? m.message
        : m.message?.text ?? '';

      await ctx.db.insert("messages", {
        senderId: sender._id,
        receiverId: receiver?._id,
        groupId: group?._id,
        conversationId: m.conversation_id ?? undefined,
        message: messageText,
        isRead: m.is_read ?? false,
        createdAt: m.created_at ? Date.parse(m.created_at) : Date.now(),
      });

      inserted++;
    }

    return { inserted };
  },
});
