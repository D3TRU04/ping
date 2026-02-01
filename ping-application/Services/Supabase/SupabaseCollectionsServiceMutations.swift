//
//  SupabaseCollectionsService+Mutations.swift
//  PingNative
//
//  Mutation operations for collections service
//

import Foundation

extension SupabaseCollectionsService {

    // MARK: - Mutations

    func createCollection(userId: String, name: String, description: String? = nil) async throws -> String {
        struct InsertResult: Decodable {
            let id: String
        }

        var values: [String: Any] = [
            "user_id": userId,
            "name": name
        ]

        if let description = description {
            values["description"] = description
        }

        let result: InsertResult = try await client.insert(
            into: "collections",
            values: values
        )

        return result.id
    }

    func getOrCreateDefaultCollection(userId: String) async throws -> String {
        // Try to find existing default collection
        let existing: SupabaseCollection? = try await client.fetchOptional(
            from: "collections",
            query: [
                "user_id": "eq.\(userId)",
                "is_default": "eq.true"
            ]
        )

        if let existing = existing {
            return existing.id
        }

        // Create default collection
        struct InsertResult: Decodable {
            let id: String
        }

        let result: InsertResult = try await client.insert(
            into: "collections",
            values: [
                "user_id": userId,
                "name": "Want to Go",
                "is_default": true
            ]
        )

        return result.id
    }

    func savePlace(userId: String, placeId: String, collectionId: String) async throws -> String {
        // First, check if already saved
        struct ExistingCheck: Decodable {
            let id: String
        }
        let existing: ExistingCheck? = try await client.fetchOptional(
            from: "saved_places",
            query: [
                "user_id": "eq.\(userId)",
                "place_id": "eq.\(placeId)"
            ],
            select: "id"
        )

        if let existing = existing {
            // Already saved, return existing id
            return existing.id
        }

        // Fetch place details to get name and image
        struct PlaceInfo: Decodable {
            let name: String
            let imageUrl: String?
        }
        let placeInfo: PlaceInfo? = try await client.fetchOptional(
            from: "places",
            query: ["id": "eq.\(placeId)"],
            select: "name,image_url"
        )

        let placeName = placeInfo?.name ?? "Unknown Place"
        let placeImage = placeInfo?.imageUrl

        struct InsertResult: Decodable {
            let id: String
        }

        var values: [String: Any] = [
            "user_id": userId,
            "place_id": placeId,
            "collection_id": collectionId,
            "place_name": placeName
        ]

        if let image = placeImage {
            values["place_image"] = image
        }

        let result: InsertResult = try await client.insert(
            into: "saved_places",
            values: values
        )

        return result.id
    }

    func unsavePlace(userId: String, placeId: String, collectionId: String) async throws {
        try await client.delete(
            from: "saved_places",
            query: [
                "user_id": "eq.\(userId)",
                "place_id": "eq.\(placeId)",
                "collection_id": "eq.\(collectionId)"
            ]
        )
    }

    func unsavePlaceFromAll(userId: String, placeId: String) async throws {
        try await client.delete(
            from: "saved_places",
            query: [
                "user_id": "eq.\(userId)",
                "place_id": "eq.\(placeId)"
            ]
        )
    }

    func deleteCollection(userId: String, collectionId: String) async throws {
        // FK constraints will cascade delete saved_places
        try await client.delete(
            from: "collections",
            query: [
                "id": "eq.\(collectionId)",
                "user_id": "eq.\(userId)"
            ]
        )
    }
}
