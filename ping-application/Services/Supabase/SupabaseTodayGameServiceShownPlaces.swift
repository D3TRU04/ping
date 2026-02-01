//
//  SupabaseTodayGameService+ShownPlaces.swift
//  PingNative
//
//  Shown places tracking for Today Game
//

import Foundation

extension SupabaseTodayGameService {

    // MARK: - Today Game Shown Places

    func getShownPlaces(userId: String, dateKey: String) async throws -> [TodayGameShownPlace] {
        return try await client.fetch(
            from: "today_game_shown_places",
            query: [
                "user_id": "eq.\(userId)",
                "date_key": "eq.\(dateKey)"
            ]
        )
    }

    func getShownPlaceIds(userId: String, dateKey: String) async throws -> Set<String> {
        let shown = try await getShownPlaces(userId: userId, dateKey: dateKey)
        return Set(shown.map { $0.placeId })
    }

    func hasShownPlace(userId: String, dateKey: String, placeId: String) async throws -> Bool {
        struct Result: Decodable {
            let id: String
        }

        let result: Result? = try await client.fetchOptional(
            from: "today_game_shown_places",
            query: [
                "user_id": "eq.\(userId)",
                "date_key": "eq.\(dateKey)",
                "place_id": "eq.\(placeId)"
            ],
            select: "id"
        )

        return result != nil
    }

    func recordShownPlace(userId: String, dateKey: String, placeId: String) async throws -> TodayGameShownPlace {
        return try await client.insert(
            into: "today_game_shown_places",
            values: [
                "user_id": userId,
                "date_key": dateKey,
                "place_id": placeId,
                "shown_at": ISO8601DateFormatter().string(from: Date())
            ]
        )
    }

    func recordShownPlaces(userId: String, dateKey: String, placeIds: [String]) async throws {
        for placeId in placeIds {
            if try await !hasShownPlace(userId: userId, dateKey: dateKey, placeId: placeId) {
                let _ = try await recordShownPlace(userId: userId, dateKey: dateKey, placeId: placeId)
            }
        }
    }
}
