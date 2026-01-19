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
            
            if viewModel.todayFeedItems.isEmpty && !viewModel.loading {
                MatchmakingFlowView(
                    onFinished: { selectedThemes in
                        // Store selected themes if needed
                        Task {
                            await viewModel.fetchData(userId: currentUser?.id ?? "")
                        }
                    }
                )
            } else if let userId = currentUser?.id {
                FeedView(
                    items: viewModel.todayFeedItems,
                    liked: viewModel.likedPlaces,
                    savedMap: viewModel.savedMap,
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
    
    private var recentlyShownSet: Set<String> = []
    private var placesService: PlacesService?
    private var collectionsService: CollectionsService?
    private var defaultCollectionId: String?
    private let recentlyShownKey = "recentlyShownPlaceIds"
    
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
    
    func fetchData(userId: String, isRefresh: Bool = false) async {
        guard let placesService = placesService else {
            errorMessage = "Places service not configured"
            return
        }
        
        if isRefresh {
            refreshing = true
        } else {
            loading = true
        }

        do {
            // Today page shows a curated selection - limit 2 per category
            let categoryPreferences: [String: [String]] = [
                "Food & Drink": ["Restaurants", "Cafes"],
                "Entertainment": ["Movies", "Music"],
                "Outdoors": ["Parks", "Nature"]
            ]
            
            // Combine recently shown and liked places to exclude
            var excludeIds = Array(recentlyShownSet)
            excludeIds.append(contentsOf: likedPlaces)
            
            let places = try await placesService.fetchPlaces(
                categoryPreferences: categoryPreferences,
                excludeIds: excludeIds,
                limit: 20
            )
            
            // Shuffle and limit for "Today" curated feel
            self.todayFeedItems = places.shuffled()
            
            // Track as recently shown
            for place in todayFeedItems {
                recentlyShownSet.insert(place.id)
            }
            saveRecentlyShown()
            
            // Also fetch user's visited places
            let visitedPlaces = try await placesService.getUserVisitedPlaces(userId: userId, limit: 100)
            self.likedPlaces = Set(visitedPlaces.map { $0.placeId })

            // Fetch saved places
            if let collectionsService = collectionsService {
                // Get or create default collection
                self.defaultCollectionId = try await collectionsService.getOrCreateDefaultCollection(userId: userId)

                // Fetch saved places
                let saved = try await collectionsService.getUserSavedPlaces(userId: userId, limit: 100)
                self.savedPlaces = Set(saved.map { $0.placeId })

                // Build savedMap for UI
                var newSavedMap: [String: [String]] = [:]
                newSavedMap["all_saved"] = saved.map { $0.placeId }
                
                for savedPlace in saved {
                    let collectionName = savedPlace.collectionName ?? "Want to Go"
                    if newSavedMap[collectionName] == nil {
                        newSavedMap[collectionName] = []
                    }
                    newSavedMap[collectionName]?.append(savedPlace.placeId)
                }
                self.savedMap = newSavedMap
            }
            
        } catch {
            print("❌ Error fetching today feed: \(error)")
            errorMessage = error.localizedDescription
        }

        loading = false
        refreshing = false
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
