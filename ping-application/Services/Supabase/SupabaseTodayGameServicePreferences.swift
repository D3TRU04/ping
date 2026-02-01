//
//  SupabaseTodayGameService+Preferences.swift
//  PingNative
//
//  Daily preferences operations for Today Game
//

import Foundation

extension SupabaseTodayGameService {

    // MARK: - Daily Subcategory Preferences

    func getDailyPreferences(userId: String, dateKey: String) async throws -> [DailySubcategoryPreference] {
        return try await client.fetch(
            from: "daily_subcategory_preferences",
            query: [
                "user_id": "eq.\(userId)",
                "date_key": "eq.\(dateKey)"
            ]
        )
    }

    func getPreference(userId: String, dateKey: String, subcategory: String) async throws -> DailySubcategoryPreference? {
        return try await client.fetchOptional(
            from: "daily_subcategory_preferences",
            query: [
                "user_id": "eq.\(userId)",
                "date_key": "eq.\(dateKey)",
                "subcategory": "eq.\(subcategory)"
            ]
        )
    }

    func upsertPreference(
        userId: String,
        dateKey: String,
        subcategory: String,
        category: String,
        selectionCount: Int,
        presentedCount: Int
    ) async throws -> DailySubcategoryPreference {
        if let existing = try await getPreference(userId: userId, dateKey: dateKey, subcategory: subcategory) {
            return try await client.update(
                table: "daily_subcategory_preferences",
                values: [
                    "selection_count": selectionCount,
                    "presented_count": presentedCount,
                    "last_updated": ISO8601DateFormatter().string(from: Date())
                ],
                query: ["id": "eq.\(existing.id)"]
            )
        } else {
            return try await client.insert(
                into: "daily_subcategory_preferences",
                values: [
                    "user_id": userId,
                    "date_key": dateKey,
                    "subcategory": subcategory,
                    "category": category,
                    "selection_count": selectionCount,
                    "presented_count": presentedCount
                ]
            )
        }
    }

    func incrementSelection(userId: String, dateKey: String, subcategory: String, category: String) async throws {
        if let existing = try await getPreference(userId: userId, dateKey: dateKey, subcategory: subcategory) {
            let _: DailySubcategoryPreference = try await client.update(
                table: "daily_subcategory_preferences",
                values: [
                    "selection_count": existing.selectionCount + 1,
                    "last_updated": ISO8601DateFormatter().string(from: Date())
                ],
                query: ["id": "eq.\(existing.id)"]
            )
        } else {
            let _: DailySubcategoryPreference = try await client.insert(
                into: "daily_subcategory_preferences",
                values: [
                    "user_id": userId,
                    "date_key": dateKey,
                    "subcategory": subcategory,
                    "category": category,
                    "selection_count": 1,
                    "presented_count": 1
                ]
            )
        }
    }

    func incrementPresented(userId: String, dateKey: String, subcategory: String, category: String) async throws {
        if let existing = try await getPreference(userId: userId, dateKey: dateKey, subcategory: subcategory) {
            let _: DailySubcategoryPreference = try await client.update(
                table: "daily_subcategory_preferences",
                values: [
                    "presented_count": existing.presentedCount + 1,
                    "last_updated": ISO8601DateFormatter().string(from: Date())
                ],
                query: ["id": "eq.\(existing.id)"]
            )
        } else {
            let _: DailySubcategoryPreference = try await client.insert(
                into: "daily_subcategory_preferences",
                values: [
                    "user_id": userId,
                    "date_key": dateKey,
                    "subcategory": subcategory,
                    "category": category,
                    "selection_count": 0,
                    "presented_count": 1
                ]
            )
        }
    }
}
