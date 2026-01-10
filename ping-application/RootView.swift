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
                MainTabView(selectedTab: $selectedTab)
                    .transition(.opacity)
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
                .transition(.opacity)
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
