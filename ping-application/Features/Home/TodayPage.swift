//
//  TodayPage.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/today/page.tsx
//  Today feed page matching RN implementation
//

import SwiftUI
import Combine

struct TodayPage: View {
    let currentUser: User?
    @StateObject private var viewModel = TodayViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: "FAF6F2")
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
                        Task {
                            await viewModel.fetchData(userId: userId, isRefresh: true)
                        }
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
                        viewModel.toggleLike(placeId: placeId, isLiked: isLiked)
                    },
                    onSaveChange: { placeId, listName in
                        viewModel.toggleSave(placeId: placeId, listName: listName)
                    }
                )
                .task {
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
    @Published var savedMap: [String: [String]] = [:]
    @Published var erroredImages: Set<String> = []
    @Published var currentIndex: Int = 0
    private var recentlyShownSet: Set<String> = []
    
    func loadRecentlyShown() async {
        // TODO: Load from UserDefaults/Keychain matching RN AsyncStorage
        // let stored = UserDefaults.standard.array(forKey: "recentlyShownPlaceIds") as? [String]
        // recentlyShownSet = Set(stored ?? [])
    }
    
    func clearRecentlyShown() {
        recentlyShownSet.removeAll()
        // TODO: Clear from UserDefaults
    }
    
    func fetchData(userId: String, isRefresh: Bool = false) async {
        if isRefresh {
            refreshing = true
        } else {
            loading = true
        }

        // TODO: Fetch data from Supabase matching RN implementation
        // - Fetch user profile with category_preferences, liked, saved
        // - Fetch places for each category/subcategory (limit 2 per type)
        // - Filter out liked, saved, and recently shown places
        // - Track recently shown places

        loading = false
        refreshing = false
    }
    
    func toggleLike(placeId: String, isLiked: Bool) {
        if isLiked {
            likedPlaces.insert(placeId)
        } else {
            likedPlaces.remove(placeId)
        }
    }
    
    func toggleSave(placeId: String, listName: String) {
        if savedMap[listName] == nil {
            savedMap[listName] = []
        }
        if let index = savedMap[listName]?.firstIndex(of: placeId) {
            savedMap[listName]?.remove(at: index)
        } else {
            savedMap[listName]?.append(placeId)
        }
    }
}

// MatchmakingFlowView is now in MatchmakingFlow.swift

