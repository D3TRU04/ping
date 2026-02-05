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

    // MARK: - Category Selection State
    @Published var categorySelectionStep: CategorySelectionStep = .categories
    @Published var selectedCategoryIds: Set<String> = []
    @Published var selectedSubcategoryValues: Set<String> = []

    // MARK: - Swipe Feature State
    @Published var swipeCards: [SwipeCard] = []
    @Published var interestedPlaces: [Place] = []
    @Published var currentSwipeIndex: Int = 0
    @Published var swipeBatchNumber: Int = 1
    @Published var totalSwipesThisBatch: Int = 20
    @Published var swipeResults: [SwipeResult] = []

    // Swipe batch size constants
    let firstBatchSize: Int = 20
    let additionalBatchSize: Int = 10

    enum CategorySelectionStep {
        case categories      // Step 1: Select categories
        case subcategories   // Step 2: Select subcategories
        case swipe           // Step 3: Swipe through places
        case preview         // Step 4: Preview "Your Picks"
        case complete        // Proceed to feed
    }

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

    // Keys for persisting category selection state
    let categorySelectionStepKey = "todayCategorySelectionStep"
    let selectedCategoryIdsKey = "todaySelectedCategoryIds"
    let selectedSubcategoryValuesKey = "todaySelectedSubcategoryValues"
    let interestedPlacesKey = "todayInterestedPlaces"

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
            // Restore category selection state
            loadCategorySelectionState()
        } else {
            // New day - reset everything
            matchmakingComplete = false
            selectedThemes = []
            categorySelectionStep = .categories
            selectedCategoryIds = []
            selectedSubcategoryValues = []
            interestedPlaces = []
            todayFeedItems = []
            UserDefaults.standard.set(false, forKey: matchmakingCompleteKey)
            UserDefaults.standard.set(today, forKey: matchmakingDateKey)
            UserDefaults.standard.removeObject(forKey: selectedThemesKey)
            clearCategorySelectionState()
        }
    }

    private func loadCategorySelectionState() {
        // Don't load state if matchmaking is already complete
        if matchmakingComplete {
            categorySelectionStep = .complete
            // Load interested places for the feed
            if let data = UserDefaults.standard.data(forKey: interestedPlacesKey),
               let places = try? JSONDecoder().decode([Place].self, from: data) {
                todayFeedItems = places
            }
            return
        }

        // Load category selection step
        if let stepString = UserDefaults.standard.string(forKey: categorySelectionStepKey) {
            switch stepString {
            case "categories": categorySelectionStep = .categories
            case "subcategories": categorySelectionStep = .subcategories
            case "swipe": categorySelectionStep = .swipe
            case "preview": categorySelectionStep = .preview
            case "complete": categorySelectionStep = .complete
            default: categorySelectionStep = .categories
            }
        }

        // Load selected categories
        if let categoryIds = UserDefaults.standard.array(forKey: selectedCategoryIdsKey) as? [String] {
            selectedCategoryIds = Set(categoryIds)
        }

        // Load selected subcategories
        if let subcategoryValues = UserDefaults.standard.array(forKey: selectedSubcategoryValuesKey) as? [String] {
            selectedSubcategoryValues = Set(subcategoryValues)
        }

        // Load interested places
        if let data = UserDefaults.standard.data(forKey: interestedPlacesKey),
           let places = try? JSONDecoder().decode([Place].self, from: data) {
            interestedPlaces = places
            // If we're at preview step, also set them
            if categorySelectionStep == .preview {
                // Swipe cards need to be regenerated, so go back to swipe
                // Or we can go to preview with existing interested places
            }
        }
    }

    func saveCategorySelectionState() {
        // Save category selection step
        let stepString: String
        switch categorySelectionStep {
        case .categories: stepString = "categories"
        case .subcategories: stepString = "subcategories"
        case .swipe: stepString = "swipe"
        case .preview: stepString = "preview"
        case .complete: stepString = "complete"
        }
        UserDefaults.standard.set(stepString, forKey: categorySelectionStepKey)

        // Save selected categories
        UserDefaults.standard.set(Array(selectedCategoryIds), forKey: selectedCategoryIdsKey)

        // Save selected subcategories
        UserDefaults.standard.set(Array(selectedSubcategoryValues), forKey: selectedSubcategoryValuesKey)

        // Save interested places
        if let data = try? JSONEncoder().encode(interestedPlaces) {
            UserDefaults.standard.set(data, forKey: interestedPlacesKey)
        }
    }

    private func clearCategorySelectionState() {
        UserDefaults.standard.removeObject(forKey: categorySelectionStepKey)
        UserDefaults.standard.removeObject(forKey: selectedCategoryIdsKey)
        UserDefaults.standard.removeObject(forKey: selectedSubcategoryValuesKey)
        UserDefaults.standard.removeObject(forKey: interestedPlacesKey)
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

        // Reset category selection state
        categorySelectionStep = .categories
        selectedCategoryIds = []
        selectedSubcategoryValues = []
        swipeCards = []
        interestedPlaces = []
        currentSwipeIndex = 0
        swipeBatchNumber = 1
        swipeResults = []

        UserDefaults.standard.set(false, forKey: matchmakingCompleteKey)
        UserDefaults.standard.removeObject(forKey: selectedThemesKey)
        clearCategorySelectionState()
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

    // MARK: - Category Selection Methods

    func toggleCategorySelection(_ categoryId: String) {
        if selectedCategoryIds.contains(categoryId) {
            selectedCategoryIds.remove(categoryId)
        } else {
            selectedCategoryIds.insert(categoryId)
        }
    }

    func toggleSubcategorySelection(_ value: String) {
        if selectedSubcategoryValues.contains(value) {
            selectedSubcategoryValues.remove(value)
        } else {
            selectedSubcategoryValues.insert(value)
        }
    }

    func proceedToSubcategories() {
        categorySelectionStep = .subcategories
        saveCategorySelectionState()
    }

    func goBackToCategories() {
        categorySelectionStep = .categories
        saveCategorySelectionState()
    }

    func markCategorySelectionComplete() {
        // Start the swipe flow instead of going directly to complete
        saveCategorySelectionState()
        Task {
            await startSwipeFlow()
        }
    }

    func resetCategorySelection() {
        categorySelectionStep = .categories
        selectedCategoryIds = []
        selectedSubcategoryValues = []
        // Reset swipe state
        swipeCards = []
        interestedPlaces = []
        currentSwipeIndex = 0
        swipeBatchNumber = 1
        swipeResults = []
        saveCategorySelectionState()
    }

    func getSelectedCategories() -> [Category] {
        OnboardingData.categories.filter { selectedCategoryIds.contains($0.id) }
    }
}
