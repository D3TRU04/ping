//
//  DiscoverUserResults.swift
//  PingNative
//
//  User search results component for Discover screen
//

import SwiftUI

struct DiscoverUserResults: View {
    let users: [ProfileSearchResult]
    let loading: Bool
    let onUserSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            UserResultsHeader(usersCount: users.count)

            UserResultsContent(
                users: users,
                loading: loading,
                onUserSelect: onUserSelect
            )
        }
        .frame(height: UIScreen.main.bounds.height * 0.7)
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
        .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: -10)
    }
}

// MARK: - User Results Header
private struct UserResultsHeader: View {
    let usersCount: Int

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "D1D5DB"))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 10)

            HStack(alignment: .center) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "6EE7E7").opacity(0.3), Color(hex: "1FC9C3").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)

                        Image(systemName: "person.2.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "1FC9C3"))
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Users")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Text("\(usersCount) result\(usersCount != 1 ? "s" : "")")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

// MARK: - User Results Content
private struct UserResultsContent: View {
    let users: [ProfileSearchResult]
    let loading: Bool
    let onUserSelect: (String) -> Void

    var body: some View {
        ZStack {
            Color(hex: "F5F5F7")

            if loading {
                UserResultsLoadingView()
            } else if users.isEmpty {
                UserResultsEmptyView()
            } else {
                UserResultsListView(users: users, onUserSelect: onUserSelect)
            }
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - User Results Loading View
private struct UserResultsLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1FC9C3")))
                .scaleEffect(1.2)
            Text("Searching users...")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
    }
}

// MARK: - User Results Empty View
private struct UserResultsEmptyView: View {
    var body: some View {
        VStack(spacing: 14) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)

                Image(systemName: "person.slash")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "B2BEC3"))
            }

            VStack(spacing: 4) {
                Text("No users found")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Try a different search")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()
        }
    }
}

// MARK: - User Results List View
private struct UserResultsListView: View {
    let users: [ProfileSearchResult]
    let onUserSelect: (String) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(users.enumerated()), id: \.element.id) { index, user in
                    UserSearchResultRow(user: user)
                        .onTapGesture {
                            onUserSelect(user.id)
                        }

                    if index < users.count - 1 {
                        Divider()
                            .padding(.leading, 68)
                            .opacity(0.4)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }
}
