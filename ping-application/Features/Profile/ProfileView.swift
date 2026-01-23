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
    @State private var activeTab: ProfileTabType = .wantToTry
    @State private var scrollOffset: CGFloat = 0
    @State private var showingSettings: Bool = false
    @State private var showingEditProfile: Bool = false
    
    // Soft white background color
    private let backgroundColor = Color(hex: "FAFAFA")
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed Header Section
                VStack(spacing: 0) {
                    // Fixed Nav Bar Space
                    Spacer().frame(height: 60)
                    
                    // Profile Card (Fixed)
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
                                // Stats
                                ProfileStats(
                                    following: viewModel.following,
                                    followers: viewModel.followers,
                                    onPressFollowing: {},
                                    onPressFollowers: {}
                                )

                                // Floating Tabs with counts
                                ProfileTabs(
                                    activeTab: $activeTab,
                                    wantToTryCount: viewModel.savedPlaces.count,
                                    beenCount: viewModel.likedPlaces.count
                                )
                            }
                        )
                    }
                }
                .background(backgroundColor)
                
                // Scrollable Content Section
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ProfileTabContent(
                            activeTab: activeTab,
                            currentUser: viewModel.currentUser,
                            isOwnProfile: true,
                            likedPlaces: viewModel.likedPlaces,
                            savedPlaces: viewModel.savedPlaces,
                            isLoading: viewModel.isLoadingPlaces
                        )
                        
                        // Bottom Spacer for Nav Bar padding
                        Spacer().frame(height: 120)
                    }
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
    
    // Animation Helpers (Removed as they are no longer used for fixed header)
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
                case .wantToTry:
                    if savedPlaces.isEmpty {
                        EmptyStateView(
                            icon: "bookmark.fill",
                            title: "No places to try",
                            subtitle: "Places you want to try will appear here."
                        )
                    } else {
                        PlacesList(places: savedPlaces.compactMap { $0.place }.map { placeDetails in
                            PlaceListItem(
                                id: placeDetails.id,
                                name: placeDetails.name,
                                category: placeDetails.category,
                                subcategory: placeDetails.subcategory,
                                location: placeDetails.location,
                                imageUrl: placeDetails.imageUrl,
                                rating: placeDetails.rating,
                                hours: nil,
                                price: nil
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
                                subcategory: place.subcategory,
                                location: place.address ?? "",
                                imageUrl: place.imageUrl,
                                rating: place.rating,
                                hours: place.hours,
                                price: place.priceRange
                            )
                        })
                    }
