import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

// ==================== NOTIFICATION QUERIES ====================

// Get all notifications for a user
export const getNotifications = query({
  args: {
    userId: v.id("users"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { userId, limit = 50 }) => {
    const notifications = await ctx.db
      .query("notifications")
      .withIndex("by_recipient", (q) => q.eq("recipientId", userId))
      .order("desc")
      .take(limit);

    // Batch fetch all unique senders at once to avoid N+1 queries
    const senderIds = [...new Set(
      notifications
        .map(n => n.senderId)
        .filter((id): id is typeof id & {} => id !== undefined)
    )];

    const senders = await Promise.all(senderIds.map(id => ctx.db.get(id)));
    const senderMap = new Map(
      senders.filter(s => s).map(s => [s!._id.toString(), s!])
    );

    return notifications.map(notification => ({
      _id: notification._id,
      recipientId: notification.recipientId,
      senderId: notification.senderId,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      metadata: notification.metadata,
      isRead: notification.isRead,
      createdAt: notification.createdAt,
      sender: notification.senderId
        ? (() => {
            const s = senderMap.get(notification.senderId.toString());
            return s ? {
              _id: s._id,
              username: s.username,
              fullName: s.fullName,
              profilePicture: s.profilePicture,
            } : null;
          })()
        : null,
    }));
  },
});

// Get unread notification count
export const getUnreadCount = query({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    // Use take with a reasonable limit instead of collect to reduce bandwidth
    const unreadNotifications = await ctx.db
      .query("notifications")
      .withIndex("by_recipient_unread", (q) =>
        q.eq("recipientId", userId).eq("isRead", false)
      )
      .take(1000);

    return unreadNotifications.length;
  },
});

// Get unread notifications only
export const getUnreadNotifications = query({
  args: {
    userId: v.id("users"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { userId, limit = 50 }) => {
    const notifications = await ctx.db
      .query("notifications")
      .withIndex("by_recipient_unread", (q) =>
        q.eq("recipientId", userId).eq("isRead", false)
      )
      .order("desc")
      .take(limit);

    // Batch fetch all unique senders at once to avoid N+1 queries
    const senderIds = [...new Set(
      notifications
        .map(n => n.senderId)
        .filter((id): id is typeof id & {} => id !== undefined)
    )];

    const senders = await Promise.all(senderIds.map(id => ctx.db.get(id)));
    const senderMap = new Map(
      senders.filter(s => s).map(s => [s!._id.toString(), s!])
    );

    return notifications.map(notification => ({
      _id: notification._id,
      recipientId: notification.recipientId,
      senderId: notification.senderId,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      metadata: notification.metadata,
      isRead: notification.isRead,
      createdAt: notification.createdAt,
      sender: notification.senderId
        ? (() => {
            const s = senderMap.get(notification.senderId.toString());
            return s ? {
              _id: s._id,
              username: s.username,
              fullName: s.fullName,
              profilePicture: s.profilePicture,
            } : null;
          })()
        : null,
    }));
  },
});

// Get notification settings for a user
export const getNotificationSettings = query({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    const settings = await ctx.db
      .query("notificationSettings")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .first();

    if (!settings) {
      // Return default settings if none exist
      return {
        userId,
        pushEnabled: true,
        emailEnabled: true,
        followNotifications: true,
        groupNotifications: true,
      };
    }

    return {
      _id: settings._id,
      userId: settings.userId,
      pushEnabled: settings.pushEnabled,
      emailEnabled: settings.emailEnabled,
      followNotifications: settings.followNotifications,
      groupNotifications: settings.groupNotifications,
    };
  },
});

// ==================== NOTIFICATION MUTATIONS ====================

