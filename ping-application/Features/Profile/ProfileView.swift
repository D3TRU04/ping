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
    @State private var scrollOffset: CGFloat = 0
    @State private var showingSettings: Bool = false
    
    // Soft white background color
    private let backgroundColor = Color(hex: "FAFAFA")
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor
                .ignoresSafeArea()
            
            // Scrollable Content
            ScrollView {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: proxy.frame(in: .named("scroll")).minY
                    )
                }
                .frame(height: 0)
                
                VStack(spacing: 0) {
                    // Spacer for fixed nav bar
                    Spacer().frame(height: 80)
                    
                    // Profile Card with Scroll Fade
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
                        showFollowButton: false,
                        isFollowing: .constant(false),
                        onEditProfile: {
                            // Navigate to Edit Profile
                        }
                    ) {
                        AnyView(
                            VStack(spacing: 12) {
                                // 3-Column Stats
                                ProfileStats(
                                    following: viewModel.following,
                                    followers: viewModel.followers,
                                    placesCount: 0, // Placeholder
                                    onPressFollowing: {},
                                    onPressFollowers: {}
                                )
                                
                                // Floating Tabs
                                ProfileTabs(activeTab: $activeTab)
                            }
                        )
                    }
                    .opacity(calculateOpacity(offset: scrollOffset))
                    .scaleEffect(calculateScale(offset: scrollOffset))
                    
                    // Tab Content
                    ProfileTabContent(
                        activeTab: activeTab,
                        currentUser: viewModel.currentUser,
                        isOwnProfile: true
                    )
                    .frame(minHeight: 300)
                    .padding(.top, 16)
                    
                    // Bottom Spacer
                    Spacer().frame(height: 40)
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                withAnimation(.linear(duration: 0.1)) {
                    scrollOffset = value
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Fixed Top Nav Bar
            ProfileNavBar(
                onSettingsTap: {
                    showingSettings = true
                }
            )
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(appEnvironment)
        }
        .task {
            await viewModel.load(userId: appEnvironment.currentUser?.id ?? "", appEnvironment: appEnvironment)
        }
    }
    
    // Animation Helpers
    private func calculateOpacity(offset: CGFloat) -> Double {
        // Fade out as user scrolls down (negative offset)
        // Start fading at -50, fully faded at -300
        let fadeStart: CGFloat = -50
        let fadeEnd: CGFloat = -300
        
        if offset > fadeStart {
            return 1.0
        } else if offset < fadeEnd {
            return 0.0
        } else {
            return 1.0 - (offset - fadeStart) / (fadeEnd - fadeStart)
        }
    }
    
    private func calculateScale(offset: CGFloat) -> CGFloat {
        // Subtle scale down
        let scaleStart: CGFloat = -50
        let scaleEnd: CGFloat = -400
        
        if offset > scaleStart {
            return 1.0
        } else if offset < scaleEnd {
            return 0.9
        } else {
            return 1.0 - (0.1 * (offset - scaleStart) / (scaleEnd - scaleStart))
        }
    }
}

// Preference Key for Scroll Tracking
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
                EmptyStateView(
                    icon: "bookmark.fill",
                    title: "No saved places",
                    subtitle: "Places you want to visit will appear here."
                )
            case .been:
                EmptyStateView(
                    icon: "mappin.circle.fill",
                    title: "No places visited",
                    subtitle: "Mark places you've visited to build your map."
                )
            case .likes:
                EmptyStateView(
                    icon: "heart.fill",
                    title: "No liked places",
                    subtitle: "Like places to share them with friends."
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "F3F4F6"))
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: "B2BEC3"))
            }
            .padding(.bottom, 8)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 260)
            }
        }
        .padding(.vertical, 60)
    }
}
