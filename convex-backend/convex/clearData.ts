import { mutation } from "./_generated/server";
import { v } from "convex/values";

export const clearTable = mutation({
  args: {
    table: v.string(),
    batchSize: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const batchSize = args.batchSize || 100;
    const docs = await ctx.db.query(args.table as any).take(batchSize);

    for (const doc of docs) {
      await ctx.db.delete(doc._id);
    }

    return { deleted: docs.length, hasMore: docs.length === batchSize };
  },
});
