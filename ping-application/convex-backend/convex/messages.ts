import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

// ==================== CONVERSATION QUERIES ====================

// Get all DM conversations for a user
export const getConversations = query({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    // Get all messages where user is sender or receiver
    const sentMessages = await ctx.db
      .query("messages")
      .withIndex("by_sender", (q) => q.eq("senderId", userId))
      .filter((q) => q.neq(q.field("conversationId"), undefined))
      .collect();

    const receivedMessages = await ctx.db
      .query("messages")
      .withIndex("by_receiver", (q) => q.eq("receiverId", userId))
      .filter((q) => q.neq(q.field("conversationId"), undefined))
      .collect();

    // Combine and get unique conversation IDs
    const allMessages = [...sentMessages, ...receivedMessages];
    const conversationIds = new Set(
      allMessages
        .map((m) => m.conversationId)
        .filter((id): id is string => id !== undefined)
    );

    // For each conversation, get the other user and latest message
    const conversations = await Promise.all(
      Array.from(conversationIds).map(async (conversationId) => {
        // Get all messages in this conversation
        const messages = allMessages.filter(
          (m) => m.conversationId === conversationId
        );

        // Sort by createdAt to get latest message
        messages.sort((a, b) => b.createdAt - a.createdAt);
        const latestMessage = messages[0];

        // Determine the other user in the conversation
        const otherUserId =
          latestMessage.senderId === userId
            ? latestMessage.receiverId
            : latestMessage.senderId;

        if (!otherUserId) return null;

        // Get other user's details
        const otherUser = await ctx.db.get(otherUserId);
        if (!otherUser) return null;

        // Count unread messages
        const unreadCount = messages.filter(
          (m) => m.receiverId === userId && !m.isRead
        ).length;

        return {
          conversationId,
          otherUser: {
            _id: otherUser._id,
            username: otherUser.username,
            fullName: otherUser.fullName,
            profilePicture: otherUser.profilePicture,
          },
          latestMessage: {
            text: latestMessage.message,
            createdAt: latestMessage.createdAt,
            senderId: latestMessage.senderId,
          },
          unreadCount,
          updatedAt: latestMessage.createdAt,
        };
      })
    );

    // Filter out nulls and sort by latest message
    return conversations
      .filter((c) => c !== null)
      .sort((a, b) => b.updatedAt - a.updatedAt);
  },
});

// Get or create a conversation between two users
export const getOrCreateConversation = query({
  args: {
    userId1: v.id("users"),
    userId2: v.id("users"),
  },
  handler: async (ctx, { userId1, userId2 }) => {
    // Don't allow conversation with self
    if (userId1 === userId2) {
      throw new Error("Cannot create conversation with yourself");
    }

    // Create a deterministic conversation ID (sorted user IDs)
    const sortedIds = [userId1, userId2].sort();
    const conversationId = `dm_${sortedIds[0]}_${sortedIds[1]}`;

    // Check if any messages exist in this conversation
    const existingMessage = await ctx.db
      .query("messages")
      .withIndex("by_conversation", (q) => q.eq("conversationId", conversationId))
      .first();

    if (existingMessage) {
      return { conversationId, exists: true };
    }

    return { conversationId, exists: false };
  },
});

// Get messages in a conversation
export const getMessages = query({
  args: {
    conversationId: v.string(),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { conversationId, limit = 100 }) => {
    const messages = await ctx.db
      .query("messages")
      .withIndex("by_conversation", (q) => q.eq("conversationId", conversationId))
      .order("desc")
      .take(limit);

    // Reverse to get chronological order (oldest first)
    const chronologicalMessages = messages.reverse();

    // Get sender details for each message
    const messagesWithSender = await Promise.all(
      chronologicalMessages.map(async (msg) => {
        const sender = await ctx.db.get(msg.senderId);

        return {
          _id: msg._id,
          senderId: msg.senderId,
          receiverId: msg.receiverId,
          conversationId: msg.conversationId,
          message: msg.message,
          isRead: msg.isRead,
          createdAt: msg.createdAt,
          sender: sender
            ? {
                username: sender.username,
                fullName: sender.fullName,
                profilePicture: sender.profilePicture,
              }
            : null,
        };
      })
    );

    return messagesWithSender;
  },
});

// ==================== GROUP MESSAGE QUERIES ====================

