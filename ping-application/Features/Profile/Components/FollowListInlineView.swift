//
//  FollowListInlineView.swift
//  PingNative
//
//  Inline followers/following list that replaces profile content
//

import SwiftUI

enum FollowListTab: String, CaseIterable {
    case followers = "Followers"
    case following = "Following"
}

struct FollowListInlineView: View {
    @ObservedObject var viewModel: FollowListViewModel
    @Binding var activeTab: FollowListTab
    let currentUserId: String
    let appEnvironment: AppEnvironment

    @Namespace private var tabAnimation
    @State private var selectedUserId: String? = nil
    @State private var navigateToProfile: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Tab Selector
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(FollowListTab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                activeTab = tab
                                viewModel.searchQuery = ""
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Text(tab.rawValue)
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(activeTab == tab ? AppColors.textPrimary : AppColors.textSecondary)
                                    .frame(maxWidth: .infinity)

                                if activeTab == tab {
                                    Rectangle()
                                        .fill(AppColors.textPrimary)
                                        .frame(height: 1.5)
                                        .matchedGeometryEffect(id: "followTabUnderline", in: tabAnimation)
                                        .padding(.horizontal, 16)
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 1.5)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }
                }
                .padding(.top, 4)

                Divider()
                    .overlay(Color.primary.opacity(0.05))
            }
            .padding(.bottom, 16)

            // MARK: - Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)

                TextField(
                    activeTab == .followers ? "Search followers..." : "Search following...",
                    text: $viewModel.searchQuery
                )
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                if !viewModel.searchQuery.isEmpty {
                    Button(action: { viewModel.searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .glassInputStyle(cornerRadius: 24)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)

            // MARK: - User List
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                let users = activeTab == .followers
                    ? viewModel.filteredFollowers()
                    : viewModel.filteredFollowing()

                if users.isEmpty {
                    VStack(spacing: 8) {
                        Spacer().frame(height: 40)
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.textTertiary)
                        Text(viewModel.searchQuery.isEmpty
                             ? "No \(activeTab.rawValue.lowercased()) yet"
                             : "No results found")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(users, id: \.id) { user in
                                FollowListRow(
                                    user: user,
                                    currentUserId: currentUserId,
                                    isFollowing: viewModel.isFollowingMap[user.id] ?? false,
                                    theyFollowMe: viewModel.theyFollowMeMap[user.id] ?? false,
                                    onToggleFollow: {
                                        Task {
                                            await viewModel.toggleFollow(
                                                userId: user.id,
                                                currentUserId: currentUserId,
                                                appEnvironment: appEnvironment
                                            )
                                        }
                                    },
                                    onTapUser: {
                                        selectedUserId = user.id
                                        navigateToProfile = true
                                    }
                                )
                            }

                            Spacer().frame(height: 120)
                        }
                    }
                }
            }
        }
        .background(
            // Hidden NavigationLink for profile navigation
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
        )
    }
}
