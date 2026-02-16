//
//  FollowersView.swift
//  PingNative
//
//  Followers list view
//
//  Related files:
//  - FollowingView.swift - Following list view
//

import SwiftUI
import Combine

struct FollowersView: View {
    let userId: String
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = FollowersViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LiquidGlassBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Glass-style nav bar
                HStack(alignment: .center) {
                    GlassCircleButton(icon: "arrow.backward", action: { dismiss() })

                    Spacer()

                    Text("Followers")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    // Invisible spacer for centering
                    Color.clear
                        .frame(width: 48, height: 48)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)

                if viewModel.loading {
                    ProgressView()
                        .tint(AppColors.mint)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.followers.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2")
                            .font(.system(size: 64))
                            .foregroundColor(AppColors.textTertiary)

                        Text("No followers yet")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.followers) { user in
                        FollowerRow(user: user) {
                            // Navigate to user profile
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.load(userId: userId, appEnvironment: appEnvironment)
        }
    }
}

struct FollowerRow: View {
    let user: User
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ProfileImageView(source: profileImageSource)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(user.fullName ?? user.username ?? "User")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    if let username = user.username {
                        Text("@\(username)")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var profileImageSource: ImageSource {
        if let urlString = user.profilePicture, let url = URL(string: urlString) {
            return .url(url)
        }
        return .url(nil)
    }
}

@MainActor
class FollowersViewModel: ObservableObject {
    @Published var followers: [User] = []
    @Published var loading: Bool = false

    func load(userId: String, appEnvironment: AppEnvironment) async {
        loading = true

        do {
            followers = try await appEnvironment.profileService.fetchFollowers(userId: userId)
        } catch {
            // Handle error
        }

        loading = false
    }
}
