//
//  SearchUsersView.swift
//  PingNative
//
//  User search screen with recent searches
//

import SwiftUI
import Combine

struct SearchUsersView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = SearchUsersViewModel()
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    @State private var selectedUserId: String?
    @State private var navigateToProfile: Bool = false

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack(spacing: 0) {
                SearchUsersHeader(
                    searchQuery: $viewModel.searchQuery,
                    isFocused: _isFocused,
                    onDismiss: { dismiss() },
                    onSearchChange: {
                        Task {
                            await viewModel.searchUsers(
                                query: viewModel.searchQuery,
                                appEnvironment: appEnvironment
                            )
                        }
                    }
                )

                SearchUsersContentView(
                    viewModel: viewModel,
                    selectedUserId: $selectedUserId,
                    navigateToProfile: $navigateToProfile
                )
            }

            NavigationLink(
                destination: Group {
                    if let userId = selectedUserId {
                        PublicProfileView(userId: userId)
                            .environmentObject(appEnvironment)
                    }
                },
                isActive: $navigateToProfile
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationBarHidden(true)
        .onAppear {
            isFocused = true
        }
        .task {
            await viewModel.loadRecentSearches()
        }
    }
}
