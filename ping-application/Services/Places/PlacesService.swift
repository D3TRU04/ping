//
//  PlacesService.swift
//  PingNative
//
//  Places service with Convex integration
//

import Foundation

class PlacesService {
    private let convexClient: ConvexClient

    init(convexClient: ConvexClient) {
        self.convexClient = convexClient
    }
    
    func fetchPlaces(
        categoryPreferences: [String: [String]],
        excludeIds: [String] = [],
        limit: Int? = nil
    ) async throws -> [Place] {
        struct PlaceResult: Codable {
            let id: String
            let name: String
            let category: String
            let subcategory: String?
            let location: String
            let lat: Double
            let lng: Double
            let rating: Double?
            let priceRange: String?
            let hours: String?
            let description: String?
            let imageUrl: String?
            let websiteUrl: String?

            enum CodingKeys: String, CodingKey {
                case id = "_id"
                case name, category, subcategory, location, lat, lng
                case rating, priceRange, hours, description, imageUrl, websiteUrl
            }
        }

        var args: [String: Any] = ["categoryPreferences": categoryPreferences]
        if !excludeIds.isEmpty {
            args["excludeIds"] = excludeIds
        }
        if let limit = limit {
            args["limit"] = limit
        }

        let places: [PlaceResult] = try await convexClient.query(
            function: "places:getPlacesByPreferences",
            args: args
        )

        return places.map { placeResult in
            Place(
                id: placeResult.id,
                name: placeResult.name,
                address: placeResult.location,
                latitude: placeResult.lat,
                longitude: placeResult.lng,
                category: placeResult.category,
                subcategory: placeResult.subcategory,
                subtopic: nil,
                rating: placeResult.rating,
                imageUrl: placeResult.imageUrl,
                description: placeResult.description,
                hours: placeResult.hours.map { [$0] }, // Convert single string to array
                phone: nil,
                priceRange: Int(placeResult.priceRange ?? "0")
            )
        }
    }

    func searchPlaces(query: String, limit: Int = 50) async throws -> [Place] {
        struct PlaceResult: Codable {
            let id: String
            let name: String
            let category: String
            let subcategory: String?
            let location: String
            let lat: Double
            let lng: Double
            let rating: Double?
            let priceRange: String?
            let hours: String?
            let description: String?
            let imageUrl: String?
            let websiteUrl: String?

            enum CodingKeys: String, CodingKey {
                case id = "_id"
                case name, category, subcategory, location, lat, lng
                case rating, priceRange, hours, description, imageUrl, websiteUrl
            }
        }

        let places: [PlaceResult] = try await convexClient.query(
            function: "places:searchPlaces",
            args: ["query": query, "limit": limit]
        )

        return places.map { placeResult in
            Place(
                id: placeResult.id,
                name: placeResult.name,
                address: placeResult.location,
                latitude: placeResult.lat,
                longitude: placeResult.lng,
                category: placeResult.category,
                subcategory: placeResult.subcategory,
                subtopic: nil,
                rating: placeResult.rating,
                imageUrl: placeResult.imageUrl,
                description: placeResult.description,
                hours: placeResult.hours.map { [$0] },
                phone: nil,
                priceRange: Int(placeResult.priceRange ?? "0")
            )
        }
    }
    
    func fetchPlaceDetails(placeId: String) async throws -> Place? {
        struct PlaceResult: Codable {
            let id: String
            let name: String
            let category: String
            let subcategory: String?
            let location: String
            let lat: Double
            let lng: Double
            let rating: Double?
            let priceRange: String?
            let hours: String?
            let description: String?
            let imageUrl: String?
            let websiteUrl: String?

            enum CodingKeys: String, CodingKey {
                case id = "_id"
                case name, category, subcategory, location, lat, lng
                case rating, priceRange, hours, description, imageUrl, websiteUrl
            }
        }

        let placeResult: PlaceResult = try await convexClient.query(
            function: "places:getPlaceById",
            args: ["placeId": placeId]
        )

        return Place(
            id: placeResult.id,
            name: placeResult.name,
            address: placeResult.location,
            latitude: placeResult.lat,
            longitude: placeResult.lng,
            category: placeResult.category,
            subcategory: placeResult.subcategory,
            subtopic: nil,
            rating: placeResult.rating,
            imageUrl: placeResult.imageUrl,
            description: placeResult.description,
            hours: placeResult.hours.map { [$0] },
            phone: nil,
            priceRange: Int(placeResult.priceRange ?? "0")
        )
    }

