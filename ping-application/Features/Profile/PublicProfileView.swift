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
        .onAppear {
            // Refresh data when returning to the view
            Task {
                await viewModel.refresh(userId: userId, appEnvironment: appEnvironment)
            }
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
                        viewModel.handleFollowChange(isNowFollowing: isFollowing, appEnvironment: appEnvironment)
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
                    PublicProfileMutualButtons(
                        sharedWantToTryCount: viewModel.sharedWantToTryCount,
                        sharedBeenCount: viewModel.sharedBeenCount,
                        onShowSharedWantToTry: { showingSharedWantToTry = true },
                        onShowSharedBeen: { showingSharedBeen = true }
                    )
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
                    likedPlaces: viewModel.visitedPlaces,
                    savedPlaces: viewModel.savedPlaces,
                    isLoading: viewModel.isLoadingPlaces
                )

                Spacer().frame(height: 40)
            }
        }
    }
}
