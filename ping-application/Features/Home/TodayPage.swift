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
                        // Mark matchmaking as complete - FeedView will handle data fetch
                        viewModel.markMatchmakingComplete()
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
    
    private var recentlyShownSet: Set<String> = []
    private var placesService: PlacesService?
    private var collectionsService: CollectionsService?
    private var defaultCollectionId: String?
    private let recentlyShownKey = "recentlyShownPlaceIds"
    private var isFetchingData: Bool = false
    
    func configure(placesService: PlacesService, collectionsService: CollectionsService) {
        self.placesService = placesService
        self.collectionsService = collectionsService
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
        guard let placesService = placesService else {
            print("❌ PlacesService not configured for generateGameRounds")
            errorMessage = "Service not configured"
            return
        }

        loading = true

        do {
            let allPlaces = try await placesService.getAllPlaces(limit: 100)
            print("📍 Fetched \(allPlaces.count) places for game rounds")

            // Need at least 2 places to make a single round
            guard allPlaces.count >= 2 else {
                print("⚠️ Not enough places for game, skipping to feed")
                // Skip the game entirely and go straight to feed
                matchmakingComplete = true
                loading = false
                return
            }

            let shuffled = allPlaces.shuffled()

            var rounds: [GameRound] = []
            var index = 0

            // Create as many rounds as possible, up to 10
            let maxRounds = min(10, shuffled.count / 2)
            while rounds.count < maxRounds && index + 1 < shuffled.count {
                let placeA = shuffled[index]
                let placeB = shuffled[index + 1]

                rounds.append(GameRound(
                    optionA: mapToOption(placeA),
                    optionB: mapToOption(placeB)
                ))

                index += 2
            }

            print("✅ Generated \(rounds.count) game rounds")
            
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
            
            // Shuffle for variety
            self.todayFeedItems = places.shuffled()
            
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
                        self.todayFeedItems = fallbackPlaces.shuffled()
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
