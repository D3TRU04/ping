//
//  SupabaseCollectionsModels.swift
//  PingNative
//
//  Model types for collections service
//

import Foundation

struct SupabaseCollection: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let description: String?
    let coverImage: String?
    let isDefault: Bool?
    let createdAt: Date

    // No CodingKeys needed - SupabaseClient uses .convertFromSnakeCase

    func toCollection() -> CollectionsService.Collection {
        CollectionsService.Collection(
            id: id,
            userId: userId,
            name: name,
            description: description,
            coverImage: coverImage,
            isDefault: isDefault,
            createdAt: createdAt.timeIntervalSince1970 * 1000,
            placeCount: nil
        )
    }
}

struct SupabaseSavedPlace: Codable, Identifiable {
    let id: String
    let userId: String
    let placeId: String
    let collectionId: String
    let placeName: String
    let placeImage: String?
    let createdAt: Date
    let place: PlaceDetails?

    // Only need CodingKey for "places" -> "place" (different name)
    enum CodingKeys: String, CodingKey {
        case id, userId, placeId, collectionId, placeName, placeImage, createdAt
        case place = "places"
    }

    struct PlaceDetails: Codable {
        let id: String
        let name: String
        let category: String?
        let subcategory: String?
        let location: String?
        let lat: Double?
        let lng: Double?
        let rating: Double?
        let imageUrl: String?

        // No CodingKeys needed - auto-converted from snake_case
    }

    func toSavedPlace() -> CollectionsService.SavedPlace {
        CollectionsService.SavedPlace(
            id: id,
            placeId: placeId,
            placeName: placeName,
            placeImage: placeImage,
            savedAt: createdAt.timeIntervalSince1970 * 1000,
            collectionId: collectionId,
            collectionName: nil,
            place: place.map { p in
                CollectionsService.SavedPlace.PlaceDetails(
                    id: p.id,
                    name: p.name,
                    category: p.category ?? "",
                    subcategory: p.subcategory,
                    location: p.location ?? "",
                    lat: p.lat ?? 0,
                    lng: p.lng ?? 0,
                    rating: p.rating,
                    imageUrl: p.imageUrl
                )
            }
        )
    }
}
