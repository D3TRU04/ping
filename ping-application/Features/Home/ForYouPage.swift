//
//  ForYouPage.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/for-you/page.tsx
//  ForYou feed page connected to Convex database
//

import SwiftUI
import Combine

struct ForYouPage: View {
    let currentUser: User?
    let activeTab: SecondaryNavBarTab
    @StateObject private var viewModel = ForYouViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    let onUpdatePreferences: () -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "FAFAFA")
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
                            await viewModel.fetchData(
                                userId: userId,
                                categoryPreferences: currentUser?.categoryPreferences,
                                isRefresh: true
                            )
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
                        Task {
                            await viewModel.toggleLike(placeId: placeId, isLiked: isLiked, userId: userId)
                        }
                    },
                    onSaveChange: { placeId, listName in
                        viewModel.toggleSave(placeId: placeId, listName: listName)
                    },
                    onUpdatePreferences: {
                        onUpdatePreferences()
                    }
                )
                .task {
                    viewModel.configure(placesService: appEnvironment.placesService)
                    await viewModel.fetchData(
                        userId: userId,
                        categoryPreferences: currentUser?.categoryPreferences
                    )
                }
            } else {
                VStack(spacing: 16) {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color(hex: "F3F4F6"))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Sign in to continue")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Please log in to see your personalized feed")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
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
    @Published var errorMessage: String?
    
    private var placesService: PlacesService?
    
    func configure(placesService: PlacesService) {
        self.placesService = placesService
    }
    
    func fetchData(userId: String, categoryPreferences: [String: [String]]? = nil, isRefresh: Bool = false) async {
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
            // Use user's category preferences, or fall back to defaults
            let preferences = categoryPreferences ?? getDefaultPreferences()

            // Get already liked places to exclude
            let excludeIds = Array(likedPlaces)

            let places = try await placesService.fetchPlaces(
                categoryPreferences: preferences,
                excludeIds: excludeIds,
                limit: 50
            )
            
            self.contentData = places
            
            // Also fetch user's visited places to mark as liked
            let visitedPlaces = try await placesService.getUserVisitedPlaces(userId: userId, limit: 100)
            self.likedPlaces = Set(visitedPlaces.map { $0.placeId })
            
        } catch {
            print("❌ Error fetching feed data: \(error)")
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
            // Revert optimistic update on error
            if isLiked {
                likedPlaces.remove(placeId)
            } else {
                likedPlaces.insert(placeId)
            }
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
        // TODO: Implement save to collection in Convex
    }

    private func getDefaultPreferences() -> [String: [String]] {
        // Default category preferences when user hasn't set any
        return [
            "Food & Drink": ["Restaurants", "Cafes", "Bars", "Coffee"],
            "Entertainment": ["Movies", "Music", "Games", "Nightlife"],
            "Outdoors": ["Parks", "Hiking", "Beaches", "Nature"],
            "Shopping": ["Malls", "Boutiques", "Markets"]
        ]
    }
}
