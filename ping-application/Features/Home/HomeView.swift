//
//  HomeView.swift
//  PingNative
//
//  Clean home screen matching Profile screen style
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var groupsViewModel = GroupsViewModel()
    @StateObject private var forYouViewModel = ForYouViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var activeTab: SecondaryNavBarTab = .forYou
    @Binding var path: NavigationPath // Changed from @State to @Binding
    @State private var showPreferences = false
    @State private var showFilterSheet = false
    @State private var filters = PlaceFilters()
    @State private var forYouDataLoaded = false

    // Group state
    @State private var selectedGroup: GroupsService.Group?
    @State private var showGroupsSheet = false

    // Replay game callback (set by TodayPage)
    @State private var replayGameAction: (() -> Void)?

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // MARK: - Background Layer (ignores safe area)
                LiquidGlassBackground()

                // MARK: - Content Layer (full screen, scrolls behind nav bar)
                TabView(selection: $activeTab) {
                    TodayPage(
                        currentUser: appEnvironment.currentUser,
                        onUpdatePreferences: {
                            showPreferences = true
                        },
                        onReplayGameRequest: { callback in
                            replayGameAction = callback
                        }
                    )
                    .tag(SecondaryNavBarTab.today)

                    ForYouPage(
                        currentUser: appEnvironment.currentUser,
                        activeTab: activeTab,
                        viewModel: forYouViewModel,
                        onUpdatePreferences: {
                            showPreferences = true
                        },
                        filters: $filters,
                        showFilterSheet: $showFilterSheet
                    )
                    .tag(SecondaryNavBarTab.forYou)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: activeTab)
                .ignoresSafeArea(.container, edges: .bottom)

                // MARK: - Top Nav Bar (overlays content, cards scroll behind it)
                VStack(spacing: 0) {
                    HomeTopNavBar(
                        activeTab: $activeTab,
                        currentUser: appEnvironment.currentUser,
                        filtersActive: filters.isActive,
                        onFilterTap: { showFilterSheet = true },
                        groups: groupsViewModel.groups,
                        selectedGroup: $selectedGroup,
                        onManageGroups: { showGroupsSheet = true },
                        onReplayGame: replayGameAction
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                    .safeAreaPadding(.top, 12)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.6)
                            .ignoresSafeArea(.container, edges: .top)
                    )
                    .mask(
                        VStack(spacing: 0) {
                            Rectangle()
                            LinearGradient(
                                colors: [.black, .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 20)
                        }
                        .ignoresSafeArea(.container, edges: .top)
                    )

                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { route in
                switch route {
                case "profile":
                    ProfileView()
                case "notifications":
                    NotificationsView()
                default:
                    EmptyView()
                }
            }
            .sheet(isPresented: $showPreferences) {
                PreferencesView()
                    .environmentObject(appEnvironment)
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheet(
                    filters: $filters,
                    isPresented: $showFilterSheet,
                    onApply: {
                        // Filters are applied reactively via onChange in ForYouPage
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showGroupsSheet) {
                GroupsView()
                    .environmentObject(appEnvironment)
                    .onDisappear {
                        // Refresh groups when sheet closes
                        Task {
                            await groupsViewModel.loadGroups()
                        }
                    }
            }
            .onAppear {
                // Load groups on appear
                groupsViewModel.configure(
                    groupsService: appEnvironment.groupsService,
                    userId: appEnvironment.currentUser?.id
                )
                Task {
                    await groupsViewModel.loadGroups()
                }

                // Configure and load ForYou data using a detached-like approach
                // This won't be cancelled by view updates
                if !forYouDataLoaded, let userId = appEnvironment.currentUser?.id {
                    forYouViewModel.configure(
                        placesService: appEnvironment.placesService,
                        collectionsService: appEnvironment.collectionsService,
                        notificationsService: appEnvironment.notificationsService,
                        profileService: appEnvironment.profileService
                    )
                    let preferences = appEnvironment.currentUser?.categoryPreferences?.toPlacesQueryFormat(using: OnboardingData.categories)
                    let vm = forYouViewModel
                    let prefs = preferences
                    let f = filters
                    Task { @MainActor in
                        await vm.fetchData(
                            userId: userId,
                            categoryPreferences: prefs,
                            filters: f
                        )
                    }
                    forYouDataLoaded = true
                }
            }
        }
    }
}

enum SecondaryNavBarTab: String {
    case today = "today"
    case forYou = "forYou"
}
