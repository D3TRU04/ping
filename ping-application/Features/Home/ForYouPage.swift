//
//  ForYouPage.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/for-you/page.tsx
//  ForYou feed page matching RN implementation
//

import SwiftUI
import Combine

struct ForYouPage: View {
    let currentUser: User?
    let activeTab: SecondaryNavBarTab
    @StateObject private var viewModel = ForYouViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: "FAF6F2")
                .ignoresSafeArea()
            
            if let userId = currentUser?.id {
                FeedView(
                    items: viewModel.contentData,
                    liked: viewModel.likedPlaces,
                    savedMap: viewModel.savedMap,
                    refreshing: viewModel.refreshing,
                    loading: viewModel.loading,
                    onRefresh: {
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
                    await viewModel.fetchData(userId: userId)
                }
            } else {
                VStack {
                    Text("Please log in to see your personalized feed")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
    }
}

@MainActor
class ForYouViewModel: ObservableObject {
    @Published var contentData: [Place] = []
    @Published var loading: Bool = false
    @Published var refreshing: Bool = false
    @Published var likedPlaces: Set<String> = []
    @Published var savedMap: [String: [String]] = [:]
    @Published var erroredImages: Set<String> = []
    @Published var currentIndex: Int = 0
    
    func fetchData(userId: String, isRefresh: Bool = false) async {
        if isRefresh {
            refreshing = true
        } else {
            loading = true
        }

        // TODO: Fetch data from Supabase matching RN implementation
        // - Fetch user profile with category_preferences, liked, saved
        // - Fetch places for each category/subcategory
        // - Filter out already liked places

        loading = false
        refreshing = false
    }
    
    func toggleLike(placeId: String, isLiked: Bool) {
        if isLiked {
            likedPlaces.insert(placeId)
        } else {
            likedPlaces.remove(placeId)
        }
        // TODO: Update in Supabase
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
        // TODO: Update in Supabase
    }
}
