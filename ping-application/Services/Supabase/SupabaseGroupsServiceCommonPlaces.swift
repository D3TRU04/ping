//
//  SupabaseGroupsService+CommonPlaces.swift
//  PingNative
//
//  Common places query logic for groups
//

import Foundation

extension SupabaseGroupsService {

    func getGroupCommonPlaces(groupId: String, placeType: PlaceType) async throws -> [GroupsService.CommonPlace] {
        let members = try await getGroupMembers(groupId: groupId)
        let memberIds = members.map { $0.userId }

        guard memberIds.count >= 2 else { return [] }

        if placeType == .saved {
            return try await getSavedCommonPlaces(memberIds: memberIds)
        }

        return try await getVisitedCommonPlaces(memberIds: memberIds)
    }

    private func getSavedCommonPlaces(memberIds: [String]) async throws -> [GroupsService.CommonPlace] {
        // Get saved place IDs only (minimal columns)
        struct SavedPlace: Decodable {
            let placeId: String
        }

        let savedPlaces: [SavedPlace] = try await client.fetch(
            from: "saved_places",
            query: ["user_id": "in.(\(memberIds.joined(separator: ",")))"],
            select: "place_id"
        )

        // Count places that appear for multiple members
        var placeCount: [String: Int] = [:]
        for saved in savedPlaces {
            placeCount[saved.placeId, default: 0] += 1
        }

        // Get full place details for common places (appearing 2+ times)
        let commonPlaceIds = placeCount.filter { $0.value >= 2 }.map { $0.key }
        guard !commonPlaceIds.isEmpty else { return [] }

        let places: [SupabasePlace] = try await client.fetch(
            from: "places",
            query: ["id": "in.(\(commonPlaceIds.joined(separator: ",")))"]
        )

        return places.map { place in
            GroupsService.CommonPlace(
                id: place.id,
                name: place.name,
                category: place.category ?? "",
                subcategory: place.subcategory,
                location: place.location ?? "",
                lat: place.lat ?? 0,
                lng: place.lng ?? 0,
                rating: place.rating,
                imageUrl: place.imageUrl
            )
        }
    }

    private func getVisitedCommonPlaces(memberIds: [String]) async throws -> [GroupsService.CommonPlace] {
        // Get visited place IDs only (minimal columns)
        struct VisitedPlace: Decodable {
            let placeId: String
        }

        let visitedPlaces: [VisitedPlace] = try await client.fetch(
            from: "user_place_visits",
            query: ["user_id": "in.(\(memberIds.joined(separator: ",")))"],
            select: "place_id"
        )

        // Count places that appear for multiple members
        var placeCount: [String: Int] = [:]
        for visited in visitedPlaces {
            placeCount[visited.placeId, default: 0] += 1
        }

        // Get full place details for common places (appearing 2+ times)
        let commonPlaceIds = placeCount.filter { $0.value >= 2 }.map { $0.key }
        guard !commonPlaceIds.isEmpty else { return [] }

        let places: [SupabasePlace] = try await client.fetch(
            from: "places",
            query: ["id": "in.(\(commonPlaceIds.joined(separator: ",")))"]
        )

        return places.map { place in
            GroupsService.CommonPlace(
                id: place.id,
                name: place.name,
                category: place.category ?? "",
                subcategory: place.subcategory,
                location: place.location ?? "",
                lat: place.lat ?? 0,
                lng: place.lng ?? 0,
                rating: place.rating,
                imageUrl: place.imageUrl
            )
        }
    }
}
