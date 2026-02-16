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

// MARK: - View Mode

private enum ProfileViewMode {
    case profile
    case followList
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var followListVM = FollowListViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    @State private var activeTab: ProfileTabType = .wantToTry
    @State private var showingSettings: Bool = false
    @State private var showingEditProfile: Bool = false
    @State private var viewMode: ProfileViewMode = .profile
    @State private var followListTab: FollowListTab = .followers

    var body: some View {
        ZStack(alignment: .top) {
            LiquidGlassBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 70)

                switch viewMode {
                case .profile:
                    profileContent
                case .followList:
                    FollowListInlineView(
                        viewModel: followListVM,
                        activeTab: $followListTab,
                        currentUserId: appEnvironment.currentUser?.id ?? "",
                        appEnvironment: appEnvironment
                    )
                }
            }

            ProfileNavBar(
                username: viewModel.user?.username ?? "",
                onSettingsTap: {
                    showingSettings = true
                },
                isFollowListMode: viewMode == .followList,
                onBackTap: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        viewMode = .profile
                    }
                    followListVM.searchQuery = ""
                    Task {
                        await viewModel.refreshFollowCounts(appEnvironment: appEnvironment)
                    }
                }
            )
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingSettings, onDismiss: {
            viewModel.syncFromCurrentUser(appEnvironment: appEnvironment)
        }) {
            SettingsView()
                .environmentObject(appEnvironment)
                .presentationBackground(.ultraThinMaterial)
        }
        .sheet(isPresented: $showingEditProfile, onDismiss: {
            viewModel.syncFromCurrentUser(appEnvironment: appEnvironment)
        }) {
            NavigationStack {
                AccountInfoView()
                    .environmentObject(appEnvironment)
            }
            .presentationBackground(.ultraThinMaterial)
        }
        .task {
            await viewModel.load(userId: appEnvironment.currentUser?.id ?? "", appEnvironment: appEnvironment)
            await viewModel.loadAllPlaces(appEnvironment: appEnvironment)
        }
        .onChange(of: appEnvironment.currentUser?.id) { _ in
            // Reload when currentUser changes (e.g., after onboarding)
            Task {
                await viewModel.load(userId: appEnvironment.currentUser?.id ?? "", appEnvironment: appEnvironment)
                await viewModel.loadAllPlaces(appEnvironment: appEnvironment)
            }
        }
    }

    // MARK: - Profile Content

    private var profileContent: some View {
        Group {
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
                following: viewModel.following,
                followers: viewModel.followers,
                onPressFollowing: {
                    followListTab = .following
                    Task {
                        await followListVM.load(
                            userId: appEnvironment.currentUser?.id ?? "",
                            appEnvironment: appEnvironment
                        )
                    }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        viewMode = .followList
                    }
                },
                onPressFollowers: {
                    followListTab = .followers
                    Task {
                        await followListVM.load(
                            userId: appEnvironment.currentUser?.id ?? "",
                            appEnvironment: appEnvironment
                        )
                    }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        viewMode = .followList
                    }
                },
                onEditProfile: {
                    showingEditProfile = true
                }
            ) {
                AnyView(
                    ProfileTabs(
                        activeTab: $activeTab,
                        wantToTryCount: viewModel.savedPlaces.count,
                        beenCount: viewModel.likedPlaces.count
                    )
                    .padding(.top, 8)
                )
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 12)

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
                case .saved:
                    ProfileEmptyStateView(
                        icon: "square.stack.3d.up.fill",
                        title: "Collections",
                        subtitle: "Your saved collections will appear here."
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
}
