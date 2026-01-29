import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

// ==================== GROUP QUERIES ====================

// Get all groups for a user (owned or member of)
export const getUserGroups = query({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    // Parallel fetch owned groups and memberships
    const [ownedGroups, memberships] = await Promise.all([
      ctx.db
        .query("groups")
        .withIndex("by_creator", (q) => q.eq("createdBy", userId))
        .take(100),
      ctx.db
        .query("groupMembers")
        .withIndex("by_user", (q) => q.eq("userId", userId))
        .take(100),
    ]);

    // Batch fetch member groups
    const memberGroups = await Promise.all(
      memberships.map((m) => ctx.db.get(m.groupId))
    );

    // Combine and dedupe
    const seenIds = new Set(ownedGroups.map(g => g._id.toString()));
    const allGroups = [...ownedGroups];
    for (const group of memberGroups) {
      if (group && !seenIds.has(group._id.toString())) {
        seenIds.add(group._id.toString());
        allGroups.push(group);
      }
    }

    // Batch fetch member counts for all groups
    const memberCounts = await Promise.all(
      allGroups.map(async (group) => {
        const members = await ctx.db
          .query("groupMembers")
          .withIndex("by_group", (q) => q.eq("groupId", group._id))
          .take(100);
        return { id: group._id.toString(), count: members.length };
      })
    );

    const countMap = new Map(memberCounts.map(c => [c.id, c.count]));

    return allGroups.map(group => ({
      ...group,
      memberCount: (countMap.get(group._id.toString()) || 0) + 1, // +1 for owner
    }));
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

    // Parallel fetch owner and memberships
    const [owner, memberships] = await Promise.all([
      ctx.db.get(group.createdBy),
      ctx.db
        .query("groupMembers")
        .withIndex("by_group", (q) => q.eq("groupId", groupId))
        .take(100),
    ]);

    // Batch fetch all member users at once
    const users = await Promise.all(
      memberships.map(m => ctx.db.get(m.userId))
    );
    const userMap = new Map(
      users.filter(u => u).map(u => [u!._id.toString(), u!])
    );

    const members = memberships
      .map(m => {
        const user = userMap.get(m.userId.toString());
        return user
          ? {
              _id: user._id,
              username: user.username,
              fullName: user.fullName,
              profilePicture: user.profilePicture,
              role: m.role || "member",
              joinedAt: m.joinedAt,
            }
          : null;
      })
      .filter((m): m is NonNullable<typeof m> => m !== null);

    return {
      ...group,
      owner: owner
        ? {
            _id: owner._id,
            username: owner.username,
            fullName: owner.fullName,
            profilePicture: owner.profilePicture,
          }
        : null,
      members,
    };
  },
});

// Get common places for all group members (intersection)
export const getGroupCommonPlaces = query({
  args: {
    groupId: v.id("groups"),
    placeType: v.union(v.literal("saved"), v.literal("been")),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { groupId, placeType, limit = 50 }) => {
    const group = await ctx.db.get(groupId);
    if (!group) {
      throw new Error("Group not found");
    }

    // Get all member IDs including owner
    const memberships = await ctx.db
      .query("groupMembers")
      .withIndex("by_group", (q) => q.eq("groupId", groupId))
      .take(50);

    const memberIds = [group.createdBy, ...memberships.map((m) => m.userId)];

    if (memberIds.length === 0) {
      return [];
    }

    // Parallel fetch place IDs for all members with limits
    const memberPlaceResults = await Promise.all(
      memberIds.map(async (memberId) => {
        if (placeType === "saved") {
          const savedPlaces = await ctx.db
            .query("savedPlaces")
            .withIndex("by_user", (q) => q.eq("userId", memberId))
            .take(200);
          return new Set(savedPlaces.map((sp) => sp.placeId.toString()));
        } else {
          const visits = await ctx.db
            .query("userPlaceVisits")
            .withIndex("by_user", (q) => q.eq("userId", memberId))
            .take(200);
          return new Set(visits.map((v) => v.placeId.toString()));
        }
      })
    );

    // Find intersection of all sets
    if (memberPlaceResults.length === 0) {
      return [];
    }

    let commonPlaceIds = memberPlaceResults[0];
    for (let i = 1; i < memberPlaceResults.length; i++) {
      commonPlaceIds = new Set(
        [...commonPlaceIds].filter((id) => memberPlaceResults[i].has(id))
      );
    }

    // Limit and batch fetch place details
    const limitedIds = [...commonPlaceIds].slice(0, limit);
    const places = await Promise.all(
      limitedIds.map((placeIdStr) => ctx.db.get(placeIdStr as any))
    );

    return places
      .filter((p): p is NonNullable<typeof p> => p !== null)
      .map(place => ({
        _id: place._id,
        name: place.name,
        category: place.category,
        subcategory: place.subcategory,
        location: place.location,
        lat: place.lat,
        lng: place.lng,
        rating: place.rating,
        imageUrl: place.imageUrl,
      }));
  },
});

