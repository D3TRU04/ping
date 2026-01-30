//
//  TodayPage.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/today/page.tsx
//  Today feed page connected to Convex database
//

import SwiftUI
import Combine

struct TodayPage: View {
    let currentUser: User?
    @StateObject private var viewModel = TodayViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    var onUpdatePreferences: (() -> Void)? = nil
    var onReplayGameRequest: ((@escaping () -> Void) -> Void)? = nil  // Passes the reset callback to parent
    
    var body: some View {
        ZStack {
            Color(hex: "FAFAFA")
                .ignoresSafeArea()

            if let errorMessage = viewModel.errorMessage, viewModel.todayFeedItems.isEmpty {
                // Error state
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.textTertiary)
                    Text("Something went wrong")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        viewModel.errorMessage = nil
                        Task {
                            await viewModel.generateGameRounds()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.primaryAction)
                }
                .padding()
            } else if !viewModel.matchmakingComplete && viewModel.gameRounds.isEmpty {
                // Initial loading - generate game rounds
                ProgressView()
                    .task {
                        // Configure services first, then generate rounds
                        viewModel.configure(
                            placesService: appEnvironment.placesService,
                            collectionsService: appEnvironment.collectionsService
                        )
                        await viewModel.generateGameRounds()
                    }
            } else if !viewModel.matchmakingComplete && !viewModel.gameRounds.isEmpty {
                // Show matchmaking game
                MatchmakingFlowView(
                    rounds: viewModel.gameRounds,
                    onFinished: { selectedThemes in
                        // Store selected themes and mark matchmaking as complete
                        viewModel.selectedThemes = selectedThemes
                        viewModel.markMatchmakingComplete()
                    },
                    onRequestMoreRounds: { currentThemes in
                        // Generate additional rounds when user wants to keep playing
                        return await viewModel.generateAdditionalRounds(count: 5)
                    },
                    onUpdatePreview: { themes in
                        // Get updated preview places based on user's theme selections
                        return viewModel.getPreviewPlaces(for: themes)
                    }
                )
            } else if let userId = currentUser?.id {
                // Show feed after matchmaking is complete
                FeedView(
                    items: viewModel.todayFeedItems,
                    liked: viewModel.likedPlaces,
                    saved: viewModel.savedPlaces,
                    refreshing: viewModel.refreshing,
                    loading: viewModel.loading,
                    onRefresh: {
                        viewModel.clearRecentlyShown()
                        await viewModel.fetchData(userId: userId, isRefresh: true)
                    },
                    erroredImages: viewModel.erroredImages,
                    setErroredImages: { newSet in
                        viewModel.erroredImages = newSet
                    },
                    setCurrentIndex: { index in
                        viewModel.currentIndex = index
                    },
                    currentUserId: userId,
                    onLikeChange: { placeId, isLiked in
                        Task {
                            await viewModel.toggleLike(placeId: placeId, isLiked: isLiked, userId: userId)
                        }
                    },
                    onSaveChange: { placeId, listName in
                        Task {
                            await viewModel.toggleSave(placeId: placeId, listName: listName, userId: userId)
                        }
                    },
                    onUpdatePreferences: onUpdatePreferences
                )
                .task {
                    viewModel.configure(
                        placesService: appEnvironment.placesService,
                        collectionsService: appEnvironment.collectionsService
                    )
                    await viewModel.loadRecentlyShown()
                    await viewModel.fetchData(userId: userId)
                }
            }
        }
        .onAppear {
            // Register the replay callback with the parent
            onReplayGameRequest? { [viewModel, appEnvironment] in
                // Ensure services are configured before replaying
                viewModel.configure(
                    placesService: appEnvironment.placesService,
                    collectionsService: appEnvironment.collectionsService
                )
                viewModel.resetMatchmaking()
                Task {
                    await viewModel.generateGameRounds()
                }
            }
        }
    }
}

@MainActor
class TodayViewModel: ObservableObject {
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

    private var recentlyShownSet: Set<String> = []
    private var allFetchedPlaces: [Place] = []  // Store all places for generating more rounds
    private var usedPlaceIds: Set<String> = []  // Track places already used in rounds
    private var placesService: PlacesService?
    private var collectionsService: CollectionsService?
    private var defaultCollectionId: String?
    private let recentlyShownKey = "recentlyShownPlaceIds"
    private let matchmakingCompleteKey = "todayMatchmakingComplete"
    private let matchmakingDateKey = "todayMatchmakingDate"
    private let selectedThemesKey = "todaySelectedThemes"
    private var isFetchingData: Bool = false

