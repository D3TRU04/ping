// ============================================================
// DEPRECATED: Replaced by Clerk authentication
// ============================================================
// This file contains custom authentication logic that has been
// replaced by Clerk. All auth actions (signup, signin, OTP)
// are now handled by Clerk's infrastructure.
//
// Kept for rollback purposes and reference.
// ============================================================

"use node";

import { action } from "./_generated/server";
import { v } from "convex/values";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { api } from "./_generated/api";

// Helper: Generate 6-digit OTP code
function generateOtpCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Helper: Generate JWT
function generateToken(userId: string): string {
  return jwt.sign({ sub: userId }, process.env.JWT_SECRET!, {
    expiresIn: "1h",
  });
}

// Helper: Generate refresh token
function generateRefreshToken(): string {
  return jwt.sign(
    { type: "refresh", nonce: Math.random() },
    process.env.JWT_SECRET!,
    { expiresIn: "7d" }
  );
}

// Action: Sign up new user
export const signUpAction = action({
  args: { email: v.string(), password: v.string() },
  handler: async (ctx, { email, password }) => {
    // Validate password strength
    if (password.length < 8) {
      throw new Error("Password must be at least 8 characters");
    }

    // Check if user already exists
    const existing = await ctx.runQuery(api.auth.getUserByEmail, { email });
    if (existing) {
      throw new Error("Email already registered");
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user via mutation
    const userId = await ctx.runMutation(api.auth.createUser, {
      email,
      passwordHash,
      username: email.split("@")[0],
    });

    // Generate tokens
    const token = generateToken(userId);
    const refreshToken = generateRefreshToken();

    // Create session via mutation
    await ctx.runMutation(api.auth.createSession, {
      userId,
      token,
      refreshToken,
    });

    return { token, refreshToken, userId };
  },
});

// Action: Sign up new user with phone number
export const signUpWithPhoneAction = action({
  args: { phoneNumber: v.string(), password: v.string() },
  handler: async (ctx, { phoneNumber, password }) => {
    // Validate password strength
    if (password.length < 8) {
      throw new Error("Password must be at least 8 characters");
    }

    // Validate phone number format (basic validation)
    const cleanPhone = phoneNumber.replace(/\D/g, "");
    if (cleanPhone.length < 10) {
      throw new Error("Please enter a valid phone number");
    }

    // Check if phone number already exists
    const existing = await ctx.runQuery(api.auth.getUserByPhoneNumber, {
      phoneNumber: cleanPhone,
    });
    if (existing) {
      throw new Error("Phone number already registered");
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user via mutation
    // Generate username from phone number (last 6 digits + random suffix)
    const username = `user${cleanPhone.slice(-6)}${Math.floor(Math.random() * 1000)}`;

    const userId = await ctx.runMutation(api.auth.createUserWithPhone, {
      phoneNumber: cleanPhone,
      passwordHash,
      username,
    });

    // Generate tokens
    const token = generateToken(userId);
    const refreshToken = generateRefreshToken();

    // Create session via mutation
    await ctx.runMutation(api.auth.createSession, {
      userId,
      token,
      refreshToken,
    });

    return { token, refreshToken, userId };
  },
});

// Action: Sign in existing user
export const signInAction = action({
  args: { email: v.string(), password: v.string() },
  handler: async (ctx, { email, password }) => {
    // Find user
    const user = await ctx.runQuery(api.auth.getUserByEmail, { email });
    if (!user) {
      throw new Error("Invalid email or password");
    }

    // Verify password
    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) {
      throw new Error("Invalid email or password");
    }

    // Generate tokens
    const token = generateToken(user._id);
    const refreshToken = generateRefreshToken();

    // Create session
    await ctx.runMutation(api.auth.createSession, {
      userId: user._id,
      token,
      refreshToken,
    });

    return { token, refreshToken, userId: user._id };
  },
});

// Action: Verify JWT token
export const verifyTokenAction = action({
  args: { token: v.string() },
  handler: async (ctx, { token }) => {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as {
        sub: string;
      };
      return decoded.sub;
    } catch (error) {
      return null;
    }
  },
});

// Action: Refresh access token
export const refreshTokenAction = action({
  args: { refreshToken: v.string() },
  handler: async (ctx, { refreshToken }) => {
    // Find session by refresh token
    const session = await ctx.runQuery(api.auth.getSessionByRefreshToken, {
      refreshToken,
    });

    if (!session) {
      throw new Error("Invalid refresh token");
    }

    // Generate new tokens
    const newToken = generateToken(session.userId);
    const newRefreshToken = generateRefreshToken();

    // Update session
    await ctx.runMutation(api.auth.updateSession, {
      sessionId: session._id,
      token: newToken,
      refreshToken: newRefreshToken,
    });

    return {
      token: newToken,
      refreshToken: newRefreshToken,
      userId: session.userId,
    };
  },
});

// Action: Send OTP code
export const sendOtpAction = action({
  args: {
    destination: v.string(), // email or phone number
    type: v.union(v.literal("email"), v.literal("phone")),
  },
  handler: async (ctx, { destination, type }) => {
    // Clean phone number if it's a phone type
    const cleanDestination =
      type === "phone" ? destination.replace(/\D/g, "") : destination;

    // Validate destination
    if (type === "phone" && cleanDestination.length < 10) {
      throw new Error("Please enter a valid phone number");
    }
    if (type === "email" && !destination.includes("@")) {
      throw new Error("Please enter a valid email address");
    }

    // Generate 6-digit OTP code
    const code = generateOtpCode();

    // Store OTP in database
    await ctx.runMutation(api.otp.createOtpCode, {
      destination: cleanDestination,
      code,
    });

    // In production, you would send the code via SMS/Email here
    // For now, we'll return it for development/testing
    console.log(`🔐 OTP Code for ${cleanDestination}: ${code}`);

    // Return success (in production, don't return the code)
    return {
      success: true,
      destination: cleanDestination,
      // DEVELOPMENT ONLY: Remove this in production
      code: process.env.NODE_ENV === "development" ? code : undefined,
    };
  },
});

// Action: Verify OTP code
export const verifyOtpAction = action({
  args: {
    destination: v.string(),
    code: v.string(),
  },
  handler: async (ctx, { destination, code }) => {
    // Clean destination (remove non-digits from phone numbers)
    const cleanDestination = destination.replace(/\D/g, "");

    // Get OTP from database
    const otp = await ctx.runQuery(api.otp.getOtpByDestination, {
      destination: cleanDestination,
    });

    if (!otp) {
      throw new Error("No verification code found. Please request a new code.");
    }

    // Check if OTP has expired
    if (Date.now() > otp.expiresAt) {
      throw new Error("Verification code has expired. Please request a new code.");
    }

    // Check max attempts (prevent brute force)
    if (otp.attempts >= 5) {
      throw new Error("Too many failed attempts. Please request a new code.");
    }

    // Verify code
    if (otp.code !== code) {
      // Increment attempts
      await ctx.runMutation(api.otp.incrementOtpAttempts, {
        otpId: otp._id,
      });
      throw new Error("Invalid verification code. Please try again.");
    }

    // Mark OTP as verified
    await ctx.runMutation(api.otp.markOtpVerified, {
      otpId: otp._id,
    });

    return {
      success: true,
      verified: true,
    };
  },
});
