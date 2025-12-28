# Convex Auth Files - Copy These

## File 1: convex-backend/convex/schema.ts

**REPLACE the users table definition (lines 15-32) with:**

```typescript
// Users (migrated from Supabase profiles table + auth fields)
users: defineTable({
  // Auth fields (NEW)
  email: v.string(),
  passwordHash: v.string(),

  // Legacy migration field
  supabaseId: v.optional(v.string()), // Made optional for new users

  // Profile fields
  username: v.string(),
  fullName: v.optional(v.string()),
  bio: v.optional(v.string()),
  profilePicture: v.optional(v.string()),
  birthday: v.optional(v.string()),
  phoneNumber: v.optional(v.string()),
  location: v.optional(v.string()),
  pronouns: v.optional(v.string()),
  links: v.optional(v.array(v.string())),
  categoryPreferences: v.optional(v.record(v.string(), v.array(v.string()))),
  isOnboarded: v.boolean(),
  createdAt: v.number(),
})
  .index("by_username", ["username"])
  .index("by_email", ["email"])  // NEW index
  .index("by_supabase_id", ["supabaseId"]),
```

**ADD this NEW table BEFORE the closing `});` (after userPlaceVisits):**

```typescript
// Auth Sessions (NEW)
authSessions: defineTable({
  userId: v.id("users"),
  token: v.string(),
  refreshToken: v.string(),
  expiresAt: v.number(),
  createdAt: v.number(),
})
  .index("by_user", ["userId"])
  .index("by_token", ["token"])
  .index("by_refresh_token", ["refreshToken"]),
```

---

## File 2: convex-backend/convex/auth.ts (NEW FILE - CREATE THIS)

```typescript
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

// Helper: Generate JWT
function generateToken(userId: string): string {
  return jwt.sign(
    { sub: userId },
    process.env.JWT_SECRET!,
    { expiresIn: "1h" }
  );
}

// Helper: Generate refresh token
function generateRefreshToken(): string {
  return jwt.sign(
    { type: "refresh", nonce: Math.random() },
    process.env.JWT_SECRET!,
    { expiresIn: "7d" }
  );
}

// Check if user exists by email
export const checkUserExists = query({
  args: { email: v.string() },
  handler: async (ctx, { email }) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", email))
      .first();
    return user !== null;
  },
});

// Sign up new user
export const signUp = mutation({
  args: { email: v.string(), password: v.string() },
  handler: async (ctx, { email, password }) => {
    // Validate password strength
    if (password.length < 8) {
      throw new Error("Password must be at least 8 characters");
    }

    // Check if user already exists
    const existing = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", email))
      .first();

    if (existing) {
      throw new Error("Email already registered");
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user
    const userId = await ctx.db.insert("users", {
      email,
      passwordHash,
      username: email.split("@")[0], // Default username from email
      isOnboarded: false,
      createdAt: Date.now(),
    });

    // Generate tokens
    const token = generateToken(userId);
    const refreshToken = generateRefreshToken();

    // Create session
    await ctx.db.insert("authSessions", {
      userId,
      token,
      refreshToken,
      expiresAt: Date.now() + 3600000, // 1 hour
      createdAt: Date.now(),
    });

    return { token, refreshToken, userId };
  },
});

// Sign in existing user
export const signIn = mutation({
  args: { email: v.string(), password: v.string() },
  handler: async (ctx, { email, password }) => {
    // Find user
    const user = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", email))
      .first();

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
    await ctx.db.insert("authSessions", {
      userId: user._id,
      token,
      refreshToken,
      expiresAt: Date.now() + 3600000, // 1 hour
      createdAt: Date.now(),
    });

    return { token, refreshToken, userId: user._id };
  },
});

// Sign out (invalidate session)
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

// Refresh access token
export const refreshToken = mutation({
  args: { refreshToken: v.string() },
  handler: async (ctx, { refreshToken }) => {
    // Find session by refresh token
    const session = await ctx.db
      .query("authSessions")
      .withIndex("by_refresh_token", (q) =>
        q.eq("refreshToken", refreshToken)
      )
      .first();

    if (!session) {
      throw new Error("Invalid refresh token");
    }

    // Generate new tokens
    const newToken = generateToken(session.userId);
    const newRefreshToken = generateRefreshToken();

    // Update session
    await ctx.db.patch(session._id, {
      token: newToken,
      refreshToken: newRefreshToken,
      expiresAt: Date.now() + 3600000, // 1 hour
    });

    return {
      token: newToken,
      refreshToken: newRefreshToken,
      userId: session.userId,
    };
  },
});

// Helper: Verify JWT and get user ID
export const verifyToken = query({
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
```

