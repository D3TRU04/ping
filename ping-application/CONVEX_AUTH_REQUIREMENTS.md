# Convex Auth Backend Requirements

**Status:** ⚠️ NOT IMPLEMENTED YET

The Swift app has been migrated to use Convex Auth, but the backend HTTP actions need to be implemented.

---

## Required Files

### 1. Update Schema (`convex/schema.ts`)

Add email and password fields to the `users` table:

```typescript
users: defineTable({
  // Existing fields
  supabaseId: v.optional(v.string()), // Keep for migration reference
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

  // NEW: Auth fields
  email: v.string(),
  passwordHash: v.string(),
})
  .index("by_username", ["username"])
  .index("by_supabase_id", ["supabaseId"])
  .index("by_email", ["email"]);  // NEW index

// NEW: Auth sessions table
authSessions: defineTable({
  userId: v.id("users"),
  token: v.string(),  // JWT token (for revocation checking)
  refreshToken: v.string(),
  expiresAt: v.number(),
  createdAt: v.number(),
})
  .index("by_user", ["userId"])
  .index("by_token", ["token"])
  .index("by_refresh_token", ["refreshToken"]);
```

---

## Required HTTP Actions

### 2. Create `convex/http.ts`

```typescript
import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { api } from "./_generated/api";

const http = httpRouter();

// POST /signUp
http.route({
  path: "/signUp",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const { email, password } = await request.json();

    // Validate input
    if (!email || !password) {
      return new Response(
        JSON.stringify({ message: "Email and password required" }),
        { status: 400 }
      );
    }

    // Check if user already exists
    const existing = await ctx.runQuery(api.auth.checkUserExists, { email });
    if (existing) {
      return new Response(
        JSON.stringify({ message: "Email already registered" }),
        { status: 400 }
      );
    }

    // Create user and session
    const result = await ctx.runMutation(api.auth.signUp, { email, password });

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// POST /signIn
http.route({
  path: "/signIn",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const { email, password } = await request.json();

    // Validate credentials
    const result = await ctx.runMutation(api.auth.signIn, { email, password });

    if (!result) {
      return new Response(
        JSON.stringify({ message: "Invalid email or password" }),
        { status: 401 }
      );
    }

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// POST /signOut
http.route({
  path: "/signOut",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const authHeader = request.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ message: "No token provided" }),
        { status: 401 }
      );
    }

    const token = authHeader.replace("Bearer ", "");
    await ctx.runMutation(api.auth.signOut, { token });

    return new Response(JSON.stringify({}), { status: 200 });
  }),
});

// POST /refreshToken
http.route({
  path: "/refreshToken",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const { refreshToken } = await request.json();

    const result = await ctx.runMutation(api.auth.refreshToken, { refreshToken });

    if (!result) {
      return new Response(
        JSON.stringify({ message: "Invalid refresh token" }),
        { status: 401 }
      );
    }

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }),
});

export default http;
```

---

## Required Mutations & Queries

### 3. Create `convex/auth.ts`

```typescript
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import bcrypt from "bcryptjs";  // npm install bcryptjs
import jwt from "jsonwebtoken";  // npm install jsonwebtoken

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
    { type: "refresh" },
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
    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user
    const userId = await ctx.db.insert("users", {
      email,
      passwordHash,
      username: email.split("@")[0],  // Default username
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
      expiresAt: Date.now() + 3600000,  // 1 hour
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

    if (!user) return null;

    // Verify password
    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) return null;

    // Generate tokens
    const token = generateToken(user._id);
    const refreshToken = generateRefreshToken();

    // Create session
    await ctx.db.insert("authSessions", {
      userId: user._id,
      token,
      refreshToken,
      expiresAt: Date.now() + 3600000,  // 1 hour
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
      .withIndex("by_refresh_token", (q) => q.eq("refreshToken", refreshToken))
      .first();

    if (!session) return null;

    // Generate new tokens
    const newToken = generateToken(session.userId);
    const newRefreshToken = generateRefreshToken();

    // Update session
    await ctx.db.patch(session._id, {
      token: newToken,
      refreshToken: newRefreshToken,
      expiresAt: Date.now() + 3600000,  // 1 hour
    });

    return { token: newToken, refreshToken: newRefreshToken, userId: session.userId };
  },
});
```

---

## Required User Queries

### 4. Create `convex/users.ts`

```typescript
import { query } from "./_generated/server";
import { v } from "convex/values";

// Get current user from auth context
export const getCurrentUser = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");

    const userId = identity.subject;
    const user = await ctx.db.get(userId);

    if (!user) throw new Error("User not found");

    // Don't return password hash
    const { passwordHash, ...safeUser } = user;
    return safeUser;
  },
});

// Get user by ID
export const getById = query({
  args: { userId: v.string() },
  handler: async (ctx, { userId }) => {
    const user = await ctx.db.get(userId);
    if (!user) throw new Error("User not found");

    const { passwordHash, ...safeUser } = user;
    return safeUser;
  },
});
```

---

## Environment Variables

Add to `convex-backend/.env.local`:

```bash
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
```

---

## Installation

```bash
cd convex-backend
npm install bcryptjs jsonwebtoken
npm install --save-dev @types/bcryptjs @types/jsonwebtoken
```

---

## Testing Endpoints

Once implemented, test with curl:

```bash
# Sign up
curl -X POST http://localhost:3000/signUp \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Sign in
curl -X POST http://localhost:3000/signIn \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Get current user (with token from sign in)
curl -X POST http://localhost:3000/api/query \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"path":"users:getCurrentUser","args":{}}'
```

---

## Next Steps

1. ✅ Swift app migrated to use Convex Auth
2. ⚠️ **Implement backend auth actions** (this document)
3. Test auth flow end-to-end
4. Migrate other services (places, chat, etc.)
