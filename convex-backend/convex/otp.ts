// ============================================================
// DEPRECATED: Replaced by Clerk OTP
// ============================================================
// This file contains custom OTP management logic that has been
// replaced by Clerk's built-in OTP verification.
//
// Kept for rollback purposes and reference.
// ============================================================

import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Mutation: Create new OTP code
export const createOtpCode = mutation({
  args: {
    destination: v.string(), // email or phone number
    code: v.string(),
  },
  handler: async (ctx, { destination, code }) => {
    // Invalidate any existing OTP codes for this destination
    const existingCodes = await ctx.db
      .query("otpCodes")
      .withIndex("by_destination", (q) => q.eq("destination", destination))
      .take(10);

    await Promise.all(existingCodes.map(c => ctx.db.delete(c._id)));

    // Create new OTP code (expires in 10 minutes)
    const otpId = await ctx.db.insert("otpCodes", {
      destination,
      code,
      expiresAt: Date.now() + 10 * 60 * 1000, // 10 minutes
      verified: false,
      attempts: 0,
      createdAt: Date.now(),
    });

    return otpId;
  },
});

// Query: Get OTP code by destination
export const getOtpByDestination = query({
  args: { destination: v.string() },
  handler: async (ctx, { destination }) => {
    const otp = await ctx.db
      .query("otpCodes")
      .withIndex("by_destination", (q) => q.eq("destination", destination))
      .filter((q) => q.eq(q.field("verified"), false))
      .first();

    return otp;
  },
});

// Mutation: Increment OTP verification attempts
export const incrementOtpAttempts = mutation({
  args: { otpId: v.string() },
  handler: async (ctx, { otpId }) => {
    const otp = await ctx.db.get(otpId as any);
    if (!otp) {
      throw new Error("OTP not found");
    }

    await ctx.db.patch(otpId as any, {
      attempts: otp.attempts + 1,
    });
  },
});

// Mutation: Mark OTP as verified
export const markOtpVerified = mutation({
  args: { otpId: v.string() },
  handler: async (ctx, { otpId }) => {
    await ctx.db.patch(otpId as any, {
      verified: true,
    });
  },
});

// Mutation: Delete expired OTP codes (cleanup)
export const cleanupExpiredOtps = mutation({
  args: {},
  handler: async (ctx) => {
    const now = Date.now();
    // Limit to prevent timeout on large cleanup batches
    const expiredCodes = await ctx.db
      .query("otpCodes")
      .filter((q) => q.lt(q.field("expiresAt"), now))
      .take(100);

    await Promise.all(expiredCodes.map(code => ctx.db.delete(code._id)));

    return expiredCodes.length;
  },
});