//                case .likes:
//                    // Likes tab shows the same as Been for now
//                    if likedPlaces.isEmpty {
//                        EmptyStateView(
//                            icon: "heart.fill",
//                            title: "No liked places",
//                            subtitle: "Like places to share them with friends."
//                        )
//                    } else {
//                        PlacesList(places: likedPlaces.compactMap { $0.place }.map { place in
//                            PlaceListItem(
//                                id: place.id,
//                                name: place.name,
//                                category: place.category ?? "Unknown",
//                                location: place.address ?? "",
//                                imageUrl: place.imageUrl,
//                                rating: place.rating,
//                                hours: place.hours,
//                                price: place.priceRange
//                            )
//                        })
//                    }
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
    let subcategory: String?
    let location: String
    let imageUrl: String?
    let rating: Double?
    let hours: [String]?
    let price: Int?
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

    private var formattedHours: String? {
        guard let hours = place.hours, !hours.isEmpty else { return nil }

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let todayName = days[weekday - 1]

        if let todayHour = hours.first(where: { $0.hasPrefix(todayName) }) {
            if let colonIndex = todayHour.firstIndex(of: ":") {
                return String(todayHour[todayHour.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
            }
            return todayHour
        }
        return nil
    }

    private var priceString: String? {
        guard let price = place.price, price > 0 else { return nil }
        return String(repeating: "$", count: price)
    }

    private func getSubcategoryGradient(_ name: String) -> [Color] {
        let lowerName = name.lowercased()
        
        if lowerName.contains("coffee") || lowerName.contains("cafe") || lowerName.contains("bakery") || lowerName.contains("bread") || lowerName.contains("waffle") || lowerName.contains("crepe") || lowerName.contains("breakfast") {
            return [Color(hex: "E2D1C3"), Color(hex: "CDB4A6")]
        } else if lowerName.contains("salad") || lowerName.contains("vegan") || lowerName.contains("vegetarian") || lowerName.contains("park") || lowerName.contains("nature") || lowerName.contains("hike") {
            return [Color(hex: "A8E6CF"), Color(hex: "88D8B0")]
        } else if lowerName.contains("ocean") || lowerName.contains("sea") || lowerName.contains("water") || lowerName.contains("pool") || lowerName.contains("swim") {
            return [Color(hex: "A1C4FD"), Color(hex: "8AB6F9")]
        } else if lowerName.contains("pizza") || lowerName.contains("burger") || lowerName.contains("fast food") || lowerName.contains("taco") {
            return [Color(hex: "FAD390"), Color(hex: "F6B93B")]
        } else if lowerName.contains("dessert") || lowerName.contains("ice cream") || lowerName.contains("cake") || lowerName.contains("sweet") || lowerName.contains("donut") {
            return [Color(hex: "F8A5C2"), Color(hex: "F78FB3")]
        } else if lowerName.contains("bar") || lowerName.contains("wine") || lowerName.contains("beer") || lowerName.contains("cocktail") || lowerName.contains("night") {
            return [Color(hex: "D6A2E8"), Color(hex: "B39CD0")]
        } else if lowerName.contains("sushi") || lowerName.contains("japanese") || lowerName.contains("seafood") {
            return [Color(hex: "FFBE76"), Color(hex: "FFA502")]
        }

        let sum = name.utf8.reduce(0) { $0 + Int($1) }
        let index = sum % 8

        switch index {
        case 0: return [Color(hex: "81ECEC"), Color(hex: "00CEC9")]
        case 1: return [Color(hex: "74B9FF"), Color(hex: "0984E3")]
        case 2: return [Color(hex: "A29BFE"), Color(hex: "6C5CE7")]
        case 3: return [Color(hex: "FAB1A0"), Color(hex: "E17055")]
        case 4: return [Color(hex: "B2BEC3"), Color(hex: "636E72")]
        case 5: return [Color(hex: "FD79A8"), Color(hex: "E84393")]
        case 6: return [Color(hex: "E0C3FC"), Color(hex: "8EC5FC")]
        case 7: return [Color(hex: "55EFC4"), Color(hex: "00B894")]
        default: return [Color(hex: "81ECEC"), Color(hex: "00CEC9")]
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            /* // Commented out images for now
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
            */

            // Place Info
            VStack(alignment: .leading, spacing: 6) {
                Text(place.name)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Rating & Price & Subcategory row
                HStack(spacing: 12) {
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

                    if let price = priceString {
                        Text(price)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    // Category & Subcategory
                    Text(place.category.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                colors: getSubcategoryGradient(place.category),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())

                    if let subcategory = place.subcategory, !subcategory.isEmpty {
                        Text(subcategory.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                LinearGradient(
                                    colors: getSubcategoryGradient(subcategory),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                    }
                }

                // Location text
                if !place.location.isEmpty {
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10, weight: .medium))
                            .padding(.top, 2)
                        Text(place.location)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                
                // Hours text
                if let hours = formattedHours {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10, weight: .medium))
                        Text(hours)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                    }
                    .foregroundColor(AppColors.textTertiary)
                }
            }

            Spacer()

            // Arrow button
            VStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
                    .frame(width: 28, height: 28)
                    .background(Color(hex: "F3F4F6"))
                    .clipShape(Circle())
                Spacer()
            }
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
