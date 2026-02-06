//
//  RootView.swift
//  PingNative
//
//  Source: ping/apps/App.tsx navigation structure
//  Updated to match RN app navigation flow
//

import SwiftUI

enum NavigationDestination: Hashable {
    case signIn
    case signUp
    case onboarding
}

struct RootView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var showLoading = true
    @State private var selectedTab: BottomNavBar.MainTab = .home
    
    var body: some View {
        ZStack {
            // Main content - always rendered underneath
            if appEnvironment.isAuthenticated {
                if appEnvironment.needsOnboarding {
                    OnboardingView()
                } else {
                    MainTabView(selectedTab: $selectedTab)
                }
            } else {
                NavigationStack {
                    StartupView()
                        .navigationDestination(for: NavigationDestination.self) { destination in
                            switch destination {
                            case .signIn:
                                LoginView(showingLogin: .constant(true))
                            case .signUp:
                                SignupView(showingLogin: .constant(false))
                            case .onboarding:
                                OnboardingView()
                            }
                        }
                }
            }

            // Loading overlay - covers everything until dismissed
            if showLoading {
                LoadingView {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLoading = false
                    }
                }
                .zIndex(10)
                .transition(.opacity)
            }
        }
    }
}

// Preference key for satellite mode state
struct SatelliteModePreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

struct MainTabView: View {
    @Binding var selectedTab: BottomNavBar.MainTab
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var discoverSheetExpansion: CGFloat = 0
    @State private var discoverSatelliteMode: Bool = false
    @State private var homeNavigationPath = NavigationPath()
    @State private var discoverNavigationPath = NavigationPath()
    
    @ViewBuilder
    var contentView: some View {
        switch selectedTab {
        case .home:
            HomeView(path: $homeNavigationPath)
                .transition(.opacity)
        case .discover:
            DiscoverView(path: $discoverNavigationPath)
                .onPreferenceChange(SheetExpansionPreferenceKey.self) { value in
                    discoverSheetExpansion = value
                }
                .onPreferenceChange(SatelliteModePreferenceKey.self) { value in
                    discoverSatelliteMode = value
                }
                .transition(.opacity)
        case .notifications:
            NotificationsView()
                .transition(.opacity)
        }
    }
    
    // Calculate nav bar visibility based on sheet expansion
    private var navBarOpacity: Double {
        if selectedTab == .discover {
            return 1.0 - Double(discoverSheetExpansion) * 0.9
        }
        return 1.0
    }
    
    private var navBarOffset: CGFloat {
        if selectedTab == .discover {
            return discoverSheetExpansion * 80
        }
        return 0
    }
    
    // Only show satellite mode styling when on discover tab
    private var isSatelliteMode: Bool {
        selectedTab == .discover && discoverSatelliteMode
    }
    
    var body: some View {
        ZStack {
            // Content based on selected tab
            contentView
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
            
            // Bottom Nav Bar overlay - fades and slides when discover sheet expands
            VStack {
                Spacer()
                HStack(alignment: .center, spacing: 12) {
                    BottomNavBar(
                        selectedTab: $selectedTab,
                        currentUser: appEnvironment.currentUser,
                        isSatelliteMode: isSatelliteMode,
                        onReselect: { tab in
                            if tab == .home {
                                homeNavigationPath = NavigationPath()
                            } else if tab == .discover {
                                discoverNavigationPath = NavigationPath()
                            }
                        }
                    )

                    // Profile island (visible on all tabs)
                    ProfileButtonIsland(
                        currentUser: appEnvironment.currentUser,
                        onProfileTap: { homeNavigationPath.append("profile") }
                    )
                }
                .padding(.horizontal, 24)
                .background(
                    LinearGradient(
                        colors: [Color.white.opacity(0.0), Color.white.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .padding(.top, -30)
                    .ignoresSafeArea(.container, edges: .bottom)
                )
                .opacity(navBarOpacity)
                .offset(y: navBarOffset)
                .animation(.easeOut(duration: 0.25), value: discoverSheetExpansion)
            }
        }
    }
}
