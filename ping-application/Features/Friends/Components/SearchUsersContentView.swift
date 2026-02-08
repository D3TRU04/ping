//
//  SearchUsersContentView.swift
//  PingNative
//
//  Content views for user search screen
//
//  Related files:
//  - SearchUsersStateViews.swift - Loading, empty, and no results views
//

import SwiftUI

struct SearchUsersContentView: View {
    @ObservedObject var viewModel: SearchUsersViewModel
    @Binding var selectedUserId: String?
    @Binding var navigateToProfile: Bool

    var body: some View {
        if viewModel.loading {
            SearchUsersLoadingView()
        } else if viewModel.searchQuery.isEmpty {
            if viewModel.recentSearches.isEmpty {
                SearchUsersEmptyStateView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                SearchUsersRecentView(
                    viewModel: viewModel,
                    selectedUserId: $selectedUserId,
                    navigateToProfile: $navigateToProfile
                )
            }
        } else if viewModel.searchResults.isEmpty {
            SearchUsersNoResultsView()
        } else {
            SearchUsersResultsView(
                viewModel: viewModel,
                selectedUserId: $selectedUserId,
                navigateToProfile: $navigateToProfile
            )
        }
    }
}

struct SearchUsersRecentView: View {
    @ObservedObject var viewModel: SearchUsersViewModel
    @Binding var selectedUserId: String?
    @Binding var navigateToProfile: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Recent")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()

                    Button(action: {
                        withAnimation {
                            viewModel.clearRecentSearches()
                        }
                    }) {
                        Text("Clear")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.mint)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)

                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.recentSearches.enumerated()), id: \.element.id) { index, user in
                        UserSearchRow(
                            user: user,
                            onTap: {
                                viewModel.saveRecentSearch(user: user)
                                selectedUserId = user.id
                                navigateToProfile = true
                            },
                            onRemove: {
                                withAnimation {
                                    viewModel.removeRecentSearch(userId: user.id)
                                }
                            }
                        )

                        if index < viewModel.recentSearches.count - 1 {
                            Divider()
                                .padding(.leading, 70)
                                .padding(.trailing, 0)
                                .opacity(0.4)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct SearchUsersResultsView: View {
    @ObservedObject var viewModel: SearchUsersViewModel
    @Binding var selectedUserId: String?
    @Binding var navigateToProfile: Bool

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, user in
                    UserSearchRow(
                        user: user,
                        onTap: {
                            viewModel.saveRecentSearch(user: user)
                            selectedUserId = user.id
                            navigateToProfile = true
                        }
                    )

                    if index < viewModel.searchResults.count - 1 {
                        Divider()
                            .padding(.leading, 70)
                            .padding(.trailing, 0)
                            .opacity(0.4)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }
}
