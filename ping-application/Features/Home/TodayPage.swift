//
//  TodayPage.swift
//  PingNative
//
//  Today feed page connected to Supabase database
//

import SwiftUI

struct TodayPage: View {
    let currentUser: User?
    @StateObject private var viewModel = TodayViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    var onUpdatePreferences: (() -> Void)? = nil
    var onReplayGameRequest: ((@escaping () -> Void) -> Void)? = nil

    var body: some View {
        ZStack {
            // Background provided by HomeView
            content
        }
        .onAppear {
            onReplayGameRequest? { [viewModel, appEnvironment] in
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

    @ViewBuilder
    private var content: some View {
        if let errorMessage = viewModel.errorMessage, viewModel.todayFeedItems.isEmpty {
            TodayErrorView(
                errorMessage: errorMessage,
                onRetry: {
                    viewModel.errorMessage = nil
                    Task {
                        await viewModel.generateGameRounds()
                    }
                }
            )
        } else if !viewModel.matchmakingComplete && viewModel.gameRounds.isEmpty {
            TodayLoadingView(
                viewModel: viewModel,
                appEnvironment: appEnvironment
            )
        } else if !viewModel.matchmakingComplete && !viewModel.gameRounds.isEmpty {
            TodayMatchmakingView(viewModel: viewModel)
        } else if let userId = currentUser?.id {
            TodayFeedContentView(
                viewModel: viewModel,
                userId: userId,
                appEnvironment: appEnvironment,
                onUpdatePreferences: onUpdatePreferences
            )
        }
    }
}

// MARK: - Error View

struct TodayErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void

    var body: some View {
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
            Button("Try Again", action: onRetry)
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primaryAction)
        }
        .padding()
    }
}

// MARK: - Loading View

struct TodayLoadingView: View {
    @ObservedObject var viewModel: TodayViewModel
    let appEnvironment: AppEnvironment

    var body: some View {
        ProgressView()
            .task {
                viewModel.configure(
                    placesService: appEnvironment.placesService,
                    collectionsService: appEnvironment.collectionsService
                )
                await viewModel.generateGameRounds()
            }
    }
}

// MARK: - Matchmaking View

struct TodayMatchmakingView: View {
    @ObservedObject var viewModel: TodayViewModel

    var body: some View {
        MatchmakingFlowView(
            rounds: viewModel.gameRounds,
            onFinished: { selectedThemes in
                viewModel.selectedThemes = selectedThemes
                viewModel.markMatchmakingComplete()
            },
            onRequestMoreRounds: { currentThemes in
                return await viewModel.generateAdditionalRounds(count: 5)
            },
            onUpdatePreview: { themes in
                return viewModel.getPreviewPlaces(for: themes)
            }
        )
    }
}

// MARK: - Feed Content View

struct TodayFeedContentView: View {
    @ObservedObject var viewModel: TodayViewModel
    let userId: String
    let appEnvironment: AppEnvironment
    var onUpdatePreferences: (() -> Void)?

    var body: some View {
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
