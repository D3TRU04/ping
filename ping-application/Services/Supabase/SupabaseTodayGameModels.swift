//
//  SupabaseTodayGameModels.swift
//  PingNative
//
//  Model types for Today Game service
//  Note: No CodingKeys needed - SupabaseClient uses .convertFromSnakeCase
//

import Foundation

struct DailySubcategoryPreference: Codable, Identifiable {
    let id: String
    let userId: String
    let dateKey: String
    let subcategory: String
    let category: String
    let selectionCount: Int
    let presentedCount: Int
    let lastUpdated: Date?
}

struct TodayGameSession: Codable, Identifiable {
    let id: String
    let userId: String
    let dateKey: String
    let roundsCompleted: Int
    let totalRounds: Int
    let isComplete: Bool
    let startedAt: Date
    let completedAt: Date?
}

struct TodayGameChoice: Codable, Identifiable {
    let id: String
    let userId: String
    let sessionId: String
    let dateKey: String
    let roundNumber: Int
    let chosenPlaceId: String
    let rejectedPlaceId: String
    let chosenSubcategory: String
    let rejectedSubcategory: String
    let createdAt: Date
}

struct TodayGameShownPlace: Codable, Identifiable {
    let id: String
    let userId: String
    let dateKey: String
    let placeId: String
    let shownAt: Date
}
