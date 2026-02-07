//
//  ForYouPage.swift
//  PingNative
//
//  ForYou feed page connected to Supabase database
//
//  Related files:
//  - ForYouViewModel.swift - ViewModel for feed data management
//  - FilterModels.swift - Filter enums and structs
//  - FilterComponents.swift - Filter UI components
//

import SwiftUI

struct ForYouPage: View {
    let currentUser: User?
    let activeTab: SecondaryNavBarTab
    @ObservedObject var viewModel: ForYouViewModel
    @EnvironmentObject var appEnvironment: AppEnvironment
    let onUpdatePreferences: () -> Void
    @Binding var filters: PlaceFilters
    @Binding var showFilterSheet: Bool

    private var transformedPreferences: [String: [String]]? {
        currentUser?.categoryPreferences?.toPlacesQueryFormat(using: OnboardingData.categories)
    }

    var body: some View {
        ZStack {
            // Background provided by HomeView

            if let userId = currentUser?.id {
                feedContent(userId: userId)
            } else {
                signInPrompt
            }
        }
    }

    @ViewBuilder
    private func feedContent(userId: String) -> some View {
        FeedView(
            items: viewModel.contentData,
            liked: viewModel.likedPlaces,
            saved: viewModel.savedPlaces,
            refreshing: viewModel.refreshing,
            loading: viewModel.loading,
            onRefresh: {
                await viewModel.fetchData(
                    userId: userId,
                    categoryPreferences: transformedPreferences,
                    isRefresh: true,
                    filters: filters
                )
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
            onUpdatePreferences: {
                onUpdatePreferences()
            }
        )
        .onAppear {
            // Ensure services are configured
            if viewModel.placesService == nil {
                viewModel.configure(
                    placesService: appEnvironment.placesService,
                    collectionsService: appEnvironment.collectionsService,
                    notificationsService: appEnvironment.notificationsService,
                    profileService: appEnvironment.profileService
                )
            }
            // Only fetch if no data yet and not currently loading/fetching
            if viewModel.contentData.isEmpty && !viewModel.loading && !viewModel.isFetchingData {
                let vm = viewModel
                let prefs = transformedPreferences
                let f = filters
                Task { @MainActor in
                    await vm.fetchData(
                        userId: userId,
                        categoryPreferences: prefs,
                        filters: f
                    )
                }
            }
        }
        .onChange(of: filters.sortBy) { _ in
            viewModel.applyFilters(filters)
        }
        .onChange(of: filters.minRating) { _ in
            viewModel.applyFilters(filters)
        }
        .onChange(of: filters.maxPrice) { _ in
            viewModel.applyFilters(filters)
        }
    }

    private var signInPrompt: some View {
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
                    .font(.system(size: 18, weight: .regular, design: .rounded))
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
