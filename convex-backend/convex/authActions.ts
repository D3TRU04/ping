"use node";

import { action } from "./_generated/server";
import { v } from "convex/values";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { api } from "./_generated/api";

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
