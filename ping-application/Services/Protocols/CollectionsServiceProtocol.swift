//
//  CollectionsServiceProtocol.swift
//  PingNative
//
//  Protocol and types for collections service
//

import Foundation

protocol CollectionsServiceProtocol {
    func getUserCollections(userId: String) async throws -> [CollectionsService.Collection]
    func getCollectionPlaces(collectionId: String) async throws -> [CollectionsService.SavedPlace]
    func getUserSavedPlaces(userId: String, limit: Int) async throws -> [CollectionsService.SavedPlace]
    func isPlaceSaved(userId: String, placeId: String) async throws -> Bool
    func getPlaceSavedCollections(userId: String, placeId: String) async throws -> [CollectionsService.Collection]
    func createCollection(userId: String, name: String, description: String?) async throws -> String
    func getOrCreateDefaultCollection(userId: String) async throws -> String
    func savePlace(userId: String, placeId: String, collectionId: String) async throws -> String
    func unsavePlace(userId: String, placeId: String, collectionId: String) async throws
    func unsavePlaceFromAll(userId: String, placeId: String) async throws
    func deleteCollection(userId: String, collectionId: String) async throws
}

// MARK: - Collections Service Types

enum CollectionsService {
    struct Collection: Identifiable {
        let id: String
        let userId: String
        let name: String
        let description: String?
        let coverImage: String?
        let isDefault: Bool?
        let createdAt: Double
        let placeCount: Int?
    }

    struct SavedPlace: Identifiable {
        let id: String
        let placeId: String
        let placeName: String
        let placeImage: String?
        let savedAt: Double
        let collectionId: String
        let collectionName: String?
        let place: PlaceDetails?

        struct PlaceDetails {
            let id: String
            let name: String
            let category: String
            let subcategory: String?
            let location: String
            let lat: Double
            let lng: Double
            let rating: Double?
            let imageUrl: String?
        }
    }
}
