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
        if showLoading {
            LoadingView()
                .onAppear {
                    // Show loading for at least 2 seconds (matching RN behavior)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showLoading = false
                    }
                }
        } else if appEnvironment.isAuthenticated {
            MainTabView(selectedTab: $selectedTab)
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
    }
}

struct MainTabView: View {
    @Binding var selectedTab: BottomNavBar.MainTab
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    @ViewBuilder
    var contentView: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .discover:
            DiscoverView()
        case .notifications:
            NotificationsView()
        case .chats:
            ChatsView()
        }
    }
    
    var body: some View {
        ZStack {
            // Content based on selected tab
            contentView
            
            // Bottom Nav Bar overlay
            VStack {
                Spacer()
                BottomNavBar(selectedTab: $selectedTab, currentUser: appEnvironment.currentUser)
            }
        }
    }
}
