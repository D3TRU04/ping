//
//  TodayViewModel.swift
//  PingNative
//
//  ViewModel for Today feed - Core properties and configuration
//

import Foundation
import Combine

@MainActor
class TodayViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var todayFeedItems: [Place] = []
    @Published var loading: Bool = false
    @Published var refreshing: Bool = false
    @Published var likedPlaces: Set<String> = []
    @Published var savedPlaces: Set<String> = []
    @Published var savedMap: [String: [String]] = [:]
    @Published var erroredImages: Set<String> = []
    @Published var currentIndex: Int = 0
    @Published var errorMessage: String?
    @Published var gameRounds: [GameRound] = []
    @Published var matchmakingComplete: Bool = false
    @Published var selectedThemes: [String] = []
    @Published var previewPlaces: [Place] = []

    // MARK: - Internal Properties
    var recentlyShownSet: Set<String> = []
    var allFetchedPlaces: [Place] = []
    var usedPlaceIds: Set<String> = []
    var placesService: PlacesServiceProtocol?
    var collectionsService: CollectionsServiceProtocol?
    var defaultCollectionId: String?
    var isFetchingData: Bool = false

    // MARK: - Constants
    let recentlyShownKey = "recentlyShownPlaceIds"
    let matchmakingCompleteKey = "todayMatchmakingComplete"
    let matchmakingDateKey = "todayMatchmakingDate"
    let selectedThemesKey = "todaySelectedThemes"

    // MARK: - Configuration

    func configure(placesService: PlacesServiceProtocol, collectionsService: CollectionsServiceProtocol) {
        self.placesService = placesService
        self.collectionsService = collectionsService
        loadMatchmakingState()
    }

    // MARK: - Matchmaking State Management

    func loadMatchmakingState() {
        let savedDate = UserDefaults.standard.string(forKey: matchmakingDateKey)
        let today = getTodayDateString()

        if savedDate == today {
            matchmakingComplete = UserDefaults.standard.bool(forKey: matchmakingCompleteKey)
            if let savedThemes = UserDefaults.standard.array(forKey: selectedThemesKey) as? [String] {
                selectedThemes = savedThemes
            }
        } else {
            matchmakingComplete = false
            selectedThemes = []
            UserDefaults.standard.set(false, forKey: matchmakingCompleteKey)
            UserDefaults.standard.set(today, forKey: matchmakingDateKey)
            UserDefaults.standard.removeObject(forKey: selectedThemesKey)
        }
    }

    func saveMatchmakingComplete() {
        UserDefaults.standard.set(true, forKey: matchmakingCompleteKey)
        UserDefaults.standard.set(getTodayDateString(), forKey: matchmakingDateKey)
        UserDefaults.standard.set(selectedThemes, forKey: selectedThemesKey)
    }

    func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func markMatchmakingComplete() {
        matchmakingComplete = true
        saveMatchmakingComplete()
    }

    func resetMatchmaking() {
        matchmakingComplete = false
        selectedThemes = []
        gameRounds = []
        previewPlaces = []
        todayFeedItems = []
        allFetchedPlaces = []
        usedPlaceIds = []

        UserDefaults.standard.set(false, forKey: matchmakingCompleteKey)
        UserDefaults.standard.removeObject(forKey: selectedThemesKey)
    }

    // MARK: - Recently Shown Management

    func loadRecentlyShown() async {
        if let stored = UserDefaults.standard.array(forKey: recentlyShownKey) as? [String] {
            recentlyShownSet = Set(stored)
        }
    }

    func clearRecentlyShown() {
        recentlyShownSet.removeAll()
        UserDefaults.standard.removeObject(forKey: recentlyShownKey)
    }

    func saveRecentlyShown() {
        UserDefaults.standard.set(Array(recentlyShownSet), forKey: recentlyShownKey)
    }
}