// Get all groups a user is a member of
export const getUserGroups = query({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    // Get all group memberships
    const memberships = await ctx.db
      .query("groupMembers")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .collect();

    // Get group details for each membership
    const groups = await Promise.all(
      memberships.map(async (membership) => {
        const group = await ctx.db.get(membership.groupId);
        if (!group) return null;

        // Get latest message in group
        const latestMessage = await ctx.db
          .query("messages")
          .withIndex("by_group", (q) => q.eq("groupId", membership.groupId))
          .order("desc")
          .first();

        // Count unread messages
        const unreadMessages = await ctx.db
          .query("messages")
          .withIndex("by_group", (q) => q.eq("groupId", membership.groupId))
          .filter((q) =>
            q.and(
              q.neq(q.field("senderId"), userId),
              q.eq(q.field("isRead"), false)
            )
          )
          .collect();

        return {
          _id: group._id,
          name: group.name,
          createdBy: group.createdBy,
          createdAt: group.createdAt,
          memberRole: membership.role,
          latestMessage: latestMessage
            ? {
                text: latestMessage.message,
                createdAt: latestMessage.createdAt,
                senderId: latestMessage.senderId,
              }
            : null,
          unreadCount: unreadMessages.length,
        };
      })
    );

    return groups
      .filter((g) => g !== null)
      .sort((a, b) => {
        const aTime = a.latestMessage?.createdAt ?? a.createdAt;
        const bTime = b.latestMessage?.createdAt ?? b.createdAt;
        return bTime - aTime;
      });
  },
});

