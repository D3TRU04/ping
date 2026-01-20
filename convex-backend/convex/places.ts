import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

// ==================== DEBUG QUERIES ====================

// Get all unique categories in the places table (for debugging)
export const getAllCategories = query({
  args: {},
  handler: async (ctx) => {
    const allPlaces = await ctx.db.query("places").collect();
    const categories = new Set<string>();
    const subcategories = new Set<string>();

    for (const place of allPlaces) {
      if (place.category) categories.add(place.category);
      if (place.subcategory) subcategories.add(place.subcategory);
    }

    return {
      totalPlaces: allPlaces.length,
      categories: Array.from(categories).sort(),
      subcategories: Array.from(subcategories).sort(),
      samplePlaces: allPlaces.slice(0, 5).map(p => ({
        name: p.name,
        category: p.category,
        subcategory: p.subcategory
      }))
    };
  },
});

// ==================== PLACE QUERIES ====================

// Search places by name
export const searchPlaces = query({
  args: {
    query: v.string(),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { query, limit = 50 }) => {
    // Get all places and filter by name (case-insensitive)
    const allPlaces = await ctx.db.query("places").collect();

    const matchingPlaces = allPlaces
      .filter((place) =>
        place.name.toLowerCase().includes(query.toLowerCase())
      )
      .slice(0, limit);

    return matchingPlaces.map((place) => ({
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
    const excludeSet = new Set(excludeIds);
    const allMatchingPlaces: any[] = [];

    // For each category and its subcategories
    for (const [category, subcategories] of Object.entries(
      categoryPreferences
    )) {
      // Get places in this category
      const categoryPlaces = await ctx.db
        .query("places")
        .withIndex("by_category", (q) => q.eq("category", category))
        .collect();

      // Filter out excluded places
      const nonExcludedPlaces = categoryPlaces.filter(
        (place) => !excludeSet.has(place._id)
      );

      // If subcategories specified, try to filter by them
      if (subcategories.length > 0) {
        const subcategoryMatches = nonExcludedPlaces.filter((place) => {
          if (!place.subcategory) return false;
          return subcategories.some((sub) =>
            place.subcategory?.toLowerCase().includes(sub.toLowerCase())
          );
        });

        // If we found subcategory matches, use them; otherwise include all from category
        if (subcategoryMatches.length > 0) {
          allMatchingPlaces.push(...subcategoryMatches);
        } else {
          // No subcategory matches - include all places from this category
          allMatchingPlaces.push(...nonExcludedPlaces);
        }
      } else {
        // No subcategories specified - include all from this category
        allMatchingPlaces.push(...nonExcludedPlaces);
      }
    }

    // Remove duplicates and limit results
    const uniquePlaces = Array.from(
      new Map(allMatchingPlaces.map((p) => [p._id, p])).values()
    ).slice(0, limit);

    return uniquePlaces.map((place) => ({
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
export const getNearbyPlaces = query({
  args: {
    latitude: v.number(),
    longitude: v.number(),
    radiusKm: v.optional(v.number()),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { latitude, longitude, radiusKm = 10, limit = 50 }) => {
    // Get all places (in production, you'd use a spatial index)
    const allPlaces = await ctx.db.query("places").collect();

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

    // Filter places within radius
    const nearbyPlaces = allPlaces
      .map((place) => ({
        place,
        distance: calculateDistance(latitude, longitude, place.lat, place.lng),
      }))
      .filter((item) => item.distance <= radiusKm)
      .sort((a, b) => a.distance - b.distance)
      .slice(0, limit);

    return nearbyPlaces.map(({ place, distance }) => ({
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
      distance: Math.round(distance * 10) / 10, // Round to 1 decimal
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
  handler: async (ctx, { userId, limit = 100 }) => {
    const visits = await ctx.db
      .query("userPlaceVisits")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .order("desc")
      .take(limit);

    // Get full place details for each visit
    const visitedPlaces = await Promise.all(
      visits.map(async (visit) => {
        const place = await ctx.db.get(visit.placeId);

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
      })
    );

    return visitedPlaces;
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
