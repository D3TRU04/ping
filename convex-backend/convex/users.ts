import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Get user by ID
export const getById = query({
  args: { userId: v.string() },
  handler: async (ctx, { userId }) => {
    const user = await ctx.db.get(userId as any);

    if (!user) {
      throw new Error("User not found");
    }

    // Don't return password hash to client
    const { passwordHash, ...safeUser } = user;

    return safeUser;
  },
});

// Get user by email
export const getByEmail = query({
  args: { email: v.string() },
  handler: async (ctx, { email }) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", email))
      .first();

    if (!user) {
      return null;
    }

    const { passwordHash, ...safeUser } = user;
    return safeUser;
  },
});

// Get user by username
export const getByUsername = query({
  args: { username: v.string() },
  handler: async (ctx, { username }) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_username", (q) => q.eq("username", username))
      .first();

    if (!user) {
      return null;
    }

    const { passwordHash, ...safeUser } = user;
    return safeUser;
  },
});

// ========== CLERK INTEGRATION ==========

// Get user by Clerk ID
export const getByClerkId = query({
  args: { clerkUserId: v.string() },
  handler: async (ctx, { clerkUserId }) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_user_id", (q) => q.eq("clerkUserId", clerkUserId))
      .first();

    if (!user) {
      throw new Error("User not found");
    }

    // No need to filter passwordHash since Clerk handles authentication
    return user;
  },
});

// Create or update user from Clerk
export const createOrUpdateFromClerk = mutation({
  args: {
    clerkUserId: v.string(),
    email: v.optional(v.string()),
    phoneNumber: v.optional(v.string()),
    profileImageUrl: v.optional(v.string()),
  },
  handler: async (ctx, { clerkUserId, email, phoneNumber, profileImageUrl }) => {
    // Check if user already exists
    const existing = await ctx.db
      .query("users")
      .withIndex("by_clerk_user_id", (q) => q.eq("clerkUserId", clerkUserId))
      .first();

    if (existing) {
      // Update existing user
      await ctx.db.patch(existing._id, {
        email: email || existing.email,
        phoneNumber: phoneNumber || existing.phoneNumber,
        profilePicture: profileImageUrl || existing.profilePicture,
      });
      return existing._id;
    } else {
      // Create new user
      const userId = await ctx.db.insert("users", {
        clerkUserId,
        email: email || undefined,
        phoneNumber: phoneNumber || undefined,
        profilePicture: profileImageUrl || undefined,
        username: email?.split("@")[0] || `user${Date.now()}`,
        isOnboarded: false,
        createdAt: Date.now(),
      });
      return userId;
    }
  },
});

// Complete onboarding with profile data
export const completeOnboarding = mutation({
  args: {
    clerkUserId: v.string(),
    fullName: v.string(),
    birthday: v.string(),
    username: v.string(),
    categoryPreferences: v.array(v.string()),
    subcategoryPreferences: v.array(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_user_id", (q) => q.eq("clerkUserId", args.clerkUserId))
      .first();

    if (!user) {
      throw new Error("User not found");
    }

    // Update user profile
    await ctx.db.patch(user._id, {
      fullName: args.fullName,
      birthday: args.birthday,
      username: args.username,
      categoryPreferences: {
        categories: args.categoryPreferences,
        subcategories: args.subcategoryPreferences,
      },
      isOnboarded: true,
    });

    // Return updated user
    return await ctx.db.get(user._id);
  },
});
