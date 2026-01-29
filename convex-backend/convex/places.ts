import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

// ==================== DEBUG QUERIES ====================

// Get all unique categories in the places table (for debugging)
// NOTE: This is a debug query - consider caching categories in production
export const getAllCategories = query({
  args: {},
  handler: async (ctx) => {
    // Limit scan to reduce bandwidth - this is a debug query
    const places = await ctx.db.query("places").take(1000);
    const categories = new Set<string>();
    const subcategories = new Set<string>();

    for (const place of places) {
      if (place.category) categories.add(place.category);
      if (place.subcategory) subcategories.add(place.subcategory);
    }

    return {
      totalPlaces: places.length,
      categories: Array.from(categories).sort(),
      subcategories: Array.from(subcategories).sort(),
      samplePlaces: places.slice(0, 5).map(p => ({
        name: p.name,
        category: p.category,
        subcategory: p.subcategory
      }))
    };
  },
});

// ==================== PLACE QUERIES ====================

// Search places by name
// NOTE: For production, consider using Convex's search indexes for better performance
export const searchPlaces = query({
  args: {
    query: v.string(),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { query, limit = 50 }) => {
    // Normalize query for consistent caching
    const normalizedQuery = query.trim().toLowerCase();

    if (!normalizedQuery || normalizedQuery.length < 2) {
      return [];
    }

    const results: any[] = [];

    // Limit scan to reduce bandwidth
    const places = await ctx.db.query("places").take(500);

    for (const place of places) {
      if (results.length >= limit) break;

      if (place.name.toLowerCase().includes(normalizedQuery)) {
        results.push({
          _id: place._id,
          name: place.name,
          category: place.category,
          subcategory: place.subcategory,
          location: place.location,
          lat: place.lat,
          lng: place.lng,
          rating: place.rating,
          priceRange: place.priceRange,
          hours: place.hours,
          description: place.description,
          imageUrl: place.imageUrl,
          websiteUrl: place.websiteUrl,
        });
      }
    }

    return results;
  },
});

// Get all places (no filtering)
export const getAllPlaces = query({
  args: {
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { limit = 100 }) => {
    const allPlaces = await ctx.db.query("places").take(limit);

    return allPlaces.map((place) => ({
      _id: place._id,
      name: place.name,
      category: place.category,
      subcategory: place.subcategory,
      location: place.location,
      lat: place.lat,
      lng: place.lng,
      rating: place.rating,
      priceRange: place.priceRange,
      hours: place.hours,
      description: place.description,
      imageUrl: place.imageUrl,
      websiteUrl: place.websiteUrl,
    }));
  },
});

// Get places by category
export const getPlacesByCategory = query({
  args: {
    category: v.string(),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { category, limit = 50 }) => {
    const places = await ctx.db
      .query("places")
      .withIndex("by_category", (q) => q.eq("category", category))
      .take(limit);

    return places.map((place) => ({
      _id: place._id,
      name: place.name,
      category: place.category,
      subcategory: place.subcategory,
      location: place.location,
      lat: place.lat,
      lng: place.lng,
      rating: place.rating,
      priceRange: place.priceRange,
      hours: place.hours,
      description: place.description,
      imageUrl: place.imageUrl,
      websiteUrl: place.websiteUrl,
    }));
  },
});

// Get places by category preferences
export const getPlacesByPreferences = query({
  args: {
    categoryPreferences: v.record(v.string(), v.array(v.string())),
    excludeIds: v.optional(v.array(v.id("places"))),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { categoryPreferences, excludeIds = [], limit = 100 }) => {
    const excludeSet = new Set(excludeIds.map(id => id.toString()));
    const seenIds = new Set<string>();
    const results: any[] = [];

    // Calculate per-category limit to avoid fetching too many from one category
    const categoryCount = Object.keys(categoryPreferences).length;
    const perCategoryLimit = Math.ceil((limit * 2) / Math.max(categoryCount, 1));

    // Fetch from each category with limits
    for (const [category, subcategories] of Object.entries(categoryPreferences)) {
      if (results.length >= limit) break;

      // Use take instead of collect to limit reads
      const categoryPlaces = await ctx.db
        .query("places")
        .withIndex("by_category", (q) => q.eq("category", category))
        .take(perCategoryLimit);

      for (const place of categoryPlaces) {
        if (results.length >= limit) break;
        if (excludeSet.has(place._id.toString())) continue;
        if (seenIds.has(place._id.toString())) continue;

        // Check subcategory filter if specified
        if (subcategories.length > 0 && place.subcategory) {
          const matchesSubcategory = subcategories.some((sub) =>
            place.subcategory?.toLowerCase().includes(sub.toLowerCase())
          );
          if (!matchesSubcategory) continue;
        }

        seenIds.add(place._id.toString());
        results.push({
          _id: place._id,
          name: place.name,
          category: place.category,
          subcategory: place.subcategory,
          location: place.location,
          lat: place.lat,
          lng: place.lng,
          rating: place.rating,
          priceRange: place.priceRange,
          hours: place.hours,
          description: place.description,
          imageUrl: place.imageUrl,
          websiteUrl: place.websiteUrl,
        });
      }
    }

    return results;
  },
});