// Create a new notification
export const createNotification = mutation({
  args: {
    recipientId: v.id("users"),
    senderId: v.optional(v.id("users")),
    type: v.string(),
    title: v.string(),
    message: v.string(),
    metadata: v.optional(v.any()),
  },
  handler: async (ctx, { recipientId, senderId, type, title, message, metadata }) => {
    // Validate recipient exists
    const recipient = await ctx.db.get(recipientId);
    if (!recipient) {
      throw new Error("Recipient not found");
    }

    // Validate sender exists if provided
    if (senderId) {
      const sender = await ctx.db.get(senderId);
      if (!sender) {
        throw new Error("Sender not found");
      }
    }

    // Check user's notification settings
    const settings = await ctx.db
      .query("notificationSettings")
      .withIndex("by_user", (q) => q.eq("userId", recipientId))
      .first();

    // If user has disabled this type of notification, don't create it
    if (settings) {
      if (type === "follow" && !settings.followNotifications) return null;
      if (type === "group" && !settings.groupNotifications) return null;
    }

    // Create notification
    const notificationId = await ctx.db.insert("notifications", {
      recipientId,
      senderId,
      type,
      title,
      message,
      metadata,
      isRead: false,
      createdAt: Date.now(),
    });

    return notificationId;
  },
});

// Mark a notification as read
export const markAsRead = mutation({
  args: { notificationId: v.id("notifications") },
  handler: async (ctx, { notificationId }) => {
    const notification = await ctx.db.get(notificationId);
    if (!notification) {
      throw new Error("Notification not found");
    }

    await ctx.db.patch(notificationId, { isRead: true });

    return { success: true };
  },
});

// Mark all notifications as read for a user
export const markAllAsRead = mutation({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    // Limit to prevent timeout on large datasets
    const unreadNotifications = await ctx.db
      .query("notifications")
      .withIndex("by_recipient_unread", (q) =>
        q.eq("recipientId", userId).eq("isRead", false)
      )
      .take(500);

    // Mark all as read
    await Promise.all(
      unreadNotifications.map((notification) =>
        ctx.db.patch(notification._id, { isRead: true })
      )
    );

    return { count: unreadNotifications.length };
  },
});

// Delete a notification
export const deleteNotification = mutation({
  args: { notificationId: v.id("notifications") },
  handler: async (ctx, { notificationId }) => {
    const notification = await ctx.db.get(notificationId);
    if (!notification) {
      throw new Error("Notification not found");
    }

    await ctx.db.delete(notificationId);

    return { success: true };
  },
});

// Delete all notifications for a user
export const deleteAllNotifications = mutation({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    // Limit to prevent timeout on large datasets
    const notifications = await ctx.db
      .query("notifications")
      .withIndex("by_recipient", (q) => q.eq("recipientId", userId))
      .take(500);

    // Delete all notifications
    await Promise.all(
      notifications.map((notification) => ctx.db.delete(notification._id))
    );

    return { count: notifications.length };
  },
});

// Update notification settings
export const updateNotificationSettings = mutation({
  args: {
    userId: v.id("users"),
    pushEnabled: v.optional(v.boolean()),
    emailEnabled: v.optional(v.boolean()),
    followNotifications: v.optional(v.boolean()),
    groupNotifications: v.optional(v.boolean()),
  },
  handler: async (ctx, args) => {
    const { userId, ...updates } = args;

    // Check if settings exist
    const existingSettings = await ctx.db
      .query("notificationSettings")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .first();

    // Filter out undefined values
    const filteredUpdates = Object.fromEntries(
      Object.entries(updates).filter(([_, value]) => value !== undefined)
    );

    if (existingSettings) {
      // Update existing settings
      await ctx.db.patch(existingSettings._id, filteredUpdates);
      return existingSettings._id;
    } else {
      // Create new settings with defaults
      const settingsId = await ctx.db.insert("notificationSettings", {
        userId,
        pushEnabled: updates.pushEnabled ?? true,
        emailEnabled: updates.emailEnabled ?? true,
        followNotifications: updates.followNotifications ?? true,
        groupNotifications: updates.groupNotifications ?? true,
      });
      return settingsId;
    }
  },
});

// ==================== HELPER MUTATIONS ====================

// Send a follow notification
export const sendFollowNotification = mutation({
  args: {
    followerId: v.id("users"),
    followingId: v.id("users"),
  },
  handler: async (ctx, { followerId, followingId }) => {
    const follower = await ctx.db.get(followerId);
    if (!follower) throw new Error("Follower not found");

    const notificationId = await ctx.db.insert("notifications", {
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

    return notificationId;
  },
});

