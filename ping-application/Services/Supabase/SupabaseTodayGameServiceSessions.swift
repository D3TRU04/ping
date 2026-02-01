//
//  SupabaseTodayGameService+Sessions.swift
//  PingNative
//
//  Session and choice operations for Today Game
//

import Foundation

extension SupabaseTodayGameService {

    // MARK: - Today Game Sessions

    func getSession(userId: String, dateKey: String) async throws -> TodayGameSession? {
        return try await client.fetchOptional(
            from: "today_game_sessions",
            query: [
                "user_id": "eq.\(userId)",
                "date_key": "eq.\(dateKey)"
            ]
        )
    }

    func getUserSessions(userId: String, limit: Int = 10) async throws -> [TodayGameSession] {
        return try await client.fetch(
            from: "today_game_sessions",
            query: [
                "user_id": "eq.\(userId)",
                "order": "started_at.desc",
                "limit": "\(limit)"
            ]
        )
    }

    func createSession(userId: String, dateKey: String, totalRounds: Int = 25) async throws -> TodayGameSession {
        return try await client.insert(
            into: "today_game_sessions",
            values: [
                "user_id": userId,
                "date_key": dateKey,
                "rounds_completed": 0,
                "total_rounds": totalRounds,
                "is_complete": false,
                "started_at": ISO8601DateFormatter().string(from: Date())
            ]
        )
    }

    func updateSessionProgress(sessionId: String, roundsCompleted: Int) async throws -> TodayGameSession {
        return try await client.update(
            table: "today_game_sessions",
            values: ["rounds_completed": roundsCompleted],
            query: ["id": "eq.\(sessionId)"]
        )
    }

    func completeSession(sessionId: String) async throws -> TodayGameSession {
        return try await client.update(
            table: "today_game_sessions",
            values: [
                "is_complete": true,
                "completed_at": ISO8601DateFormatter().string(from: Date())
            ],
            query: ["id": "eq.\(sessionId)"]
        )
    }

    // MARK: - Today Game Choices

    func getSessionChoices(sessionId: String) async throws -> [TodayGameChoice] {
        return try await client.fetch(
            from: "today_game_choices",
            query: [
                "session_id": "eq.\(sessionId)",
                "order": "round_number.asc"
            ]
        )
    }

    func getUserChoices(userId: String, dateKey: String) async throws -> [TodayGameChoice] {
        return try await client.fetch(
            from: "today_game_choices",
            query: [
                "user_id": "eq.\(userId)",
                "date_key": "eq.\(dateKey)",
                "order": "round_number.asc"
            ]
        )
    }

    func recordChoice(
        userId: String,
        sessionId: String,
        dateKey: String,
        roundNumber: Int,
        chosenPlaceId: String,
        rejectedPlaceId: String,
        chosenSubcategory: String,
        rejectedSubcategory: String
    ) async throws -> TodayGameChoice {
        return try await client.insert(
            into: "today_game_choices",
            values: [
                "user_id": userId,
                "session_id": sessionId,
                "date_key": dateKey,
                "round_number": roundNumber,
                "chosen_place_id": chosenPlaceId,
                "rejected_place_id": rejectedPlaceId,
                "chosen_subcategory": chosenSubcategory,
                "rejected_subcategory": rejectedSubcategory
            ]
        )
    }
}