// ==================== GROUP MUTATIONS ====================

// Create a new group
export const createGroup = mutation({
  args: {
    ownerId: v.id("users"),
    name: v.string(),
    memberIds: v.array(v.id("users")),
  },
  handler: async (ctx, { ownerId, name, memberIds }) => {
    // Create the group
    const groupId = await ctx.db.insert("groups", {
      supabaseId: "", // Not used for new groups
      name,
      createdBy: ownerId,
      createdAt: Date.now(),
    });

    // Add members to the group
    for (const memberId of memberIds) {
      // Don't add owner as a member (they're the creator)
      if (memberId !== ownerId) {
        await ctx.db.insert("groupMembers", {
          groupId,
          userId: memberId,
          role: "member",
          joinedAt: Date.now(),
        });
      }
    }

    return groupId;
  },
});

// Add a member to a group
export const addMember = mutation({
  args: {
    groupId: v.id("groups"),
    userId: v.id("users"),
    requesterId: v.id("users"),
  },
  handler: async (ctx, { groupId, userId, requesterId }) => {
    const group = await ctx.db.get(groupId);
    if (!group) {
      throw new Error("Group not found");
    }

    // Only owner can add members
    if (group.createdBy !== requesterId) {
      throw new Error("Only the group owner can add members");
    }

    // Check if already a member
    const existing = await ctx.db
      .query("groupMembers")
      .withIndex("by_pair", (q) => q.eq("groupId", groupId).eq("userId", userId))
      .first();

    if (existing) {
      return existing._id;
    }

    // Add the member
    const membershipId = await ctx.db.insert("groupMembers", {
      groupId,
      userId,
      role: "member",
      joinedAt: Date.now(),
    });

    return membershipId;
  },
});

// Remove a member from a group
export const removeMember = mutation({
  args: {
    groupId: v.id("groups"),
    userId: v.id("users"),
    requesterId: v.id("users"),
  },
  handler: async (ctx, { groupId, userId, requesterId }) => {
    const group = await ctx.db.get(groupId);
    if (!group) {
      throw new Error("Group not found");
    }

    // Owner can remove anyone, or member can remove themselves
    if (group.createdBy !== requesterId && userId !== requesterId) {
      throw new Error("Not authorized to remove this member");
    }

    // Find the membership
    const membership = await ctx.db
      .query("groupMembers")
      .withIndex("by_pair", (q) => q.eq("groupId", groupId).eq("userId", userId))
      .first();

    if (!membership) {
      throw new Error("User is not a member of this group");
    }

    await ctx.db.delete(membership._id);

    return { success: true };
  },
});

// Delete a group (owner only)
export const deleteGroup = mutation({
  args: {
    groupId: v.id("groups"),
    userId: v.id("users"),
  },
  handler: async (ctx, { groupId, userId }) => {
    const group = await ctx.db.get(groupId);
    if (!group) {
      throw new Error("Group not found");
    }

    if (group.createdBy !== userId) {
      throw new Error("Only the group owner can delete the group");
    }

    // Delete all memberships with limit to prevent timeout
    const memberships = await ctx.db
      .query("groupMembers")
      .withIndex("by_group", (q) => q.eq("groupId", groupId))
      .take(200);

    await Promise.all(memberships.map(m => ctx.db.delete(m._id)));

    // Delete the group
    await ctx.db.delete(groupId);

    return { success: true };
  },
});

// Update group name
export const updateGroup = mutation({
  args: {
    groupId: v.id("groups"),
    userId: v.id("users"),
    name: v.string(),
  },
  handler: async (ctx, { groupId, userId, name }) => {
    const group = await ctx.db.get(groupId);
    if (!group) {
      throw new Error("Group not found");
    }

    if (group.createdBy !== userId) {
      throw new Error("Only the group owner can update the group");
    }

    await ctx.db.patch(groupId, { name });

    return { success: true };
  },
});