    // MARK: - User Place Visits

    func getUserVisitedPlaces(userId: String, limit: Int = 100) async throws -> [PlaceVisit] {
        struct VisitResult: Codable {
            let visitId: String
            let placeId: String
            let placeName: String
            let placeImage: String?
            let visitDate: Double
            let place: PlaceInfo?

            struct PlaceInfo: Codable {
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
                    case name, category, subcategory, location, lat, lng, rating, imageUrl
                }
            }
        }

        let visits: [VisitResult] = try await convexClient.query(
            function: "places:getUserVisitedPlaces",
            args: ["userId": userId, "limit": limit]
        )

        return visits.map { visit in
            PlaceVisit(
                visitId: visit.visitId,
                placeId: visit.placeId,
                placeName: visit.placeName,
                placeImage: visit.placeImage,
                visitDate: Date(timeIntervalSince1970: visit.visitDate / 1000),
                place: visit.place.map { placeInfo in
                    Place(
                        id: placeInfo.id,
                        name: placeInfo.name,
                        address: placeInfo.location,
                        latitude: placeInfo.lat,
                        longitude: placeInfo.lng,
                        category: placeInfo.category,
                        subcategory: placeInfo.subcategory,
                        subtopic: nil,
                        rating: placeInfo.rating,
                        imageUrl: placeInfo.imageUrl,
                        description: nil,
                        hours: nil,
                        phone: nil,
                        priceRange: nil
                    )
                }
            )
        }
    }

    func recordPlaceVisit(userId: String, placeId: String) async throws -> String {
        let visitId: String = try await convexClient.mutation(
            function: "places:recordPlaceVisit",
            args: [
                "userId": userId,
                "placeId": placeId
            ]
        )

        return visitId
    }

    func removePlaceVisit(userId: String, placeId: String) async throws {
        struct RemoveResult: Codable {
            let success: Bool
        }

        let _: RemoveResult = try await convexClient.mutation(
            function: "places:removePlaceVisit",
            args: [
                "userId": userId,
                "placeId": placeId
            ]
        )
    }

    func hasVisitedPlace(userId: String, placeId: String) async throws -> Bool {
        let hasVisited: Bool = try await convexClient.query(
            function: "places:hasVisitedPlace",
            args: [
                "userId": userId,
                "placeId": placeId
            ]
        )

        return hasVisited
    }

    func getNearbyPlaces(
        latitude: Double,
        longitude: Double,
        radiusKm: Double = 10,
        limit: Int = 50
    ) async throws -> [PlaceWithDistance] {
        struct PlaceResult: Codable {
            let id: String
            let name: String
            let category: String
            let subcategory: String?
            let location: String
            let lat: Double
            let lng: Double
            let rating: Double?
            let priceRange: String?
            let hours: String?
            let description: String?
            let imageUrl: String?
            let websiteUrl: String?
            let distance: Double

            enum CodingKeys: String, CodingKey {
                case id = "_id"
                case name, category, subcategory, location, lat, lng
                case rating, priceRange, hours, description, imageUrl, websiteUrl, distance
            }
        }

        let places: [PlaceResult] = try await convexClient.query(
            function: "places:getNearbyPlaces",
            args: [
                "latitude": latitude,
                "longitude": longitude,
                "radiusKm": radiusKm,
                "limit": limit
            ]
        )

        return places.map { placeResult in
            PlaceWithDistance(
                place: Place(
                    id: placeResult.id,
                    name: placeResult.name,
                    address: placeResult.location,
                    latitude: placeResult.lat,
                    longitude: placeResult.lng,
                    category: placeResult.category,
                    subcategory: placeResult.subcategory,
                    subtopic: nil,
                    rating: placeResult.rating,
                    imageUrl: placeResult.imageUrl,
                    description: placeResult.description,
                    hours: placeResult.hours.map { [$0] },
                    phone: nil,
                    priceRange: Int(placeResult.priceRange ?? "0")
                ),
                distance: placeResult.distance
            )
        }
    }
}

// MARK: - Supporting Models

struct PlaceVisit: Identifiable {
    let visitId: String
    let placeId: String
    let placeName: String
    let placeImage: String?
    let visitDate: Date
    let place: Place?

    var id: String { visitId }
}

struct PlaceWithDistance {
    let place: Place
    let distance: Double // in kilometers
}
