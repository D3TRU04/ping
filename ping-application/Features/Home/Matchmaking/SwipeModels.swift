//
//  SwipeModels.swift
//  PingNative
//
//  Data models for the Tinder-style swipe feature
//

import Foundation

// MARK: - Swipe Direction
enum SwipeDirection {
    case left   // Skip
    case right  // Interested
}

// MARK: - Swipe Card
struct SwipeCard: Identifiable {
    let id: String
    let place: Place
    var weight: Double = 1.0

    init(place: Place, weight: Double = 1.0) {
        self.id = place.id
        self.place = place
        self.weight = weight
    }
}

// MARK: - Swipe Result
struct SwipeResult {
    let card: SwipeCard
    let direction: SwipeDirection
    let timestamp: Date

    init(card: SwipeCard, direction: SwipeDirection) {
        self.card = card
        self.direction = direction
        self.timestamp = Date()
    }
}

// MARK: - Swipe Session
struct SwipeSession {
    var cards: [SwipeCard]
    var currentIndex: Int = 0
    var results: [SwipeResult] = []
    let batchSize: Int
    let batchNumber: Int

    var interestedPlaces: [Place] {
        results
            .filter { $0.direction == .right }
            .map { $0.card.place }
    }

    var skippedPlaces: [Place] {
        results
            .filter { $0.direction == .left }
            .map { $0.card.place }
    }

    var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(currentIndex) / Double(cards.count)
    }

    var isComplete: Bool {
        currentIndex >= cards.count
    }

    var currentCard: SwipeCard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }

    var remainingCards: Int {
        max(0, cards.count - currentIndex)
    }
}
