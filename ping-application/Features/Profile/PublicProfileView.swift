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
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FAF6F2"), Color(hex: "F5F5F5")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Card
                    ProfileCard(
                        profilePicture: viewModel.profilePicture,
                        fullName: viewModel.profile?.fullName ?? "User",
                        pronouns: viewModel.profile?.pronouns,
                        username: viewModel.profile?.username ?? "",
                        creationDate: viewModel.creationDate,
                        bio: viewModel.profile?.bio,
                        location: viewModel.profile?.location,
                        links: viewModel.profile?.links,
                        currentUserId: appEnvironment.currentUser?.id,
                        profileUserId: userId,
                        showFollowButton: userId != appEnvironment.currentUser?.id,
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
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    
                    // Tab Content
                    ProfileTabContent(
                        activeTab: activeTab,
                        currentUser: viewModel.profileUser,
                        isOwnProfile: false
                    )
                    .frame(minHeight: 200)
                }
            }
            
            // Top Nav Bar
            VStack {
                PublicProfileTopNavBar(
                    userName: viewModel.profile?.fullName ?? "Profile",
                    onBack: { dismiss() }
                )
                Spacer()
            }
            
            // Bottom Nav Bar
            VStack {
                Spacer()
                BottomNavBar(
                    selectedTab: .constant(.home),
                    currentUser: appEnvironment.currentUser
                )
            }
        }
        .task {
            await viewModel.load(userId: userId, appEnvironment: appEnvironment)
        }
    }
}

@MainActor
class PublicProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var profileUser: User?
    @Published var followers: Int = 0
    @Published var following: Int = 0
    @Published var isFollowing: Bool = false
    @Published var isLoading: Bool = false
    
    var profilePicture: ImageSource {
        if let avatarUrl = profile?.avatarUrl, let url = URL(string: avatarUrl) {
            return .url(url)
        }
        return .image("profilepic")
    }
    
    var creationDate: String? {
        guard let createdAt = profileUser?.createdAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: createdAt)
    }
    
    func load(userId: String, appEnvironment: AppEnvironment) async {
        isLoading = true
        
        do {
            // Load profile
            profile = try await appEnvironment.profileService.fetchProfile(userId: userId)
            
            // Load user
            profileUser = try? await appEnvironment.authService.getCurrentUser()
            
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
        HStack {
            Button(action: onBack) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
            
            Text(userName)
                .font(.system(size: 20, weight: .bold))
            
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}
