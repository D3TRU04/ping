//
//  PublicProfileView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/public/page.tsx (implied)
//  Public profile view for viewing other users' profiles
//

import SwiftUI
import Combine

struct PublicProfileView: View {
    let userId: String
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = PublicProfileViewModel()
    @State private var activeTab: ProfileTabType = .saved
    @Environment(\.dismiss) var dismiss
    
    // Consistent background color
    private let backgroundColor = Color(hex: "FAFAFA")

    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor.ignoresSafeArea()

            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .tint(AppColors.mint)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Spacer for fixed nav bar
                        Spacer().frame(height: 30)

                        // Profile Card
                        ProfileCard(
                            profilePicture: viewModel.profilePicture,
                            fullName: viewModel.profile?.fullName ?? "User",
                            pronouns: viewModel.profile?.pronouns,
                            username: viewModel.profile?.username ?? "",
                            creationDate: viewModel.creationDate,
                            bio: viewModel.profile?.bio,
                            location: viewModel.profile?.location,
                            links: viewModel.profile?.links?.joined(separator: ", "),
                            currentUserId: appEnvironment.currentUser?.id,
                            profileUserId: userId,
                            showFollowButton: userId != appEnvironment.currentUser?.id,
                            showUsernameUnderName: false,
                            isFollowing: $viewModel.isFollowing,
                            onFollowChange: { isFollowing in
                                viewModel.isFollowing = isFollowing
                                Task {
                                    await viewModel.updateFollowCounts(appEnvironment: appEnvironment)
                                }
                            }
                        ) {
                            AnyView(
                                VStack(spacing: 0) {
                                    ProfileStats(
                                        following: viewModel.following,
                                        followers: viewModel.followers,
                                        onPressFollowing: {
                                            // Navigate to Following screen
                                        },
                                        onPressFollowers: {
                                            // Navigate to Followers screen
                                        }
                                    )

                                    ProfileTabs(activeTab: $activeTab)
                                }
                            )
                        }
                        .padding(.top, 8)

                        // Divider
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 1)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)

                        // Tab Content
                        ProfileTabContent(
                            activeTab: activeTab,
                            currentUser: viewModel.profileUser,
                            isOwnProfile: false,
                            likedPlaces: [],
                            savedPlaces: [],
                            isLoading: false
                        )

                        // Bottom spacing
                        Spacer().frame(height: 40)
                    }
                }
            }

            // Top Nav Bar
            PublicProfileTopNavBar(
                userName: viewModel.profile?.username ?? "Profile",
                onBack: { dismiss() }
            )
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.load(userId: userId, appEnvironment: appEnvironment)
        }
    }
}

@MainActor
class PublicProfileViewModel: ObservableObject {
    @Published var profile: User?
    @Published var followers: Int = 0
    @Published var following: Int = 0
    @Published var isFollowing: Bool = false
    @Published var isLoading: Bool = false

    var profilePicture: ImageSource {
        if let pictureUrl = profile?.profilePicture, let url = URL(string: pictureUrl) {
            return .url(url)
        }
        return .image("profilepic")
    }

    var creationDate: String? {
        guard let createdAt = profile?.createdAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: createdAt)
    }

    var profileUser: User? {
        profile
    }

    func load(userId: String, appEnvironment: AppEnvironment) async {
        isLoading = true

        do {
            // Load profile
            profile = try await appEnvironment.profileService.fetchProfile(userId: userId)

            // Load follow counts
            await updateFollowCounts(appEnvironment: appEnvironment)

            // Check if current user is following
            if let currentUserId = appEnvironment.currentUser?.id {
                isFollowing = try await appEnvironment.profileService.isFollowing(
                    followerId: currentUserId,
                    followingId: userId
                )
            }
        } catch {
            // Handle error
        }

        isLoading = false
    }

    func updateFollowCounts(appEnvironment: AppEnvironment) async {
        guard let userId = profile?.id else { return }

        do {
            let followersList = try await appEnvironment.profileService.fetchFollowers(userId: userId)
            let followingList = try await appEnvironment.profileService.fetchFollowing(userId: userId)

            followers = followersList.count
            following = followingList.count
        } catch {
            // Handle error
        }
    }
}

struct PublicProfileTopNavBar: View {
    let userName: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onBack) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            }

            Text("@\(userName)")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 0)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [Color(hex: "FAFAFA").opacity(0.95), Color(hex: "FAFAFA").opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
