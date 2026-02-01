//
//  SupabaseTodayGameService.swift
//  PingNative
//
//  Today Game service for Supabase integration
//

import Foundation

class SupabaseTodayGameService {
    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Helpers

    func getTodayDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func getOrCreateTodaySession(userId: String, totalRounds: Int = 25) async throws -> TodayGameSession {
        let dateKey = getTodayDateKey()

        if let existing = try await getSession(userId: userId, dateKey: dateKey) {
            return existing
        }

        return try await createSession(userId: userId, dateKey: dateKey, totalRounds: totalRounds)
    }
}
