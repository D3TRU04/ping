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
    @State private var showingEditProfile: Bool = false
    
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
                            showingEditProfile = true
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
                        isOwnProfile: true,
                        likedPlaces: viewModel.likedPlaces,
                        savedPlaces: viewModel.savedPlaces,
                        isLoading: viewModel.isLoadingPlaces
                    )
                    
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
        .sheet(isPresented: $showingEditProfile) {
            NavigationView {
                EditAccountView()
                    .environmentObject(appEnvironment)
            }
        }
        .task {
            await viewModel.load(userId: appEnvironment.currentUser?.id ?? "", appEnvironment: appEnvironment)
            await viewModel.loadAllPlaces(appEnvironment: appEnvironment)
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
    let likedPlaces: [PlaceVisit]
    let savedPlaces: [CollectionsService.SavedPlace]
    let isLoading: Bool

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else {
                switch activeTab {
                case .saved:
                    if savedPlaces.isEmpty {
                        EmptyStateView(
                            icon: "bookmark.fill",
                            title: "No saved places",
                            subtitle: "Places you want to visit will appear here."
                        )
                    } else {
                        PlacesList(places: savedPlaces.compactMap { $0.place }.map { placeDetails in
                            PlaceListItem(
                                id: placeDetails.id,
                                name: placeDetails.name,
                                category: placeDetails.category,
                                location: placeDetails.location,
                                imageUrl: placeDetails.imageUrl,
                                rating: placeDetails.rating
                            )
                        })
                    }
                case .been:
                    if likedPlaces.isEmpty {
                        EmptyStateView(
                            icon: "mappin.circle.fill",
                            title: "No places visited",
                            subtitle: "Mark places you've visited to build your map."
                        )
                    } else {
                        PlacesList(places: likedPlaces.compactMap { $0.place }.map { place in
                            PlaceListItem(
                                id: place.id,
                                name: place.name,
                                category: place.category ?? "Unknown",
                                location: place.address ?? "",
                                imageUrl: place.imageUrl,
                                rating: place.rating
                            )
                        })
                    }
                case .likes:
                    // Likes tab shows the same as Been for now
                    if likedPlaces.isEmpty {
                        EmptyStateView(
                            icon: "heart.fill",
                            title: "No liked places",
                            subtitle: "Like places to share them with friends."
                        )
                    } else {
                        PlacesList(places: likedPlaces.compactMap { $0.place }.map { place in
                            PlaceListItem(
                                id: place.id,
                                name: place.name,
                                category: place.category ?? "Unknown",
                                location: place.address ?? "",
                                imageUrl: place.imageUrl,
                                rating: place.rating
                            )
                        })
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
}

// MARK: - Place List Item Model
struct PlaceListItem: Identifiable {
    let id: String
    let name: String
    let category: String
    let location: String
    let imageUrl: String?
    let rating: Double?
}

// MARK: - Places List Component
struct PlacesList: View {
    let places: [PlaceListItem]

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(places) { place in
                ProfilePlaceCard(place: place)
            }
        }
    }
}

// MARK: - Profile Place Card
struct ProfilePlaceCard: View {
    let place: PlaceListItem

    var body: some View {
        HStack(spacing: 14) {
            // Place Image with subtle glow
            ZStack {
                // Subtle glow behind image
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppColors.mint.opacity(0.1))
                    .frame(width: 76, height: 76)
                    .blur(radius: 4)
                
                AsyncImage(url: URL(string: place.imageUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "F3F4F6"))
                            
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(AppColors.mint.opacity(0.5))
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "F3F4F6"))
                            
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(AppColors.mint.opacity(0.5))
                        }
                    @unknown default:
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "F3F4F6"))
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // Place Info
            VStack(alignment: .leading, spacing: 6) {
                Text(place.name)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Category pill
                Text(place.category.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.mint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.mint.opacity(0.1))
                    .clipShape(Capsule())

                // Location and Rating row
                HStack(spacing: 12) {
                    if !place.location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.system(size: 10, weight: .medium))
                            Text(place.location)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    }
                    
                    if let rating = place.rating {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "FBBF24"))
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }

            Spacer()

            // Arrow button
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.textTertiary)
                .frame(width: 28, height: 28)
                .background(Color(hex: "F3F4F6"))
                .clipShape(Circle())
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 14) {
            // Icon with gradient glow
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7").opacity(0.15), Color(hex: "1FC9C3").opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .blur(radius: 10)
                
                // Icon circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .light))
                    .foregroundColor(AppColors.mint.opacity(0.6))
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .frame(maxWidth: 240)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 100) // Extra padding to stay above bottom navbar
    }
}
