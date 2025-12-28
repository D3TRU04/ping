import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { api } from "./_generated/api";

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
      const result = await ctx.runAction(api.authActions.signUpAction, {
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
      const result = await ctx.runAction(api.authActions.signInAction, {
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

      const result = await ctx.runAction(api.authActions.refreshTokenAction, {
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

      // Verify token using action
      const userId = await ctx.runAction(api.authActions.verifyTokenAction, {
        token,
      });

      if (!userId) {
        return new Response(
          JSON.stringify({ message: "Invalid or expired token" }),
          { status: 401, headers: { "Content-Type": "application/json" } }
        );
      }

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
