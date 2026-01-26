//
//  ProfileView.swift
//  PingNative
//
//  User's own profile view
//
//  Related files:
//  - Components/ProfilePlaceComponents.swift - Place cards and list components
//  - ProfileComponents.swift - ProfileCard, ProfileStats, ProfileTabs
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

    private let backgroundColor = Color(hex: "FAFAFA")

    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

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
                                ProfileStats(
                                    following: viewModel.following,
                                    followers: viewModel.followers,
                                    onPressFollowing: {},
                                    onPressFollowers: {}
                                )

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

                        Spacer().frame(height: 120)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)

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
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Profile Tab Content
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
                        ProfileEmptyStateView(
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
                        ProfileEmptyStateView(
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
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
}
