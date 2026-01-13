//
//  ProfileView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/main/page.tsx
//  Updated to match RN structure with ProfileCard, ProfileStats, ProfileTabs
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    @State private var activeTab: ProfileTabType = .saved
    
    var body: some View {
        ZStack(alignment: .top) {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Card
                    ProfileCard(
                        profilePicture: viewModel.profilePicture,
                        fullName: viewModel.user?.fullName ?? "User",
                        pronouns: viewModel.user?.pronouns,
                        username: viewModel.user?.username ?? "",
                        creationDate: viewModel.creationDate,
                        bio: viewModel.user?.bio,
                        location: viewModel.user?.location,
                        links: viewModel.user?.links?.joined(separator: ", "),
                        currentUserId: appEnvironment.currentUser?.id,
                        profileUserId: appEnvironment.currentUser?.id,
                        showFollowButton: false
                    ) {
                        AnyView(
                            VStack(spacing: 0) {
                                // Temporary Sign Out Button
                                Button(action: {
                                    Task {
                                        await appEnvironment.logout()
                                    }
                                }) {
                                    Text("Sign Out (Temp)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 8)
                                        .background(AppColors.primaryAction)
                                        .clipShape(Capsule())
                                }
                                .padding(.bottom, 16)

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
                    
                    // Tab Content
                    ProfileTabContent(
                        activeTab: activeTab,
                        currentUser: viewModel.currentUser,
                        isOwnProfile: true
                    )
                    .frame(minHeight: 200)
                }
                .padding(.top, 60) // Add padding for TopNavBar
                .padding(.bottom, 100) // Add padding for Bottom Tab Bar
            }
            
            // Top Nav Bar
            ProfileTopNavBar(
                currentUser: appEnvironment.currentUser,
                onBack: { dismiss() },
                onSettingsTap: {
                    // Navigate to Settings
                },
                onEditTap: {
                    // Navigate to Edit Account
                }
            )
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.load(userId: appEnvironment.currentUser?.id ?? "", appEnvironment: appEnvironment)
        }
    }
}

struct ProfileTopNavBar: View {
    let currentUser: User?
    let onBack: () -> Void
    let onSettingsTap: () -> Void
    let onEditTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
            
            Text("Profile")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: onEditTap) {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textPrimary)
                }

                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(AppColors.background)
    }
}

struct ProfileTabContent: View {
    let activeTab: ProfileTabType
    let currentUser: User?
    let isOwnProfile: Bool
    
    var body: some View {
        VStack {
            switch activeTab {
            case .saved:
                Text("Saved places will appear here")
                    .foregroundColor(AppColors.textSecondary)
            case .been:
                Text("Places you've been will appear here")
                    .foregroundColor(AppColors.textSecondary)
            case .likes:
                Text("Liked places will appear here")
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
}