    /// Check if matchmaking was already completed today
    private func loadMatchmakingState() {
        let savedDate = UserDefaults.standard.string(forKey: matchmakingDateKey)
        let today = getTodayDateString()

        if savedDate == today {
            // Same day - restore the completed state and selected themes
            matchmakingComplete = UserDefaults.standard.bool(forKey: matchmakingCompleteKey)
            if let savedThemes = UserDefaults.standard.array(forKey: selectedThemesKey) as? [String] {
                selectedThemes = savedThemes
                print("✅ Restored \(savedThemes.count) selected themes from previous session")
            }
        } else {
            // New day - reset state
            matchmakingComplete = false
            selectedThemes = []
            UserDefaults.standard.set(false, forKey: matchmakingCompleteKey)
            UserDefaults.standard.set(today, forKey: matchmakingDateKey)
            UserDefaults.standard.removeObject(forKey: selectedThemesKey)
        }
    }

    /// Save matchmaking completion state and selected themes
    private func saveMatchmakingComplete() {
        UserDefaults.standard.set(true, forKey: matchmakingCompleteKey)
        UserDefaults.standard.set(getTodayDateString(), forKey: matchmakingDateKey)
        UserDefaults.standard.set(selectedThemes, forKey: selectedThemesKey)
        print("✅ Saved \(selectedThemes.count) selected themes")
    }

    /// Get today's date as a string for comparison
    private func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    func configure(placesService: PlacesService, collectionsService: CollectionsService) {
        self.placesService = placesService
        self.collectionsService = collectionsService
        // Restore matchmaking state from UserDefaults
        loadMatchmakingState()
    }
    
    func loadRecentlyShown() async {
        // Load from UserDefaults
        if let stored = UserDefaults.standard.array(forKey: recentlyShownKey) as? [String] {
            recentlyShownSet = Set(stored)
        }
    }
    
    func clearRecentlyShown() {
        recentlyShownSet.removeAll()
        UserDefaults.standard.removeObject(forKey: recentlyShownKey)
    }
    
    private func saveRecentlyShown() {
        UserDefaults.standard.set(Array(recentlyShownSet), forKey: recentlyShownKey)
    }
    
    func generateGameRounds() async {
        // Skip if matchmaking was already completed today (restored from UserDefaults)
        if matchmakingComplete {
            print("✅ Matchmaking already completed today, skipping game generation")
            return
        }

        guard let placesService = placesService else {
            print("❌ PlacesService not configured for generateGameRounds")
            errorMessage = "Service not configured"
            return
        }

        loading = true

        do {
            let allPlaces = try await placesService.getAllPlaces(limit: 100)
            print("📍 Fetched \(allPlaces.count) places for game rounds")

            // Clear tracking for fresh start
            self.usedPlaceIds.removeAll()
            self.allFetchedPlaces = allPlaces

            // Need at least 2 places to make a single round
            guard allPlaces.count >= 2 else {
                print("⚠️ Not enough places for game, skipping to feed")
                // Skip the game entirely and go straight to feed
                matchmakingComplete = true
                loading = false
                return
            }

            // Shuffle and deduplicate by ID to ensure no repeats
            var seenIds = Set<String>()
            let uniquePlaces = allPlaces.filter { place in
                if seenIds.contains(place.id) {
                    return false
                }
                seenIds.insert(place.id)
                return true
            }
            let shuffled = uniquePlaces.shuffled()

            var rounds: [GameRound] = []
            var index = 0

            // Create as many rounds as possible, up to 10
            let maxRounds = min(10, shuffled.count / 2)
            while rounds.count < maxRounds && index + 1 < shuffled.count {
                let placeA = shuffled[index]
                let placeB = shuffled[index + 1]

                // Track used places
                usedPlaceIds.insert(placeA.id)
                usedPlaceIds.insert(placeB.id)

                rounds.append(GameRound(
                    optionA: mapToOption(placeA),
                    optionB: mapToOption(placeB)
                ))

                index += 2
            }

            print("✅ Generated \(rounds.count) game rounds from \(uniquePlaces.count) unique places")

            // Generate initial preview places (top rated, excluding ones used in rounds)
            let availableForPreview = uniquePlaces.filter { !usedPlaceIds.contains($0.id) }
            self.previewPlaces = Array(availableForPreview.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }.prefix(5))

            // If we couldn't generate any rounds, skip to feed
            if rounds.isEmpty {
                print("⚠️ No rounds generated, skipping to feed")
                matchmakingComplete = true
            } else {
                self.gameRounds = rounds
            }
        } catch {
            print("❌ Error generating game rounds: \(error)")
            // Don't show error, just skip to feed
            matchmakingComplete = true
        }

