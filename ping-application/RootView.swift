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
            if showLoading {
                LoadingView {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLoading = false
                    }
                }
                .zIndex(1)
                .transition(.opacity)
            } else if appEnvironment.isAuthenticated {
                // NEW: Check if user needs onboarding
                if appEnvironment.needsOnboarding {
                    OnboardingView()
                        .transition(.opacity)
                } else {
                    MainTabView(selectedTab: $selectedTab)
                        .transition(.opacity)
                }
            } else {
                // User not authenticated - show Clerk auth flow
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
                .transition(.opacity)
            }
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: BottomNavBar.MainTab
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var discoverSheetExpansion: CGFloat = 0
    
    @ViewBuilder
    var contentView: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .discover:
            DiscoverView()
                .onPreferenceChange(SheetExpansionPreferenceKey.self) { value in
                    discoverSheetExpansion = value
                }
        case .notifications:
            NotificationsView()
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
    
    var body: some View {
        ZStack {
            // Content based on selected tab
            contentView
            
            // Bottom Nav Bar overlay - fades and slides when discover sheet expands
            VStack {
                Spacer()
                BottomNavBar(selectedTab: $selectedTab, currentUser: appEnvironment.currentUser)
                    .opacity(navBarOpacity)
                    .offset(y: navBarOffset)
                    .animation(.easeOut(duration: 0.25), value: discoverSheetExpansion)
            }
        }
    }
}
