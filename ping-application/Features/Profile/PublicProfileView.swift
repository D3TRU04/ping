//
//  PublicProfileView.swift
//  PingNative
//
//  Public profile view for viewing other users' profiles
//
//  Related files:
//  - Components/SharedPlacesView.swift - Shared places view and ViewModel
//  - Components/ProfilePlaceComponents.swift - Place cards and list components
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

    private let backgroundColor = Color(hex: "FAFAFA")

    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor.ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else {
                profileContent
            }

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

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(AppColors.mint)
            Spacer()
        }
    }

    private var profileContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 30)

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
                    theyFollowMe: viewModel.theyFollowMe,
                    onFollowChange: { isFollowing in
                        viewModel.isFollowing = isFollowing
                        viewModel.isMutualFollow = isFollowing && viewModel.theyFollowMe
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
                                onPressFollowing: {},
                                onPressFollowers: {}
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

                if viewModel.isMutualFollow {
                    mutualFollowButtons
                }

                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)

                ProfileTabContent(
                    activeTab: activeTab,
                    currentUser: viewModel.profileUser,
                    isOwnProfile: false,
                    likedPlaces: [],
                    savedPlaces: [],
                    isLoading: false
                )

                Spacer().frame(height: 40)
            }
        }
    }

    private var mutualFollowButtons: some View {
        VStack(spacing: 12) {
            Button(action: { showingSharedWantToTry = true }) {
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

            Button(action: { showingSharedBeen = true }) {
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
}

// MARK: - Public Profile ViewModel
@MainActor
class PublicProfileViewModel: ObservableObject {
    @Published var profile: User?
    @Published var followers: Int = 0
    @Published var following: Int = 0
    @Published var isFollowing: Bool = false
    @Published var theyFollowMe: Bool = false
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

    var profileUser: User? { profile }

    func load(userId: String, appEnvironment: AppEnvironment) async {
        isLoading = true

        do {
            profile = try await appEnvironment.profileService.fetchProfile(userId: userId)
            await updateFollowCounts(appEnvironment: appEnvironment)

            let savedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(userId: userId, limit: 100)
            let visitedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(userId: userId, limit: 100)
            wantToTryCount = savedPlaces.count
            beenCount = visitedPlaces.count

            if let currentUserId = appEnvironment.currentUser?.id {
                isFollowing = try await appEnvironment.profileService.isFollowing(
                    followerId: currentUserId,
                    followingId: userId
                )
                theyFollowMe = try await appEnvironment.profileService.isFollowing(
                    followerId: userId,
                    followingId: currentUserId
                )
                isMutualFollow = isFollowing && theyFollowMe

                if isMutualFollow {
                    let mySavedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(userId: currentUserId, limit: 100)
                    let myVisitedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(userId: currentUserId, limit: 100)

                    let mySavedIds = Set(mySavedPlaces.map { $0.placeId })
                    let myVisitedIds = Set(myVisitedPlaces.map { $0.placeId })

                    sharedWantToTryCount = savedPlaces.filter { mySavedIds.contains($0.placeId) }.count
                    sharedBeenCount = visitedPlaces.filter { myVisitedIds.contains($0.placeId) }.count
                }
            }
        } catch {}

        isLoading = false
    }

    func updateFollowCounts(appEnvironment: AppEnvironment) async {
        guard let userId = profile?.id else { return }

        do {
            let followersList = try await appEnvironment.profileService.fetchFollowers(userId: userId)
            let followingList = try await appEnvironment.profileService.fetchFollowing(userId: userId)
            followers = followersList.count
            following = followingList.count
        } catch {}
    }
}

// MARK: - Public Profile Top Nav Bar
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
