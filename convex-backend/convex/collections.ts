import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

// ==================== COLLECTION QUERIES ====================

// Get all collections for a user
export const getUserCollections = query({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    const collections = await ctx.db
      .query("collections")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .take(100);

    // Batch fetch counts for all collections
    const countPromises = collections.map(async (collection) => {
      const savedPlaces = await ctx.db
        .query("savedPlaces")
        .withIndex("by_collection", (q) => q.eq("collectionId", collection._id))
        .take(1000);
      return { id: collection._id.toString(), count: savedPlaces.length };
    });

    const counts = await Promise.all(countPromises);
    const countMap = new Map(counts.map(c => [c.id, c.count]));

    return collections.map(collection => ({
      ...collection,
      placeCount: countMap.get(collection._id.toString()) || 0,
    }));
  },
});

// Get saved places in a collection
export const getCollectionPlaces = query({
  args: {
    collectionId: v.id("collections"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { collectionId, limit = 100 }) => {
    const savedPlaces = await ctx.db
      .query("savedPlaces")
      .withIndex("by_collection", (q) => q.eq("collectionId", collectionId))
      .take(limit);

    // Batch fetch all places at once
    const places = await Promise.all(
      savedPlaces.map(saved => ctx.db.get(saved.placeId))
    );
    const placeMap = new Map(
      places.filter(p => p).map(p => [p!._id.toString(), p!])
    );

    return savedPlaces.map(saved => {
      const place = placeMap.get(saved.placeId.toString());
      return {
        savedId: saved._id,
        placeId: saved.placeId,
        placeName: saved.placeName,
        placeImage: saved.placeImage,
        savedAt: saved.createdAt,
        place: place
          ? {
              _id: place._id,
              name: place.name,
              category: place.category,
              subcategory: place.subcategory,
              location: place.location,
              lat: place.lat,
              lng: place.lng,
              rating: place.rating,
              imageUrl: place.imageUrl,
            }
          : null,
      };
    });
  },
});

// Get all saved places for a user (across all collections)
export const getUserSavedPlaces = query({
  args: {
    userId: v.id("users"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { userId, limit = 50 }) => {
    const savedPlaces = await ctx.db
      .query("savedPlaces")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .take(limit);

    // Batch fetch all places and collections at once
    const placeIds = [...new Set(savedPlaces.map(s => s.placeId))];
    const collectionIds = [...new Set(savedPlaces.map(s => s.collectionId))];

    const [places, collections] = await Promise.all([
      Promise.all(placeIds.map(id => ctx.db.get(id))),
      Promise.all(collectionIds.map(id => ctx.db.get(id))),
    ]);

    const placeMap = new Map(
      places.filter(p => p).map(p => [p!._id.toString(), p!])
    );
    const collectionMap = new Map(
      collections.filter(c => c).map(c => [c!._id.toString(), c!])
    );

    return savedPlaces.map(saved => {
      const place = placeMap.get(saved.placeId.toString());
      const collection = collectionMap.get(saved.collectionId.toString());

      return {
        savedId: saved._id,
        placeId: saved.placeId,
        placeName: saved.placeName,
        placeImage: saved.placeImage,
        savedAt: saved.createdAt,
        collectionId: saved.collectionId,
        collectionName: collection?.name,
        place: place
          ? {
              _id: place._id,
              name: place.name,
              category: place.category,
              subcategory: place.subcategory,
              location: place.location,
              lat: place.lat,
              lng: place.lng,
              rating: place.rating,
              imageUrl: place.imageUrl,
            }
          : null,
      };
    });
  },
});

// Check if a place is saved by user
export const isPlaceSaved = query({
  args: {
    userId: v.id("users"),
    placeId: v.id("places"),
  },
  handler: async (ctx, { userId, placeId }) => {
    const saved = await ctx.db
      .query("savedPlaces")
      .withIndex("by_user_place", (q) => q.eq("userId", userId).eq("placeId", placeId))
      .first();

    return saved !== null;
  },
});

// Get which collections a place is saved to
export const getPlaceSavedCollections = query({
  args: {
    userId: v.id("users"),
    placeId: v.id("places"),
  },
  handler: async (ctx, { userId, placeId }) => {
    const savedEntries = await ctx.db
      .query("savedPlaces")
      .withIndex("by_user_place", (q) => q.eq("userId", userId).eq("placeId", placeId))
      .take(50);

    // Batch fetch all collections at once
    const collections = await Promise.all(
      savedEntries.map((s) => ctx.db.get(s.collectionId))
    );

    return collections.filter((c): c is NonNullable<typeof c> => c !== null);
  },
});

// ==================== COLLECTION MUTATIONS ====================

// Create a new collection
export const createCollection = mutation({
  args: {
    userId: v.id("users"),
    name: v.string(),
    description: v.optional(v.string()),
    isDefault: v.optional(v.boolean()),
  },
  handler: async (ctx, { userId, name, description, isDefault }) => {
    const collectionId = await ctx.db.insert("collections", {
      userId,
      name,
      description,
      isDefault: isDefault || false,
      createdAt: Date.now(),
    });

    return collectionId;
  },
});

// Get or create default "Want to Go" collection
export const getOrCreateDefaultCollection = mutation({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    // Check if default collection exists using compound index for better caching
    const existing = await ctx.db
      .query("collections")
      .withIndex("by_user_default", (q) => q.eq("userId", userId).eq("isDefault", true))
      .first();

    if (existing) {
      return existing._id;
    }

    // Create default collection
    const collectionId = await ctx.db.insert("collections", {
      userId,
      name: "Want to Go",
      description: "Places I want to visit",
      isDefault: true,
      createdAt: Date.now(),
    });

    return collectionId;
  },
});

// Save a place to a collection
export const savePlace = mutation({
  args: {
    userId: v.id("users"),
    placeId: v.id("places"),
    collectionId: v.id("collections"),
  },
  handler: async (ctx, { userId, placeId, collectionId }) => {
    // Validate place exists
    const place = await ctx.db.get(placeId);
    if (!place) throw new Error("Place not found");

    // Validate collection exists and belongs to user
    const collection = await ctx.db.get(collectionId);
    if (!collection) throw new Error("Collection not found");
    if (collection.userId !== userId) throw new Error("Collection does not belong to user");

    // Check if already saved to this collection
    const existing = await ctx.db
      .query("savedPlaces")
      .withIndex("by_collection", (q) => q.eq("collectionId", collectionId))
      .filter((q) => q.eq(q.field("placeId"), placeId))
      .first();

    if (existing) {
      return existing._id; // Already saved
    }

    // Save the place
    const savedId = await ctx.db.insert("savedPlaces", {
      userId,
      placeId,
      collectionId,
      placeName: place.name,
      placeImage: place.imageUrl,
      createdAt: Date.now(),
    });

    // Update collection cover image if it doesn't have one
    if (!collection.coverImage && place.imageUrl) {
      await ctx.db.patch(collectionId, { coverImage: place.imageUrl });
    }

    return savedId;
  },
});

// Remove a place from a collection
export const unsavePlace = mutation({
  args: {
    userId: v.id("users"),
    placeId: v.id("places"),
    collectionId: v.id("collections"),
  },
  handler: async (ctx, { userId, placeId, collectionId }) => {
    const saved = await ctx.db
      .query("savedPlaces")
      .withIndex("by_collection", (q) => q.eq("collectionId", collectionId))
      .filter((q) => q.eq(q.field("placeId"), placeId))
      .first();

    if (!saved) {
      throw new Error("Place not saved to this collection");
    }

    if (saved.userId !== userId) {
      throw new Error("Unauthorized");
    }

    await ctx.db.delete(saved._id);

    return { success: true };
  },
});

// Remove a place from all collections
export const unsavePlaceFromAll = mutation({
  args: {
    userId: v.id("users"),
    placeId: v.id("places"),
  },
  handler: async (ctx, { userId, placeId }) => {
    const savedEntries = await ctx.db
      .query("savedPlaces")
      .withIndex("by_user_place", (q) => q.eq("userId", userId).eq("placeId", placeId))
      .take(100);

    await Promise.all(savedEntries.map(entry => ctx.db.delete(entry._id)));

    return { success: true, removedCount: savedEntries.length };
  },
});

// Delete a collection (and all saved places in it)
export const deleteCollection = mutation({
  args: {
    userId: v.id("users"),
    collectionId: v.id("collections"),
  },
  handler: async (ctx, { userId, collectionId }) => {
    const collection = await ctx.db.get(collectionId);

    if (!collection) {
      throw new Error("Collection not found");
    }

    if (collection.userId !== userId) {
      throw new Error("Unauthorized");
    }

    // Don't allow deleting default collection
    if (collection.isDefault) {
      throw new Error("Cannot delete default collection");
    }

    // Delete all saved places in this collection (with limit to prevent timeout)
    const savedPlaces = await ctx.db
      .query("savedPlaces")
      .withIndex("by_collection", (q) => q.eq("collectionId", collectionId))
      .take(500);

    await Promise.all(savedPlaces.map(saved => ctx.db.delete(saved._id)));

    // Delete the collection
    await ctx.db.delete(collectionId);

    return { success: true };
  },
});