// Get messages in a group
export const getGroupMessages = query({
  args: {
    groupId: v.id("groups"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { groupId, limit = 100 }) => {
    const messages = await ctx.db
      .query("messages")
      .withIndex("by_group", (q) => q.eq("groupId", groupId))
      .order("desc")
      .take(limit);

    // Reverse to get chronological order
    const chronologicalMessages = messages.reverse();

    // Get sender details for each message
    const messagesWithSender = await Promise.all(
      chronologicalMessages.map(async (msg) => {
        const sender = await ctx.db.get(msg.senderId);

        return {
          _id: msg._id,
          senderId: msg.senderId,
          groupId: msg.groupId,
          message: msg.message,
          isRead: msg.isRead,
          createdAt: msg.createdAt,
          sender: sender
            ? {
                username: sender.username,
                fullName: sender.fullName,
                profilePicture: sender.profilePicture,
              }
            : null,
        };
      })
    );

    return messagesWithSender;
  },
});

// Get group details with members
export const getGroupDetails = query({
  args: { groupId: v.id("groups") },
  handler: async (ctx, { groupId }) => {
    const group = await ctx.db.get(groupId);
    if (!group) {
      throw new Error("Group not found");
    }

    // Get all members
    const memberships = await ctx.db
      .query("groupMembers")
      .withIndex("by_group", (q) => q.eq("groupId", groupId))
      .collect();

    // Get user details for each member
    const members = await Promise.all(
      memberships.map(async (membership) => {
        const user = await ctx.db.get(membership.userId);
        if (!user) return null;

        return {
          _id: user._id,
          username: user.username,
          fullName: user.fullName,
          profilePicture: user.profilePicture,
          role: membership.role,
          joinedAt: membership.joinedAt,
        };
      })
    );

    return {
      _id: group._id,
      name: group.name,
      createdBy: group.createdBy,
      createdAt: group.createdAt,
      members: members.filter((m) => m !== null),
    };
  },
});

// ==================== MESSAGE MUTATIONS ====================

// Send a DM message
export const sendMessage = mutation({
  args: {
    conversationId: v.string(),
    senderId: v.id("users"),
    receiverId: v.id("users"),
    message: v.string(),
  },
  handler: async (ctx, { conversationId, senderId, receiverId, message }) => {
    // Validate users exist
    const [sender, receiver] = await Promise.all([
      ctx.db.get(senderId),
      ctx.db.get(receiverId),
    ]);

    if (!sender) throw new Error("Sender not found");
    if (!receiver) throw new Error("Receiver not found");

    // Create message
    const messageId = await ctx.db.insert("messages", {
      senderId,
      receiverId,
      conversationId,
      message,
      isRead: false,
      createdAt: Date.now(),
    });

    return messageId;
  },
});

// Send a group message
export const sendGroupMessage = mutation({
  args: {
    groupId: v.id("groups"),
    senderId: v.id("users"),
    message: v.string(),
  },
  handler: async (ctx, { groupId, senderId, message }) => {
    // Validate group exists
    const group = await ctx.db.get(groupId);
    if (!group) throw new Error("Group not found");

    // Validate sender is a member
    const membership = await ctx.db
      .query("groupMembers")
      .withIndex("by_pair", (q) =>
        q.eq("groupId", groupId).eq("userId", senderId)
      )
      .first();

    if (!membership) {
      throw new Error("User is not a member of this group");
    }

    // Create message
    const messageId = await ctx.db.insert("messages", {
      senderId,
      groupId,
      message,
      isRead: false,
      createdAt: Date.now(),
    });

    return messageId;
  },
});

// Mark messages as read in a conversation
export const markMessagesAsRead = mutation({
  args: {
    conversationId: v.string(),
    userId: v.id("users"),
  },
  handler: async (ctx, { conversationId, userId }) => {
    // Get all unread messages in this conversation where user is receiver
    const unreadMessages = await ctx.db
      .query("messages")
      .withIndex("by_conversation", (q) => q.eq("conversationId", conversationId))
      .filter((q) =>
        q.and(
          q.eq(q.field("receiverId"), userId),
          q.eq(q.field("isRead"), false)
        )
      )
      .collect();

    // Mark all as read
    await Promise.all(
      unreadMessages.map((msg) =>
        ctx.db.patch(msg._id, { isRead: true })
      )
    );

    return { count: unreadMessages.length };
  },
});

// Mark group messages as read
export const markGroupMessagesAsRead = mutation({
  args: {
    groupId: v.id("groups"),
    userId: v.id("users"),
  },
  handler: async (ctx, { groupId, userId }) => {
    // Get all unread messages in this group (not sent by user)
    const unreadMessages = await ctx.db
      .query("messages")
      .withIndex("by_group", (q) => q.eq("groupId", groupId))
      .filter((q) =>
        q.and(
          q.neq(q.field("senderId"), userId),
          q.eq(q.field("isRead"), false)
        )
      )
      .collect();

    // Mark all as read
    await Promise.all(
      unreadMessages.map((msg) =>
        ctx.db.patch(msg._id, { isRead: true })
      )
    );

    return { count: unreadMessages.length };
  },
});

// ==================== GROUP MANAGEMENT MUTATIONS ====================

// Create a new group
export const createGroup = mutation({
  args: {
    name: v.string(),
    createdBy: v.id("users"),
    memberIds: v.array(v.id("users")),
  },
  handler: async (ctx, { name, createdBy, memberIds }) => {
    // Validate creator exists
    const creator = await ctx.db.get(createdBy);
    if (!creator) throw new Error("Creator not found");

    // Create group
    const groupId = await ctx.db.insert("groups", {
      supabaseId: "", // Empty for new groups created in Convex
      name,
      createdBy,
      createdAt: Date.now(),
    });

    // Add creator as admin
    await ctx.db.insert("groupMembers", {
      groupId,
      userId: createdBy,
      role: "admin",
      joinedAt: Date.now(),
    });

    // Add other members
    await Promise.all(
      memberIds
        .filter((id) => id !== createdBy) // Don't add creator twice
        .map((userId) =>
          ctx.db.insert("groupMembers", {
            groupId,
            userId,
            role: "member",
            joinedAt: Date.now(),
          })
        )
    );

    return groupId;
  },
});

// Add member to group
export const addGroupMember = mutation({
  args: {
    groupId: v.id("groups"),
    userId: v.id("users"),
    addedBy: v.id("users"),
  },
  handler: async (ctx, { groupId, userId, addedBy }) => {
    // Validate group exists
    const group = await ctx.db.get(groupId);
    if (!group) throw new Error("Group not found");

    // Validate user being added exists
    const user = await ctx.db.get(userId);
    if (!user) throw new Error("User not found");

    // Validate addedBy is an admin
    const adderMembership = await ctx.db
      .query("groupMembers")
      .withIndex("by_pair", (q) =>
        q.eq("groupId", groupId).eq("userId", addedBy)
      )
      .first();

    if (!adderMembership || adderMembership.role !== "admin") {
      throw new Error("Only group admins can add members");
    }

    // Check if user is already a member
    const existingMembership = await ctx.db
      .query("groupMembers")
      .withIndex("by_pair", (q) =>
        q.eq("groupId", groupId).eq("userId", userId)
      )
      .first();

    if (existingMembership) {
      throw new Error("User is already a member");
    }

    // Add member
    const membershipId = await ctx.db.insert("groupMembers", {
      groupId,
      userId,
      role: "member",
      joinedAt: Date.now(),
    });

    return membershipId;
  },
});

// Remove member from group
export const removeGroupMember = mutation({
  args: {
    groupId: v.id("groups"),
    userId: v.id("users"),
    removedBy: v.id("users"),
  },
  handler: async (ctx, { groupId, userId, removedBy }) => {
    // Validate group exists
    const group = await ctx.db.get(groupId);
    if (!group) throw new Error("Group not found");

    // Validate remover is an admin or removing themselves
    const removerMembership = await ctx.db
      .query("groupMembers")
      .withIndex("by_pair", (q) =>
        q.eq("groupId", groupId).eq("userId", removedBy)
      )
      .first();

    if (!removerMembership) {
      throw new Error("Remover is not a member");
    }

    const isSelfRemoval = userId === removedBy;
    const isAdmin = removerMembership.role === "admin";

    if (!isSelfRemoval && !isAdmin) {
      throw new Error("Only admins can remove other members");
    }

    // Find membership to remove
    const membership = await ctx.db
      .query("groupMembers")
      .withIndex("by_pair", (q) =>
        q.eq("groupId", groupId).eq("userId", userId)
      )
      .first();

    if (!membership) {
      throw new Error("User is not a member");
    }

    // Don't allow removing the creator
    if (userId === group.createdBy && !isSelfRemoval) {
      throw new Error("Cannot remove group creator");
    }

    // Remove membership
    await ctx.db.delete(membership._id);

    return { success: true };
  },
});
