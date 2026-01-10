import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // ID Mapping table for Supabase UUID -> Convex _id resolution
  // This enables idempotent imports and foreign key resolution
  idMappings: defineTable({
    supabaseId: v.string(), // Original Supabase UUID
    convexId: v.string(), // Convex document _id (stored as string)
    tableName: v.string(), // Which collection this mapping is for
  })
    .index("by_supabase_id", ["supabaseId", "tableName"])
    .index("by_convex_id", ["convexId"]),

  // Users (migrated from Supabase profiles table + auth fields)
  users: defineTable({
    // Auth fields (NEW - optional for migrated users)
    email: v.optional(v.string()),
    passwordHash: v.optional(v.string()),

    // Legacy migration field
    supabaseId: v.optional(v.string()), // For migrated users

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

  // Places (merged from 7 Supabase tables)
  places: defineTable({
    name: v.string(),
    category: v.string(),
    subcategory: v.optional(v.string()),
    location: v.string(),
    lat: v.number(),
    lng: v.number(),
    rating: v.optional(v.number()),
    priceRange: v.optional(v.string()),
    hours: v.optional(v.string()),
    description: v.optional(v.string()),
    imageUrl: v.optional(v.string()),
    websiteUrl: v.optional(v.string()),
    insertedAt: v.number(),
  })
    .index("by_category", ["category"])
    .index("by_name", ["name"]),

  // Follows
  follows: defineTable({
    followerId: v.id("users"),
    followingId: v.id("users"),
    createdAt: v.number(),
  })
    .index("by_follower", ["followerId"])
    .index("by_following", ["followingId"])
    .index("by_pair", ["followerId", "followingId"]),

  // Groups
  groups: defineTable({
    supabaseId: v.string(), // Supabase group.id
    name: v.string(),
    createdBy: v.id("users"),
    createdAt: v.number(),
  })
    .index("by_creator", ["createdBy"])
    .index("by_supabase_id", ["supabaseId"]),

  // Group Members
  groupMembers: defineTable({
    groupId: v.id("groups"),
    userId: v.id("users"),
    role: v.optional(v.string()), // "admin" | "member"
    joinedAt: v.number(),
  })
    .index("by_group", ["groupId"])
    .index("by_user", ["userId"])
    .index("by_pair", ["groupId", "userId"]),

  // Messages
  messages: defineTable({
    senderId: v.id("users"),
    receiverId: v.optional(v.id("users")), // For DMs
    groupId: v.optional(v.id("groups")), // For group messages
    conversationId: v.optional(v.string()), // Thread ID for 1-on-1 DMs
    message: v.string(),
    isRead: v.boolean(),
    createdAt: v.number(),
  })
    .index("by_group", ["groupId"])
    .index("by_sender", ["senderId"])
    .index("by_receiver", ["receiverId"])
    .index("by_conversation", ["conversationId"]),

  // Notifications
  notifications: defineTable({
    recipientId: v.id("users"),
    senderId: v.optional(v.id("users")),
    type: v.string(),
    title: v.string(),
    message: v.string(),
    metadata: v.optional(v.any()),
    isRead: v.boolean(),
    createdAt: v.number(),
  })
    .index("by_recipient", ["recipientId"])
    .index("by_recipient_unread", ["recipientId", "isRead"])
    .index("by_sender", ["senderId"]),

  // Notification Settings
  notificationSettings: defineTable({
    userId: v.id("users"),
    pushEnabled: v.boolean(),
    emailEnabled: v.boolean(),
    followNotifications: v.boolean(),
    messageNotifications: v.boolean(),
    groupNotifications: v.boolean(),
  }).index("by_user", ["userId"]),

  // User Place Visits
  userPlaceVisits: defineTable({
    userId: v.id("users"),
    placeId: v.id("places"),
    placeName: v.string(), // Denormalized for performance
    placeImage: v.optional(v.string()), // Denormalized for performance
    visitDate: v.number(),
    createdAt: v.number(),
  })
    .index("by_user", ["userId"])
    .index("by_place", ["placeId"])
    .index("by_pair", ["userId", "placeId"]),

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
});
