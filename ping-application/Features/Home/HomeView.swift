//
//  HomeView.swift
//  PingNative
//
//  Clean home screen matching Profile screen style
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var activeTab: SecondaryNavBarTab = .forYou
    @Binding var path: NavigationPath // Changed from @State to @Binding
    @State private var showPreferences = false
    
    // Consistent background color matching Profile
    private let backgroundColor = Color(hex: "FAFAFA")
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Nav Bar
                    HomeTopNavBar(
                        currentUser: appEnvironment.currentUser,
                        onProfileTap: { path.append("profile") }
                    )
                    
                    // Secondary Nav Bar (Tabs)
                    SecondaryNavBar(
                        activeTab: $activeTab,
                        currentUser: appEnvironment.currentUser
                    )
                    
                    // Content based on active tab
                    TabView(selection: $activeTab) {
                        ForYouPage(
                            currentUser: appEnvironment.currentUser,
                            activeTab: activeTab,
                            onUpdatePreferences: {
                                showPreferences = true
                            }
                        )
                        .tag(SecondaryNavBarTab.forYou)

                        TodayPage(
                            currentUser: appEnvironment.currentUser,
                            onUpdatePreferences: {
                                showPreferences = true
                            }
                        )
                        .tag(SecondaryNavBarTab.today)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: activeTab)
                }
                .padding(.bottom, 90) // Space for bottom nav
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
        }
    }
}

enum SecondaryNavBarTab: String {
    case forYou = "forYou"
    case today = "today"
}
