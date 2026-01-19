//
//  CollectionsService.swift
//  PingNative
//
//  Collections service for Convex integration
//

import Foundation

class CollectionsService {
    private let convexClient: ConvexClient

    init(convexClient: ConvexClient) {
        self.convexClient = convexClient
    }

    // MARK: - Collection Models

    struct Collection: Codable, Identifiable {
        let id: String
        let userId: String
        let name: String
        let description: String?
        let coverImage: String?
        let isDefault: Bool?
        let createdAt: Double
        let placeCount: Int?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case userId
            case name
            case description
            case coverImage
            case isDefault
            case createdAt
            case placeCount
        }
    }

    struct SavedPlace: Codable, Identifiable {
        let id: String
        let placeId: String
        let placeName: String
        let placeImage: String?
        let savedAt: Double
        let collectionId: String?
        let collectionName: String?
        let place: PlaceDetails?

        enum CodingKeys: String, CodingKey {
            case id = "savedId"
            case placeId
            case placeName
            case placeImage
            case savedAt
            case collectionId
            case collectionName
            case place
        }

        struct PlaceDetails: Codable {
            let id: String
            let name: String
            let category: String
            let subcategory: String?
            let location: String
            let lat: Double
            let lng: Double
            let rating: Double?
            let imageUrl: String?

            enum CodingKeys: String, CodingKey {
                case id = "_id"
                case name
                case category
                case subcategory
                case location
                case lat
                case lng
                case rating
                case imageUrl
            }
        }
    }

    // MARK: - Queries

    func getUserCollections(userId: String) async throws -> [Collection] {
        let collections: [Collection] = try await convexClient.query(
            function: "collections:getUserCollections",
            args: ["userId": userId]
        )
        return collections
    }

    func getCollectionPlaces(collectionId: String) async throws -> [SavedPlace] {
        let places: [SavedPlace] = try await convexClient.query(
            function: "collections:getCollectionPlaces",
            args: ["collectionId": collectionId]
        )
        return places
    }

    func getUserSavedPlaces(userId: String, limit: Int = 100) async throws -> [SavedPlace] {
        let places: [SavedPlace] = try await convexClient.query(
            function: "collections:getUserSavedPlaces",
            args: ["userId": userId, "limit": limit]
        )
        return places
    }

    func isPlaceSaved(userId: String, placeId: String) async throws -> Bool {
        let isSaved: Bool = try await convexClient.query(
            function: "collections:isPlaceSaved",
            args: ["userId": userId, "placeId": placeId]
        )
        return isSaved
    }

    func getPlaceSavedCollections(userId: String, placeId: String) async throws -> [Collection] {
        let collections: [Collection] = try await convexClient.query(
            function: "collections:getPlaceSavedCollections",
            args: ["userId": userId, "placeId": placeId]
        )
        return collections
    }

    // MARK: - Mutations

    func createCollection(userId: String, name: String, description: String? = nil) async throws -> String {
        let collectionId: String = try await convexClient.mutation(
            function: "collections:createCollection",
            args: [
                "userId": userId,
                "name": name,
                "description": description as Any
            ]
        )
        return collectionId
    }

    func getOrCreateDefaultCollection(userId: String) async throws -> String {
        let collectionId: String = try await convexClient.mutation(
            function: "collections:getOrCreateDefaultCollection",
            args: ["userId": userId]
        )
        return collectionId
    }

    func savePlace(userId: String, placeId: String, collectionId: String) async throws -> String {
        let savedId: String = try await convexClient.mutation(
            function: "collections:savePlace",
            args: [
                "userId": userId,
                "placeId": placeId,
                "collectionId": collectionId
            ]
        )
        return savedId
    }

    func unsavePlace(userId: String, placeId: String, collectionId: String) async throws {
        struct Result: Codable {
            let success: Bool
        }

        let _: Result = try await convexClient.mutation(
            function: "collections:unsavePlace",
            args: [
                "userId": userId,
                "placeId": placeId,
                "collectionId": collectionId
            ]
        )
    }

    func unsavePlaceFromAll(userId: String, placeId: String) async throws {
        struct Result: Codable {
            let success: Bool
            let removedCount: Int
        }

        let _: Result = try await convexClient.mutation(
            function: "collections:unsavePlaceFromAll",
            args: [
                "userId": userId,
                "placeId": placeId
            ]
        )
    }

    func deleteCollection(userId: String, collectionId: String) async throws {
        struct Result: Codable {
            let success: Bool
        }

        let _: Result = try await convexClient.mutation(
            function: "collections:deleteCollection",
            args: [
                "userId": userId,
                "collectionId": collectionId
            ]
        )
    }
}
