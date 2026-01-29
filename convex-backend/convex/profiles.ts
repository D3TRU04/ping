import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

// ==================== PROFILE QUERIES ====================

// Get user profile by ID
export const getProfile = query({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    const user = await ctx.db.get(userId);

    if (!user) {
      throw new Error("Profile not found");
    }

    // Don't return sensitive fields
    const { passwordHash, email, ...profile } = user;

    return profile;
  },
});

// Get user profile by username
export const getProfileByUsername = query({
  args: { username: v.string() },
  handler: async (ctx, { username }) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_username", (q) => q.eq("username", username))
      .first();

    if (!user) {
      return null;
    }

    const { passwordHash, email, ...profile } = user;
    return profile;
  },
});

// Check if username is available
export const checkUsernameAvailability = query({
  args: { username: v.string() },
  handler: async (ctx, { username }) => {
    const existingUser = await ctx.db
      .query("users")
      .withIndex("by_username", (q) => q.eq("username", username))
      .first();

    return existingUser === null;
  },
});

// Get followers for a user (users who follow this user)
export const getFollowers = query({
  args: {
    userId: v.id("users"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { userId, limit = 100 }) => {
    const follows = await ctx.db
      .query("follows")
      .withIndex("by_following", (q) => q.eq("followingId", userId))
      .take(limit);

    // Batch fetch all follower users at once
    const users = await Promise.all(
      follows.map(follow => ctx.db.get(follow.followerId))
    );

    return users
      .filter((user): user is NonNullable<typeof user> => user !== null)
      .map(user => {
        const { passwordHash, email, ...safeUser } = user;
        return safeUser;
      });
  },
});

// Get following for a user (users this user follows)
export const getFollowing = query({
  args: {
    userId: v.id("users"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { userId, limit = 100 }) => {
    const follows = await ctx.db
      .query("follows")
      .withIndex("by_follower", (q) => q.eq("followerId", userId))
      .take(limit);

    // Batch fetch all following users at once
    const users = await Promise.all(
      follows.map(follow => ctx.db.get(follow.followingId))
    );

    return users
      .filter((user): user is NonNullable<typeof user> => user !== null)
      .map(user => {
        const { passwordHash, email, ...safeUser } = user;
        return safeUser;
      });
  },
});

// Check if user A follows user B
export const isFollowing = query({
  args: {
    followerId: v.id("users"),
    followingId: v.id("users")
  },
  handler: async (ctx, { followerId, followingId }) => {
    const follow = await ctx.db
      .query("follows")
      .withIndex("by_pair", (q) =>
        q.eq("followerId", followerId).eq("followingId", followingId)
      )
      .first();

    return follow !== null;
  },
});

// Get follower and following counts
export const getFollowCounts = query({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    // Use take with limit instead of collect
    const [followers, following] = await Promise.all([
      ctx.db
        .query("follows")
        .withIndex("by_following", (q) => q.eq("followingId", userId))
        .take(10000),
      ctx.db
        .query("follows")
        .withIndex("by_follower", (q) => q.eq("followerId", userId))
        .take(10000),
    ]);

    return {
      followers: followers.length,
      following: following.length,
    };
  },
});

// Search users by username or fullName
// NOTE: For production, consider using Convex's search indexes for better performance
export const searchUsers = query({
  args: {
    query: v.string(),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { query, limit = 20 }) => {
    // Normalize query for consistent caching
    const normalizedQuery = query.trim().toLowerCase();

    if (!normalizedQuery || normalizedQuery.length < 2) {
      return [];
    }

    // First try exact username match via index (most efficient)
    const exactMatch = await ctx.db
      .query("users")
      .withIndex("by_username", (q) => q.eq("username", normalizedQuery))
      .first();

    const results: Array<{
      _id: any;
      username: string;
      fullName?: string;
      profilePicture?: string;
      bio?: string;
    }> = [];

    if (exactMatch) {
      results.push({
        _id: exactMatch._id,
        username: exactMatch.username,
        fullName: exactMatch.fullName,
        profilePicture: exactMatch.profilePicture,
        bio: exactMatch.bio,
      });
    }

    // For partial matches, limit the scan to reduce bandwidth
    // In production, use a full-text search index
    const users = await ctx.db.query("users").take(500);

    for (const user of users) {
      if (results.length >= limit) break;
      if (exactMatch && user._id === exactMatch._id) continue;

      const username = user.username?.toLowerCase() || "";
      const fullName = user.fullName?.toLowerCase() || "";

      if (username.includes(normalizedQuery) || fullName.includes(normalizedQuery)) {
        results.push({
          _id: user._id,
          username: user.username,
          fullName: user.fullName,
          profilePicture: user.profilePicture,
          bio: user.bio,
        });
      }
    }

    return results.slice(0, limit);
  },
});

// ==================== PROFILE MUTATIONS ====================

// Update user profile
export const updateProfile = mutation({
  args: {
    userId: v.id("users"),
    fullName: v.optional(v.string()),
    username: v.optional(v.string()),
    bio: v.optional(v.string()),
    profilePicture: v.optional(v.string()),
    birthday: v.optional(v.string()),
    phoneNumber: v.optional(v.string()),
    location: v.optional(v.string()),
    pronouns: v.optional(v.string()),
    links: v.optional(v.array(v.string())),
    // Stored as {categories: [categoryIds], subcategories: [subcategoryNames]}
    categoryPreferences: v.optional(
      v.object({
        categories: v.optional(v.array(v.string())),
        subcategories: v.optional(v.array(v.string())),
      })
    ),
  },
  handler: async (ctx, args) => {
    const { userId, ...updates } = args;

    // Check if user exists
    const existingUser = await ctx.db.get(userId);
    if (!existingUser) {
      throw new Error("User not found");
    }

    // If username is being updated, check availability
    if (updates.username && updates.username !== existingUser.username) {
      const usernameTaken = await ctx.db
        .query("users")
        .withIndex("by_username", (q) => q.eq("username", updates.username!))
        .first();

      if (usernameTaken) {
        throw new Error("Username already taken");
      }
    }

    // Filter out undefined values
    const filteredUpdates = Object.fromEntries(
      Object.entries(updates).filter(([_, value]) => value !== undefined)
    );

    // Update the user
    await ctx.db.patch(userId, filteredUpdates);

    // Return updated user
    const updatedUser = await ctx.db.get(userId);
    if (!updatedUser) {
      throw new Error("Failed to fetch updated user");
    }

    const { passwordHash, email, ...profile } = updatedUser;
    return profile;
  },
});

// Follow a user
export const followUser = mutation({
  args: {
    followerId: v.id("users"),
    followingId: v.id("users"),
  },
  handler: async (ctx, { followerId, followingId }) => {
    // Don't allow self-follow
    if (followerId === followingId) {
      throw new Error("Cannot follow yourself");
    }

    // Check if both users exist
    const [follower, following] = await Promise.all([
      ctx.db.get(followerId),
      ctx.db.get(followingId),
    ]);

    if (!follower) {
      throw new Error("Follower user not found");
    }
    if (!following) {
      throw new Error("Following user not found");
    }

    // Check if already following
    const existingFollow = await ctx.db
      .query("follows")
      .withIndex("by_pair", (q) =>
        q.eq("followerId", followerId).eq("followingId", followingId)
      )
      .first();

    if (existingFollow) {
      throw new Error("Already following this user");
    }

    // Create follow relationship
    const followId = await ctx.db.insert("follows", {
      followerId,
      followingId,
      createdAt: Date.now(),
    });

    // Create follow notification for the user being followed
    await ctx.db.insert("notifications", {
      recipientId: followingId,
      senderId: followerId,
      type: "follow",
      title: "New Follower",
      message: `${follower.fullName || follower.username} started following you`,
      metadata: {
        senderId: followerId,
        senderName: follower.fullName || follower.username,
      },
      isRead: false,
      createdAt: Date.now(),
    });

    return followId;
  },
});

// Unfollow a user
export const unfollowUser = mutation({
  args: {
    followerId: v.id("users"),
    followingId: v.id("users"),
  },
  handler: async (ctx, { followerId, followingId }) => {
    // Find the follow relationship
    const follow = await ctx.db
      .query("follows")
      .withIndex("by_pair", (q) =>
        q.eq("followerId", followerId).eq("followingId", followingId)
      )
      .first();

    if (!follow) {
      throw new Error("Not following this user");
    }

    // Delete the follow relationship
    await ctx.db.delete(follow._id);

    return { success: true };
  },
});