        loading = false
    }

    /// Generate additional rounds when user wants to keep refining preferences
    func generateAdditionalRounds(count: Int = 5) async -> [GameRound] {
        // Get places not yet used in rounds
        let availablePlaces = allFetchedPlaces.filter { !usedPlaceIds.contains($0.id) }

        guard availablePlaces.count >= 2 else {
            print("⚠️ Not enough unused places for additional rounds")
            return []
        }

        let shuffled = availablePlaces.shuffled()
        var newRounds: [GameRound] = []
        var index = 0

        let maxNewRounds = min(count, shuffled.count / 2)
        while newRounds.count < maxNewRounds && index + 1 < shuffled.count {
            let placeA = shuffled[index]
            let placeB = shuffled[index + 1]

            // Track used places
            usedPlaceIds.insert(placeA.id)
            usedPlaceIds.insert(placeB.id)

            newRounds.append(GameRound(
                optionA: mapToOption(placeA),
                optionB: mapToOption(placeB)
            ))

            index += 2
        }

        print("✅ Generated \(newRounds.count) additional game rounds")

        // Update preview places based on current selected themes
        recalculatePreviewPlaces()

        return newRounds
    }

    /// Get preview places based on given themes (called synchronously when game ends)
    func getPreviewPlaces(for themes: [String]) -> [Place] {
        self.selectedThemes = themes

        // Get places not used in game rounds for preview
        let availablePlaces = allFetchedPlaces.filter { !usedPlaceIds.contains($0.id) }

        guard !availablePlaces.isEmpty else {
            // If no available places, use top rated from all
            let result = Array(allFetchedPlaces.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }.prefix(5))
            self.previewPlaces = result
            return result
        }

        guard !themes.isEmpty else {
            // No themes selected yet, just show top rated
            let result = Array(availablePlaces.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }.prefix(5))
            self.previewPlaces = result
            return result
        }

        // Count theme occurrences to weight preferences
        var themeCounts: [String: Int] = [:]
        for theme in themes {
            themeCounts[theme, default: 0] += 1
        }

        // Score places based on theme match
        let scoredPlaces = availablePlaces.map { place -> (Place, Int) in
            let subcategory = place.subcategory ?? place.category ?? ""
            let score = themeCounts[subcategory] ?? 0
            return (place, score)
        }

        // Sort by score (descending), then by rating
        let sorted = scoredPlaces.sorted { a, b in
            if a.1 != b.1 {
                return a.1 > b.1  // Higher theme match first
            }
            return (a.0.rating ?? 0) > (b.0.rating ?? 0)  // Then by rating
        }

        let result = Array(sorted.prefix(5).map { $0.0 })
        self.previewPlaces = result
        return result
    }

    /// Recalculate preview places based on current selected themes
    private func recalculatePreviewPlaces() {
        // Get places not used in game rounds for preview
        let availablePlaces = allFetchedPlaces.filter { !usedPlaceIds.contains($0.id) }

        guard !availablePlaces.isEmpty else {
            // If no available places, use top rated from all (but this shouldn't happen)
            self.previewPlaces = Array(allFetchedPlaces.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }.prefix(5))
            return
        }

        guard !selectedThemes.isEmpty else {
            // No themes selected yet, just show top rated
            self.previewPlaces = Array(availablePlaces.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }.prefix(5))
            return
        }

        // Count theme occurrences to weight preferences
        var themeCounts: [String: Int] = [:]
        for theme in selectedThemes {
            themeCounts[theme, default: 0] += 1
        }

        // Score places based on theme match
        let scoredPlaces = availablePlaces.map { place -> (Place, Int) in
            let subcategory = place.subcategory ?? place.category ?? ""
            let score = themeCounts[subcategory] ?? 0
            return (place, score)
        }

        // Sort by score (descending), then by rating
        let sorted = scoredPlaces.sorted { a, b in
            if a.1 != b.1 {
                return a.1 > b.1  // Higher theme match first
            }
            return (a.0.rating ?? 0) > (b.0.rating ?? 0)  // Then by rating
        }

        self.previewPlaces = Array(sorted.prefix(5).map { $0.0 })
    }
    
    private func mapToOption(_ place: Place) -> PlaceOption {
        let category = place.category ?? "General"
        let subcategory = place.subcategory ?? category
        
        return PlaceOption(
            name: place.name,
            description: place.description ?? "Discover this place",
            category: category,
            subcategory: subcategory,
            priceRange: place.priceRange
        )
    }
    
    func fetchData(userId: String, isRefresh: Bool = false) async {
        guard let placesService = placesService else {
            errorMessage = "Places service not configured"
            return
        }

        // Guard against duplicate fetches (except for explicit refresh)
        if !isRefresh && isFetchingData {
            print("⏳ Already fetching data, skipping duplicate call")
            return
        }

        // Skip if we already have data (unless refreshing)
        if !isRefresh && !todayFeedItems.isEmpty {
            print("✅ Data already loaded, skipping fetch")
            return
        }

        isFetchingData = true

        if isRefresh {
            refreshing = true
        } else {
            loading = true
        }

        do {
            // Check for task cancellation before long-running operations
            try Task.checkCancellation()

            // Primary: Just fetch all places - simple and reliable
            var places = try await placesService.getAllPlaces(limit: 50)

            // Filter out recently shown if we have enough places left
            if places.count > 10 {
                let filtered = places.filter { !recentlyShownSet.contains($0.id) }
                if filtered.count >= 5 {
                    places = filtered
                }
            }

            // Check for task cancellation
            try Task.checkCancellation()

            // Sort places based on selected themes from the matchmaking game
            // This ensures the feed matches the user's theme preferences
            if !selectedThemes.isEmpty && !isRefresh {
                // Count theme occurrences to weight preferences (same logic as getPreviewPlaces)
                var themeCounts: [String: Int] = [:]
                for theme in selectedThemes {
                    themeCounts[theme, default: 0] += 1
                }
                
                // Score places based on theme match
                let scoredPlaces = places.map { place -> (Place, Int) in
                    let subcategory = place.subcategory ?? place.category ?? ""
                    let score = themeCounts[subcategory] ?? 0
                    return (place, score)
                }
                
                // Sort by score (descending), then by rating
                let sorted = scoredPlaces.sorted { a, b in
                    if a.1 != b.1 {
                        return a.1 > b.1  // Higher theme match first
                    }
                    return (a.0.rating ?? 0) > (b.0.rating ?? 0)  // Then by rating
                }
                
                self.todayFeedItems = sorted.map { $0.0 }
                print("✅ Feed sorted by \(themeCounts.count) selected themes, \(sorted.filter { $0.1 > 0 }.count) places match themes")
            } else {
                // Shuffle for variety (on refresh or if no themes selected)
                self.todayFeedItems = places.shuffled()
            }
            
            // Track as recently shown
            for place in todayFeedItems {
                recentlyShownSet.insert(place.id)
            }
            saveRecentlyShown()
            
            // Fetch visited and saved places in parallel for better performance
            async let visitedPlacesTask = placesService.getUserVisitedPlaces(userId: userId, limit: 100)
            
            var savedPlacesResult: [CollectionsService.SavedPlace] = []
            var defaultColId: String? = nil
            
            if let collectionsService = collectionsService {
                async let defaultCollectionTask = collectionsService.getOrCreateDefaultCollection(userId: userId)
                async let savedPlacesTask = collectionsService.getUserSavedPlaces(userId: userId, limit: 100)
                
                do {
                    defaultColId = try await defaultCollectionTask
                    savedPlacesResult = try await savedPlacesTask
                } catch {
                    // Don't fail the whole fetch if collections fail
                    print("⚠️ Error fetching collections: \(error)")
                }
            }
            
            do {
                let visitedPlaces = try await visitedPlacesTask
                self.likedPlaces = Set(visitedPlaces.map { $0.placeId })
            } catch {
                // Don't fail the whole fetch if visited places fail
                print("⚠️ Error fetching visited places: \(error)")
            }
            
            self.defaultCollectionId = defaultColId
            self.savedPlaces = Set(savedPlacesResult.map { $0.placeId })
            
            // Build savedMap for UI
            var newSavedMap: [String: [String]] = [:]
            newSavedMap["all_saved"] = savedPlacesResult.map { $0.placeId }
            
            for savedPlace in savedPlacesResult {
                let collectionName = savedPlace.collectionName ?? "Want to Go"
                if newSavedMap[collectionName] == nil {
                    newSavedMap[collectionName] = []
                }
                newSavedMap[collectionName]?.append(savedPlace.placeId)
            }
            self.savedMap = newSavedMap
            
        } catch is CancellationError {
            print("⏹️ Fetch was cancelled (view likely changed)")
            // Don't set error message for cancellation - it's expected behavior
        } catch {
            print("❌ Error fetching today feed: \(error)")
            // Only set error if we truly have no data at all
            // Try one more time with a simple fetch
            if todayFeedItems.isEmpty {
                do {
                    let fallbackPlaces = try await placesService.getAllPlaces(limit: 30)
                    if !fallbackPlaces.isEmpty {
                        // Apply theme-based sorting even in fallback
                        if !selectedThemes.isEmpty {
                            var themeCounts: [String: Int] = [:]
                            for theme in selectedThemes {
                                themeCounts[theme, default: 0] += 1
                            }
                            let scoredPlaces = fallbackPlaces.map { place -> (Place, Int) in
                                let subcategory = place.subcategory ?? place.category ?? ""
                                return (place, themeCounts[subcategory] ?? 0)
                            }
                            let sorted = scoredPlaces.sorted { a, b in
                                if a.1 != b.1 { return a.1 > b.1 }
                                return (a.0.rating ?? 0) > (b.0.rating ?? 0)
                            }
                            self.todayFeedItems = sorted.map { $0.0 }
                        } else {
                            self.todayFeedItems = fallbackPlaces.shuffled()
                        }
                        print("✅ Fallback fetch succeeded with \(fallbackPlaces.count) places")
                    } else {
                        errorMessage = "No places available. Please try again later."
                    }
                } catch {
                    errorMessage = "Unable to load places. Please check your connection."
                }
            }
        }

        loading = false
        refreshing = false
        isFetchingData = false
    }
    
    func markMatchmakingComplete() {
        matchmakingComplete = true
        saveMatchmakingComplete()
    }

    /// Reset matchmaking state to replay the game
    func resetMatchmaking() {
        matchmakingComplete = false
        selectedThemes = []
        gameRounds = []
        previewPlaces = []
        todayFeedItems = []
        allFetchedPlaces = []
        usedPlaceIds = []
        
        // Clear persisted state
        UserDefaults.standard.set(false, forKey: matchmakingCompleteKey)
        UserDefaults.standard.removeObject(forKey: selectedThemesKey)
        
        print("🔄 Matchmaking state reset, ready to replay game")
    }
    
    func toggleLike(placeId: String, isLiked: Bool, userId: String) async {
        guard let placesService = placesService else { return }
        
        // Optimistic update
        if isLiked {
            likedPlaces.insert(placeId)
        } else {
            likedPlaces.remove(placeId)
        }
        
        do {
            if isLiked {
                _ = try await placesService.recordPlaceVisit(userId: userId, placeId: placeId)
            } else {
                try await placesService.removePlaceVisit(userId: userId, placeId: placeId)
            }
        } catch {
            print("❌ Error toggling like: \(error)")
            // Revert on error
            if isLiked {
                likedPlaces.remove(placeId)
            } else {
                likedPlaces.insert(placeId)
            }
        }
    }
    
    func toggleSave(placeId: String, listName: String, userId: String) async {
        guard let collectionsService = collectionsService else { return }

        let isSaved = savedPlaces.contains(placeId)

        // Optimistic update
        if isSaved {
            savedPlaces.remove(placeId)
            savedMap["all_saved"]?.removeAll { $0 == placeId }
        } else {
            savedPlaces.insert(placeId)
            if savedMap["all_saved"] == nil {
                savedMap["all_saved"] = []
            }
            savedMap["all_saved"]?.append(placeId)
        }

        do {
            if isSaved {
                try await collectionsService.unsavePlaceFromAll(userId: userId, placeId: placeId)
            } else {
                var collectionId = defaultCollectionId
                if collectionId == nil {
                    collectionId = try await collectionsService.getOrCreateDefaultCollection(userId: userId)
                    self.defaultCollectionId = collectionId
                }
                _ = try await collectionsService.savePlace(userId: userId, placeId: placeId, collectionId: collectionId!)
            }
        } catch {
            print("❌ Error toggling save: \(error)")
            // Revert
            if isSaved {
                savedPlaces.insert(placeId)
                savedMap["all_saved"]?.append(placeId)
            } else {
                savedPlaces.remove(placeId)
                savedMap["all_saved"]?.removeAll { $0 == placeId }
            }
        }
    }
}

// MatchmakingFlowView is now in MatchmakingFlow.swift
