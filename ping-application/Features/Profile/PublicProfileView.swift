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
    @State private var activeTab: ProfileTabType = .wantToTry
    @State private var showingSharedWantToTry: Bool = false
    @State private var showingSharedBeen: Bool = false
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

                                    ProfileTabs(
                                        activeTab: $activeTab,
                                        wantToTryCount: viewModel.wantToTryCount,
                                        beenCount: viewModel.beenCount
                                    )
                                }
                            )
                        }
                        .padding(.top, 8)

                        // Mutual Follow Shared Places Buttons
                        if viewModel.isMutualFollow {
                            VStack(spacing: 12) {
                                Button(action: {
                                    showingSharedWantToTry = true
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "bookmark.fill")
                                            .font(.system(size: 16))
                                        Text("Shared Want to Try")
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                        Text("\(viewModel.sharedWantToTryCount)")
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(AppColors.mint.opacity(0.2))
                                            .clipShape(Capsule())
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(AppColors.mint)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(AppColors.mint.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

                                Button(action: {
                                    showingSharedBeen = true
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.system(size: 16))
                                        Text("Shared Been")
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                        Text("\(viewModel.sharedBeenCount)")
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(AppColors.mint.opacity(0.2))
                                            .clipShape(Capsule())
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(AppColors.mint)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(AppColors.mint.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        }

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
        .sheet(isPresented: $showingSharedWantToTry) {
            SharedPlacesView(
                title: "Shared Want to Try",
                icon: "bookmark.fill",
                currentUserId: appEnvironment.currentUser?.id ?? "",
                otherUserId: userId,
                placeType: .wantToTry
            )
            .environmentObject(appEnvironment)
        }
        .sheet(isPresented: $showingSharedBeen) {
            SharedPlacesView(
                title: "Shared Been",
                icon: "mappin.circle.fill",
                currentUserId: appEnvironment.currentUser?.id ?? "",
                otherUserId: userId,
                placeType: .been
            )
            .environmentObject(appEnvironment)
        }
    }
}

@MainActor
class PublicProfileViewModel: ObservableObject {
    @Published var profile: User?
    @Published var followers: Int = 0
    @Published var following: Int = 0
    @Published var isFollowing: Bool = false
    @Published var isMutualFollow: Bool = false
    @Published var isLoading: Bool = false
    @Published var wantToTryCount: Int = 0
    @Published var beenCount: Int = 0
    @Published var sharedWantToTryCount: Int = 0
    @Published var sharedBeenCount: Int = 0

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

            // Load profile user's places counts
            let savedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(userId: userId, limit: 100)
            let visitedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(userId: userId, limit: 100)
            wantToTryCount = savedPlaces.count
            beenCount = visitedPlaces.count

            // Check if current user is following and if it's mutual
            if let currentUserId = appEnvironment.currentUser?.id {
                isFollowing = try await appEnvironment.profileService.isFollowing(
                    followerId: currentUserId,
                    followingId: userId
                )

                // Check if profile user follows current user back (mutual follow)
                let theyFollowMe = try await appEnvironment.profileService.isFollowing(
                    followerId: userId,
                    followingId: currentUserId
                )

                isMutualFollow = isFollowing && theyFollowMe

                // If mutual follow, calculate shared places counts
                if isMutualFollow {
                    let mySavedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(userId: currentUserId, limit: 100)
                    let myVisitedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(userId: currentUserId, limit: 100)

                    let mySavedIds = Set(mySavedPlaces.map { $0.placeId })
                    let myVisitedIds = Set(myVisitedPlaces.map { $0.placeId })

                    sharedWantToTryCount = savedPlaces.filter { mySavedIds.contains($0.placeId) }.count
                    sharedBeenCount = visitedPlaces.filter { myVisitedIds.contains($0.placeId) }.count
                }
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

// MARK: - Shared Places View
enum SharedPlaceType {
    case wantToTry
    case been
}

struct SharedPlacesView: View {
    let title: String
    let icon: String
    let currentUserId: String
    let otherUserId: String
    let placeType: SharedPlaceType

    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = SharedPlacesViewModel()
    @Environment(\.dismiss) var dismiss

    private let backgroundColor = Color(hex: "FAFAFA")

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()

                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(AppColors.mint)
                        Spacer()
                    }
                } else if viewModel.sharedPlaces.isEmpty {
                    VStack(spacing: 14) {
                        ZStack {
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

                            Circle()
                                .fill(Color.white)
                                .frame(width: 72, height: 72)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)

                            Image(systemName: icon)
                                .font(.system(size: 26, weight: .light))
                                .foregroundColor(AppColors.mint.opacity(0.6))
                        }

                        VStack(spacing: 4) {
                            Text("No shared places yet")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)

                            Text(placeType == .wantToTry
                                 ? "Places you both want to try will appear here."
                                 : "Places you've both been to will appear here.")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)
                                .frame(maxWidth: 240)
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.sharedPlaces) { place in
                                ProfilePlaceCard(place: place)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .task {
            await viewModel.loadSharedPlaces(
                currentUserId: currentUserId,
                otherUserId: otherUserId,
                placeType: placeType,
                appEnvironment: appEnvironment
            )
        }
    }
}

@MainActor
class SharedPlacesViewModel: ObservableObject {
    @Published var sharedPlaces: [PlaceListItem] = []
    @Published var isLoading: Bool = false

    func loadSharedPlaces(
        currentUserId: String,
        otherUserId: String,
        placeType: SharedPlaceType,
        appEnvironment: AppEnvironment
    ) async {
        isLoading = true

        do {
            switch placeType {
            case .wantToTry:
                // Get saved places for both users
                let mySavedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(
                    userId: currentUserId,
                    limit: 100
                )
                let theirSavedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(
                    userId: otherUserId,
                    limit: 100
                )

                // Find intersection by placeId
                let myPlaceIds = Set(mySavedPlaces.map { $0.placeId })
                let shared = theirSavedPlaces.filter { myPlaceIds.contains($0.placeId) }

                sharedPlaces = shared.compactMap { savedPlace -> PlaceListItem? in
                    guard let place = savedPlace.place else { return nil }
                    return PlaceListItem(
                        id: place.id,
                        name: place.name,
                        category: place.category,
                        subcategory: place.subcategory,
                        location: place.location,
                        imageUrl: place.imageUrl,
                        rating: place.rating,
                        hours: nil,
                        price: nil
                    )
                }

            case .been:
                // Get visited places for both users
                let myVisitedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(
                    userId: currentUserId,
                    limit: 100
                )
                let theirVisitedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(
                    userId: otherUserId,
                    limit: 100
                )

                // Find intersection by placeId
                let myPlaceIds = Set(myVisitedPlaces.map { $0.placeId })
                let shared = theirVisitedPlaces.filter { myPlaceIds.contains($0.placeId) }

                sharedPlaces = shared.compactMap { visit -> PlaceListItem? in
                    guard let place = visit.place else { return nil }
                    return PlaceListItem(
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
                }
            }
        } catch {
            print("Error loading shared places: \(error)")
        }

        isLoading = false
    }
}