---

## File 3: convex-backend/convex/users.ts (NEW FILE - CREATE THIS)

```typescript
import { query } from "./_generated/server";
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
```

---

## File 4: convex-backend/convex/http.ts (NEW FILE - CREATE THIS)

```typescript
import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { api } from "./_generated/api";
import jwt from "jsonwebtoken";

const http = httpRouter();

// POST /signUp
http.route({
  path: "/signUp",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const { email, password } = await request.json();

      // Validate input
      if (!email || !password) {
        return new Response(
          JSON.stringify({ message: "Email and password required" }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }

      // Create user and session
      const result = await ctx.runMutation(api.auth.signUp, {
        email,
        password,
      });

      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error: any) {
      return new Response(
        JSON.stringify({ message: error.message || "Signup failed" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});

// POST /signIn
http.route({
  path: "/signIn",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const { email, password } = await request.json();

      // Validate credentials
      const result = await ctx.runMutation(api.auth.signIn, {
        email,
        password,
      });

      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error: any) {
      return new Response(
        JSON.stringify({
          message: error.message || "Invalid email or password",
        }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});

// POST /signOut
http.route({
  path: "/signOut",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const authHeader = request.headers.get("Authorization");
      if (!authHeader) {
        return new Response(
          JSON.stringify({ message: "No token provided" }),
          { status: 401, headers: { "Content-Type": "application/json" } }
        );
      }

      const token = authHeader.replace("Bearer ", "");
      await ctx.runMutation(api.auth.signOut, { token });

      return new Response(JSON.stringify({}), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error: any) {
      return new Response(
        JSON.stringify({ message: error.message || "Logout failed" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});

// POST /refreshToken
http.route({
  path: "/refreshToken",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const { refreshToken } = await request.json();

      if (!refreshToken) {
        return new Response(
          JSON.stringify({ message: "Refresh token required" }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }

      const result = await ctx.runMutation(api.auth.refreshToken, {
        refreshToken,
      });

      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error: any) {
      return new Response(
        JSON.stringify({
          message: error.message || "Invalid refresh token",
        }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});

// GET /api/me - Get current user profile
http.route({
  path: "/api/me",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const authHeader = request.headers.get("Authorization");
      if (!authHeader) {
        return new Response(
          JSON.stringify({ message: "No token provided" }),
          { status: 401, headers: { "Content-Type": "application/json" } }
        );
      }

      const token = authHeader.replace("Bearer ", "");

      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as {
        sub: string;
      };
      const userId = decoded.sub;

      // Get user
      const user = await ctx.runQuery(api.users.getById, { userId });

      return new Response(JSON.stringify(user), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error: any) {
      return new Response(
        JSON.stringify({ message: "Unauthorized" }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});

export default http;
```

---

## Implementation Steps:

1. Run: `npm install bcryptjs jsonwebtoken @types/bcryptjs @types/jsonwebtoken`
2. Add `JWT_SECRET` to `.env.local`
3. Update `schema.ts` (users table + add authSessions table)
4. Create `auth.ts` file
5. Create `users.ts` file
6. Create `http.ts` file
7. Run: `npx convex dev` to deploy

---

## Your Convex Deployment URL:

```
https://cheerful-hornet-764.convex.cloud
```

This will be used in the Swift app's `CONVEX_DEPLOYMENT_URL`.
