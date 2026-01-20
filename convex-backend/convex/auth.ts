// ============================================================
// DEPRECATED: Replaced by Clerk authentication
// ============================================================
// This file contains custom auth mutations and queries that
// have been replaced by Clerk. User creation, session management,
// and password verification are now handled by Clerk.
//
// Kept for rollback purposes and reference.
// ============================================================

import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Query: Get user by email (with password hash)
export const getUserByEmail = query({
  args: { email: v.string() },
  handler: async (ctx, { email }) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", email))
      .first();
    return user;
  },
});

// Query: Get user by phone number (with password hash)
export const getUserByPhoneNumber = query({
  args: { phoneNumber: v.string() },
  handler: async (ctx, { phoneNumber }) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_phone_number", (q) => q.eq("phoneNumber", phoneNumber))
      .first();
    return user;
  },
});

// Mutation: Create new user
export const createUser = mutation({
  args: {
    email: v.string(),
    passwordHash: v.string(),
    username: v.string(),
  },
  handler: async (ctx, { email, passwordHash, username }) => {
    const userId = await ctx.db.insert("users", {
      email,
      passwordHash,
      username,
      isOnboarded: false,
      createdAt: Date.now(),
    });
    return userId;
  },
});

// Mutation: Create new user with phone number
export const createUserWithPhone = mutation({
  args: {
    phoneNumber: v.string(),
    passwordHash: v.string(),
    username: v.string(),
  },
  handler: async (ctx, { phoneNumber, passwordHash, username }) => {
    const userId = await ctx.db.insert("users", {
      phoneNumber,
      passwordHash,
      username,
      isOnboarded: false,
      createdAt: Date.now(),
    });
    return userId;
  },
});

// Mutation: Create auth session
export const createSession = mutation({
  args: {
    userId: v.string(),
    token: v.string(),
    refreshToken: v.string(),
  },
  handler: async (ctx, { userId, token, refreshToken }) => {
    await ctx.db.insert("authSessions", {
      userId: userId as any,
      token,
      refreshToken,
      expiresAt: Date.now() + 3600000, // 1 hour
      createdAt: Date.now(),
    });
  },
});

// Mutation: Sign out (invalidate session)
export const signOut = mutation({
  args: { token: v.string() },
  handler: async (ctx, { token }) => {
    const session = await ctx.db
      .query("authSessions")
      .withIndex("by_token", (q) => q.eq("token", token))
      .first();

    if (session) {
      await ctx.db.delete(session._id);
    }
  },
});

// Mutation: Refresh access token (called from action)
export const updateSession = mutation({
  args: {
    sessionId: v.string(),
    token: v.string(),
    refreshToken: v.string(),
  },
  handler: async (ctx, { sessionId, token, refreshToken }) => {
    await ctx.db.patch(sessionId as any, {
      token,
      refreshToken,
      expiresAt: Date.now() + 3600000,
    });
  },
});

// Query: Get session by refresh token
export const getSessionByRefreshToken = query({
  args: { refreshToken: v.string() },
  handler: async (ctx, { refreshToken }) => {
    const session = await ctx.db
      .query("authSessions")
      .withIndex("by_refresh_token", (q) =>
        q.eq("refreshToken", refreshToken)
      )
      .first();
    return session;
  },
});
