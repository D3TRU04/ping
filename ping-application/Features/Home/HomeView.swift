//
//  HomeView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/page.tsx
//  Updated to match RN structure with secondary tabs (ForYou, Today, Groups)
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var activeTab: SecondaryNavBarTab = .forYou
    @State private var selectedGroup: Group? = nil
    @State private var showGroupFeed: Bool = false
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(hex: "FAF6F2")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Nav Bar
                    HomeTopNavBar(
                        currentUser: appEnvironment.currentUser,
                        onProfileTap: { path.append("profile") }
                    )
                    
                    // Secondary Nav Bar
                    SecondaryNavBar(
                        activeTab: $activeTab,
                        currentUser: appEnvironment.currentUser,
                        onGroupSelect: { group in
                            selectedGroup = group
                            showGroupFeed = true
                            activeTab = .groups
                        }
                    )
                    
                                    // Content based on active tab
                                    if showGroupFeed, let group = selectedGroup {
                                        GroupFeedPage(
                                            group: group,
                                            currentUser: appEnvironment.currentUser,
                                            onBack: {
                                                showGroupFeed = false
                                                selectedGroup = nil
                                            }
                                        )
                                        .padding(.bottom, 90)
                                    } else {
                                        ZStack {
                                            // ForYou Page - always mounted, visibility controlled
                                            if activeTab == .forYou || activeTab == .groups {
                                                ForYouPage(
                                                    currentUser: appEnvironment.currentUser,
                                                    activeTab: activeTab
                                                )
                                                .opacity(activeTab == .forYou || activeTab == .groups ? 1 : 0)
                                                .padding(.bottom, 90)
                                            }
                                            
                                            // Today Page - always mounted, visibility controlled
                                            if activeTab == .today {
                                                TodayPage(currentUser: appEnvironment.currentUser)
                                                    .opacity(activeTab == .today ? 1 : 0)
                                                    .padding(.bottom, 90)
                                            }
                                        }
                                    }
                                }
                            }
                            .navigationBarHidden(true)
                            .navigationDestination(for: String.self) { route in
                                if route == "profile" {
                                    ProfileView()
                                }
                            }
                        }
                    }}

enum SecondaryNavBarTab: String {
    case forYou = "forYou"
    case today = "today"
    case groups = "groups"
}

struct Group: Identifiable {
    let id: String
    let name: String
}
