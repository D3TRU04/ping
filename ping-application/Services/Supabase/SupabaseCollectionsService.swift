//
//  SupabaseCollectionsService.swift
//  PingNative
//
//  Collections service for Supabase integration
//  Mirrors CollectionsService.swift functionality
//

import Foundation

class SupabaseCollectionsService: CollectionsServiceProtocol {
    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Queries

    func getUserCollections(userId: String) async throws -> [CollectionsService.Collection] {
        let collections: [SupabaseCollection] = try await client.fetch(
            from: "collections",
            query: ["user_id": "eq.\(userId)"]
        )
        return collections.map { $0.toCollection() }
    }

    func getCollectionPlaces(collectionId: String) async throws -> [CollectionsService.SavedPlace] {
        // Query with minimal columns that definitely exist
        struct SimpleSavedPlace: Decodable {
            let id: String
            let placeId: String
            let collectionId: String
            let createdAt: Date
        }

        let savedPlaces: [SimpleSavedPlace] = try await client.fetch(
            from: "saved_places",
            query: ["collection_id": "eq.\(collectionId)"],
            select: "id,place_id,collection_id,created_at"
        )

        guard !savedPlaces.isEmpty else { return [] }

        // Fetch place details separately
        let placeIds = savedPlaces.map { $0.placeId }
        let places: [SupabasePlace] = try await client.fetch(
            from: "places",
            query: ["id": "in.(\(placeIds.joined(separator: ",")))"]
        )
        let placeMap = Dictionary(uniqueKeysWithValues: places.map { ($0.id, $0) })

        return savedPlaces.map { p in
            let place = placeMap[p.placeId]
            let placeDetails: CollectionsService.SavedPlace.PlaceDetails? = place.map { sp in
                CollectionsService.SavedPlace.PlaceDetails(
                    id: sp.id,
                    name: sp.name,
                    category: sp.category ?? "Unknown",
                    subcategory: sp.subcategory,
                    location: sp.location ?? "",
                    lat: sp.lat ?? 0,
                    lng: sp.lng ?? 0,
                    rating: sp.rating,
                    imageUrl: sp.imageUrl
                )
            }
            return CollectionsService.SavedPlace(
                id: p.id,
                placeId: p.placeId,
                placeName: place?.name ?? "Unknown",
                placeImage: place?.imageUrl,
                savedAt: p.createdAt.timeIntervalSince1970 * 1000,
                collectionId: p.collectionId,
                collectionName: nil,
                place: placeDetails
            )
        }
    }

    func getUserSavedPlaces(userId: String, limit: Int = 100) async throws -> [CollectionsService.SavedPlace] {
        // Query with minimal columns that definitely exist
        struct SimpleSavedPlace: Decodable {
            let id: String
            let placeId: String
            let collectionId: String
            let createdAt: Date
        }

        let savedPlaces: [SimpleSavedPlace] = try await client.fetch(
            from: "saved_places",
            query: [
                "user_id": "eq.\(userId)",
                "limit": "\(limit)"
            ],
            select: "id,place_id,collection_id,created_at"
        )

        guard !savedPlaces.isEmpty else { return [] }

        // Fetch place details separately
        let placeIds = savedPlaces.map { $0.placeId }
        let places: [SupabasePlace] = try await client.fetch(
            from: "places",
            query: ["id": "in.(\(placeIds.joined(separator: ",")))"]
        )
        let placeMap = Dictionary(uniqueKeysWithValues: places.map { ($0.id, $0) })

        return savedPlaces.map { p in
            let place = placeMap[p.placeId]
            let placeDetails: CollectionsService.SavedPlace.PlaceDetails? = place.map { sp in
                CollectionsService.SavedPlace.PlaceDetails(
                    id: sp.id,
                    name: sp.name,
                    category: sp.category ?? "Unknown",
                    subcategory: sp.subcategory,
                    location: sp.location ?? "",
                    lat: sp.lat ?? 0,
                    lng: sp.lng ?? 0,
                    rating: sp.rating,
                    imageUrl: sp.imageUrl
                )
            }
            return CollectionsService.SavedPlace(
                id: p.id,
                placeId: p.placeId,
                placeName: place?.name ?? "Unknown",
                placeImage: place?.imageUrl,
                savedAt: p.createdAt.timeIntervalSince1970 * 1000,
                collectionId: p.collectionId,
                collectionName: nil,
                place: placeDetails
            )
        }
    }

    func isPlaceSaved(userId: String, placeId: String) async throws -> Bool {
        struct Saved: Decodable {
            let id: String
        }

        let saved: Saved? = try await client.fetchOptional(
            from: "saved_places",
            query: [
                "user_id": "eq.\(userId)",
                "place_id": "eq.\(placeId)"
            ],
            select: "id"
        )

        return saved != nil
    }

    func getPlaceSavedCollections(userId: String, placeId: String) async throws -> [CollectionsService.Collection] {
        struct SavedPlace: Decodable {
            let collectionId: String
            // No CodingKeys - auto-converted from snake_case
        }

        let savedPlaces: [SavedPlace] = try await client.fetch(
            from: "saved_places",
            query: [
                "user_id": "eq.\(userId)",
                "place_id": "eq.\(placeId)"
            ],
            select: "collection_id"
        )

        guard !savedPlaces.isEmpty else { return [] }

        let collectionIds = savedPlaces.map { $0.collectionId }

        let collections: [SupabaseCollection] = try await client.fetch(
            from: "collections",
            query: ["id": "in.(\(collectionIds.joined(separator: ",")))"]
        )
        return collections.map { $0.toCollection() }
    }
}
