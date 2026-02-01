//
//  SupabasePlacesService.swift
//  PingNative
//
//  Places service for Supabase integration
//  Mirrors PlacesService.swift functionality
//

import Foundation

class SupabasePlacesService: PlacesServiceProtocol {
    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Queries

    func fetchPlaces(
        categoryPreferences: [String: [String]],
        excludeIds: [String] = [],
        limit: Int? = nil
    ) async throws -> [Place] {
        #if DEBUG
        print("📍 PlacesService: fetchPlaces called")
        print("   - Category preferences: \(categoryPreferences)")
        #endif

        // Fetch ALL places from database
        let allPlaces: [SupabasePlace] = try await client.fetch(
            from: "places",
            query: ["limit": "200"]  // Fetch plenty to filter from
        )

        #if DEBUG
        print("📍 PlacesService: Fetched \(allPlaces.count) total places from database")

        // Log unique categories and subcategories in the database
        var categorySet = Set<String>()
        var subcategorySet = Set<String>()
        for place in allPlaces {
            if let cat = place.category { categorySet.insert(cat) }
            if let subcat = place.subcategory { subcategorySet.insert(subcat) }
        }
        print("📍 PlacesService: DB Categories: \(categorySet.sorted())")
        print("📍 PlacesService: DB Subcategories: \(subcategorySet.sorted())")
        #endif

        let excludeSet = Set(excludeIds)

        // If no preferences or empty, return all places
        if categoryPreferences.isEmpty {
            #if DEBUG
            print("📍 PlacesService: No preferences, returning all \(allPlaces.count) places")
            #endif
            return Array(allPlaces
                .filter { !excludeSet.contains($0.id) }
                .prefix(limit ?? 50))
                .map { $0.toPlace() }
        }

        // Build sets of requested categories and subcategories (case-insensitive)
        let requestedCategories = Set(categoryPreferences.keys.map { $0.lowercased() })
        var allRequestedSubcategories = Set<String>()
        for subcats in categoryPreferences.values {
            for subcat in subcats {
                allRequestedSubcategories.insert(subcat.lowercased())
            }
        }

        #if DEBUG
        print("📍 PlacesService: Looking for categories: \(requestedCategories)")
        print("📍 PlacesService: Looking for subcategories: \(allRequestedSubcategories)")
        #endif

        // Filter places - match if category OR subcategory matches (case-insensitive)
        let filteredPlaces = allPlaces.filter { place in
            if excludeSet.contains(place.id) { return false }

            let placeCategory = (place.category ?? "").lowercased()
            let placeSubcategory = (place.subcategory ?? "").lowercased()

            // Include if category matches ANY requested category
            if requestedCategories.contains(placeCategory) {
                return true
            }

            // Include if subcategory matches ANY requested subcategory
            if !placeSubcategory.isEmpty && allRequestedSubcategories.contains(placeSubcategory) {
                return true
            }

            return false
        }

        #if DEBUG
        print("📍 PlacesService: After filtering: \(filteredPlaces.count) places match")
        for place in filteredPlaces.prefix(5) {
            print("   ✓ \(place.name): '\(place.category ?? "")' / '\(place.subcategory ?? "")'")
        }
        #endif

        // FALLBACK: If no matches found, return ALL places so user sees something
        if filteredPlaces.isEmpty {
            #if DEBUG
            print("📍 PlacesService: ⚠️ No matches! Returning ALL places as fallback")
            #endif
            return Array(allPlaces
                .filter { !excludeSet.contains($0.id) }
                .prefix(limit ?? 50))
                .map { $0.toPlace() }
        }

        return Array(filteredPlaces.prefix(limit ?? 50)).map { $0.toPlace() }
    }

    func searchPlaces(query: String, limit: Int = 50) async throws -> [Place] {
        let places: [SupabasePlace] = try await client.fetch(
            from: "places",
            query: [
                "name": "ilike.*\(query)*",
                "limit": "\(limit)"
            ]
        )

        return places.map { $0.toPlace() }
    }

    func getAllPlaces(limit: Int = 100) async throws -> [Place] {
        #if DEBUG
        print("📍 PlacesService: getAllPlaces called with limit \(limit)")
        #endif

        let places: [SupabasePlace] = try await client.fetch(
            from: "places",
            query: ["limit": "\(limit)"]
        )

        #if DEBUG
        print("📍 PlacesService: getAllPlaces returned \(places.count) places")
        if places.isEmpty {
            print("📍 PlacesService: WARNING - No places returned!")
        }
        #endif

        return places.map { $0.toPlace() }
    }

    func fetchPlaceDetails(placeId: String) async throws -> Place? {
        let place: SupabasePlace? = try await client.fetchOptional(
            from: "places",
            query: ["id": "eq.\(placeId)"]
        )

        return place?.toPlace()
    }
}