// Get place details by ID
export const getPlaceById = query({
  args: { placeId: v.id("places") },
  handler: async (ctx, { placeId }) => {
    const place = await ctx.db.get(placeId);

    if (!place) {
      throw new Error("Place not found");
    }

    return {
      _id: place._id,
      name: place.name,
      category: place.category,
      subcategory: place.subcategory,
      location: place.location,
      lat: place.lat,
      lng: place.lng,
      rating: place.rating,
      priceRange: place.priceRange,
      hours: place.hours,
      description: place.description,
      imageUrl: place.imageUrl,
      websiteUrl: place.websiteUrl,
    };
  },
});

// Get nearby places (within a certain radius)
// NOTE: For production with large datasets, consider using a geospatial service
// or pre-computed grid-based indexes for efficient location queries
export const getNearbyPlaces = query({
  args: {
    latitude: v.number(),
    longitude: v.number(),
    radiusKm: v.optional(v.number()),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { latitude, longitude, radiusKm = 10, limit = 50 }) => {
    // Calculate distance using Haversine formula
    const calculateDistance = (lat1: number, lon1: number, lat2: number, lon2: number) => {
      const R = 6371; // Earth's radius in km
      const dLat = ((lat2 - lat1) * Math.PI) / 180;
      const dLon = ((lon2 - lon1) * Math.PI) / 180;
      const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos((lat1 * Math.PI) / 180) *
          Math.cos((lat2 * Math.PI) / 180) *
          Math.sin(dLon / 2) *
          Math.sin(dLon / 2);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      return R * c;
    };

    // Limit scan to reduce bandwidth
    const places = await ctx.db.query("places").take(1000);
    const nearbyPlaces: Array<{ place: typeof places[0]; distance: number }> = [];

    // Stream through places and collect nearby ones
    for (const place of places) {
      const distance = calculateDistance(latitude, longitude, place.lat, place.lng);
      if (distance <= radiusKm) {
        nearbyPlaces.push({ place, distance });
      }
    }

    // Sort by distance and limit
    nearbyPlaces.sort((a, b) => a.distance - b.distance);

    return nearbyPlaces.slice(0, limit).map(({ place, distance }) => ({
      _id: place._id,
      name: place.name,
      category: place.category,
      subcategory: place.subcategory,
      location: place.location,
      lat: place.lat,
      lng: place.lng,
      rating: place.rating,
      priceRange: place.priceRange,
      hours: place.hours,
      description: place.description,
      imageUrl: place.imageUrl,
      websiteUrl: place.websiteUrl,
      distance: Math.round(distance * 10) / 10,
    }));
  },
});

// ==================== USER PLACE VISIT QUERIES ====================

// Get user's visited places
export const getUserVisitedPlaces = query({
  args: {
    userId: v.id("users"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { userId, limit = 50 }) => {
    const visits = await ctx.db
      .query("userPlaceVisits")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .order("desc")
      .take(limit);

    // Batch fetch all places at once
    const places = await Promise.all(
      visits.map(visit => ctx.db.get(visit.placeId))
    );
    const placeMap = new Map(
      places.filter(p => p).map(p => [p!._id.toString(), p!])
    );

    return visits.map(visit => {
      const place = placeMap.get(visit.placeId.toString());
      return {
        visitId: visit._id,
        placeId: visit.placeId,
        placeName: visit.placeName,
        placeImage: visit.placeImage,
        visitDate: visit.visitDate,
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

// Check if user has visited a place
export const hasVisitedPlace = query({
  args: {
    userId: v.id("users"),
    placeId: v.id("places"),
  },
  handler: async (ctx, { userId, placeId }) => {
    const visit = await ctx.db
      .query("userPlaceVisits")
      .withIndex("by_pair", (q) => q.eq("userId", userId).eq("placeId", placeId))
      .first();

    return visit !== null;
  },
});

// ==================== USER PLACE VISIT MUTATIONS ====================

// Record a user visit to a place
export const recordPlaceVisit = mutation({
  args: {
    userId: v.id("users"),
    placeId: v.id("places"),
    visitDate: v.optional(v.number()),
  },
  handler: async (ctx, { userId, placeId, visitDate }) => {
    // Validate user exists
    const user = await ctx.db.get(userId);
    if (!user) throw new Error("User not found");

    // Get place details
    const place = await ctx.db.get(placeId);
    if (!place) throw new Error("Place not found");

    // Check if visit already exists
    const existingVisit = await ctx.db
      .query("userPlaceVisits")
      .withIndex("by_pair", (q) => q.eq("userId", userId).eq("placeId", placeId))
      .first();

    if (existingVisit) {
      // Update visit date
      await ctx.db.patch(existingVisit._id, {
        visitDate: visitDate || Date.now(),
      });
      return existingVisit._id;
    }

    // Create new visit
    const visitId = await ctx.db.insert("userPlaceVisits", {
      userId,
      placeId,
      placeName: place.name,
      placeImage: place.imageUrl,
      visitDate: visitDate || Date.now(),
      createdAt: Date.now(),
    });

    return visitId;
  },
});

// Remove a place visit
export const removePlaceVisit = mutation({
  args: {
    userId: v.id("users"),
    placeId: v.id("places"),
  },
  handler: async (ctx, { userId, placeId }) => {
    const visit = await ctx.db
      .query("userPlaceVisits")
      .withIndex("by_pair", (q) => q.eq("userId", userId).eq("placeId", placeId))
      .first();

    if (!visit) {
      throw new Error("Visit not found");
    }

    // Verify the visit belongs to the user
    if (visit.userId !== userId) {
      throw new Error("Unauthorized");
    }

    await ctx.db.delete(visit._id);

    return { success: true };
  },
});
