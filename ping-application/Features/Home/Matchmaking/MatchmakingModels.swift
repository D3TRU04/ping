//
//  MatchmakingModels.swift
//  PingNative
//
//  Data models for the matchmaking game flow
//

import Foundation

struct GameRound: Identifiable {
    let id = UUID()
    let optionA: PlaceOption
    let optionB: PlaceOption
}

struct PlaceOption {
    let name: String
    let description: String
    let category: String
    let subcategory: String
    let priceRange: Int?
}
