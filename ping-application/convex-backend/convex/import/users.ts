import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const insertUserBatch = mutation({
  args: {
    profiles: v.array(v.any()),
  },
  handler: async (ctx, { profiles }) => {
    for (const p of profiles) {
      // Check if user already exists (idempotency)
      const existing = await ctx.db
        .query("users")
        .withIndex("by_supabase_id", (q) => q.eq("supabaseId", p.id))
        .first();

      if (existing) {
        continue;
      }

      // Generate placeholder username if missing
      const username = p.username || `user_${p.id.substring(0, 8)}`;

      // Handle categoryPreferences - convert empty arrays to undefined
      let categoryPrefs = p.category_preferences;
      if (Array.isArray(categoryPrefs) && categoryPrefs.length === 0) {
        categoryPrefs = undefined;
      } else if (Array.isArray(categoryPrefs)) {
        // If it's a non-empty array, also convert to undefined (we expect an object)
        categoryPrefs = undefined;
      }

      await ctx.db.insert("users", {
        supabaseId: p.id,
        username: username,
        fullName: p.full_name ?? undefined,
        bio: p.bio ?? undefined,
        profilePicture: p.profile_picture ?? undefined,
        birthday: p.birthday ?? undefined,
        phoneNumber: p.phone_number ?? undefined,
        location: p.location ?? undefined,
        pronouns: p.pronouns ?? undefined,
        links: Array.isArray(p.links) ? p.links : undefined,
        categoryPreferences: categoryPrefs ?? undefined,
        isOnboarded: p.has_onboarded ?? false,
        createdAt: p.created_at ? Date.parse(p.created_at) : Date.now(),
      });
    }
  },
});
