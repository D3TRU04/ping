//
//  SupabasePlacesService+Visits.swift
//  PingNative
//
//  User place visit operations for places service
//

import Foundation

extension SupabasePlacesService {

    // MARK: - User Place Visits

    func getUserVisitedPlaces(userId: String, limit: Int = 100) async throws -> [PlaceVisit] {
        // Query with minimal columns that definitely exist
        struct SimpleVisit: Decodable {
            let id: String
            let placeId: String
            let visitDate: Date
        }

        let visits: [SimpleVisit] = try await client.fetch(
            from: "user_place_visits",
            query: [
                "user_id": "eq.\(userId)",
                "limit": "\(limit)"
            ],
            select: "id,place_id,visit_date"
        )

        guard !visits.isEmpty else { return [] }

        // Fetch place details separately
        let placeIds = visits.map { $0.placeId }
        let places: [SupabasePlace] = try await client.fetch(
            from: "places",
            query: ["id": "in.(\(placeIds.joined(separator: ",")))"]
        )
        let placeMap = Dictionary(uniqueKeysWithValues: places.map { ($0.id, $0) })

        return visits.map { visit in
            let place = placeMap[visit.placeId]
            return PlaceVisit(
                visitId: visit.id,
                placeId: visit.placeId,
                placeName: place?.name ?? "Unknown",
                placeImage: place?.imageUrl,
                visitDate: visit.visitDate,
                place: place?.toPlace()
            )
        }
    }

    func recordPlaceVisit(userId: String, placeId: String) async throws -> String {
        // First, check if visit already exists
        struct ExistingVisit: Decodable {
            let id: String
        }
        let existing: ExistingVisit? = try await client.fetchOptional(
            from: "user_place_visits",
            query: [
                "user_id": "eq.\(userId)",
                "place_id": "eq.\(placeId)"
            ],
            select: "id"
        )

        if let existing = existing {
            // Already visited, return existing id
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

        // Insert new visit with place details
        struct InsertResult: Decodable {
            let id: String
        }

        var values: [String: Any] = [
            "user_id": userId,
            "place_id": placeId,
            "place_name": placeName,
            "visit_date": ISO8601DateFormatter().string(from: Date())
        ]

        if let image = placeImage {
            values["place_image"] = image
        }

        let result: InsertResult = try await client.insert(
            into: "user_place_visits",
            values: values
        )

        return result.id
    }

    func removePlaceVisit(userId: String, placeId: String) async throws {
        try await client.delete(
            from: "user_place_visits",
            query: [
                "user_id": "eq.\(userId)",
                "place_id": "eq.\(placeId)"
            ]
        )
    }

    func hasVisitedPlace(userId: String, placeId: String) async throws -> Bool {
        struct Visit: Decodable {
            let id: String
        }

        let visit: Visit? = try await client.fetchOptional(
            from: "user_place_visits",
            query: [
                "user_id": "eq.\(userId)",
                "place_id": "eq.\(placeId)"
            ],
            select: "id"
        )

        return visit != nil
    }

    func getNearbyPlaces(
        latitude: Double,
        longitude: Double,
        radiusKm: Double = 10,
        limit: Int = 50
    ) async throws -> [PlaceWithDistance] {
        let places: [SupabasePlace] = try await client.fetch(
            from: "places",
            query: ["limit": "\(limit * 3)"]
        )

        let placesWithDistance = places.compactMap { place -> PlaceWithDistance? in
            guard let placeLat = place.lat, let placeLng = place.lng else {
                return nil
            }

            let distance = calculateDistance(
                lat1: latitude, lon1: longitude,
                lat2: placeLat, lon2: placeLng
            )

            if distance <= radiusKm {
                return PlaceWithDistance(place: place.toPlace(), distance: distance)
            }
            return nil
        }

        return Array(placesWithDistance.sorted { $0.distance < $1.distance }.prefix(limit))
    }

    // MARK: - Helpers

    private func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadius = 6371.0

        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180

        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon / 2) * sin(dLon / 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadius * c
    }
}
