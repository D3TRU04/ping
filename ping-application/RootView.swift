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

// MARK: - CGFloat Clamping Helper

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

struct MainTabView: View {
    @Binding var selectedTab: BottomNavBar.MainTab
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var discoverSheetExpansion: CGFloat = 0
    @State private var discoverSatelliteMode: Bool = false
    @State private var homeNavigationPath = NavigationPath()
    @State private var discoverNavigationPath = NavigationPath()

    // MARK: - Scroll Tracking State
    @State private var contentScrollOffset: CGFloat = 0
    @State private var contentScrollVelocity: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var lastScrollTime: Date = Date()
    @State private var scrollDecayWorkItem: DispatchWorkItem?
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // MARK: - Computed Glass Values
    private var glassIntensity: CGFloat {
        (contentScrollOffset / 20.0).clamped(to: 0...1)
    }

    private var distortionIntensity: CGFloat {
        reduceMotion ? 0 : (abs(contentScrollVelocity) / 1500.0).clamped(to: 0...1)
    }

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
                        },
                        glassIntensity: glassIntensity,
                        distortionIntensity: distortionIntensity
                    )

                    // Profile island (visible on all tabs)
                    ProfileButtonIsland(
                        currentUser: appEnvironment.currentUser,
                        onProfileTap: { homeNavigationPath.append("profile") },
                        glassIntensity: glassIntensity,
                        distortionIntensity: distortionIntensity
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
        // MARK: - Scroll Offset Tracking
        .onPreferenceChange(ContentScrollOffsetPreferenceKey.self) { newOffset in
            let now = Date()
            let timeDelta = now.timeIntervalSince(lastScrollTime)

            if timeDelta > 0.001 {
                let offsetDelta = newOffset - lastScrollOffset
                let rawVelocity = offsetDelta / CGFloat(timeDelta)
                // Low-pass filter: 70% old + 30% new
                contentScrollVelocity = contentScrollVelocity * 0.7 + rawVelocity * 0.3
            }

            lastScrollOffset = newOffset
            lastScrollTime = now
            contentScrollOffset = newOffset

            // Schedule velocity decay
            scrollDecayWorkItem?.cancel()
            let workItem = DispatchWorkItem {
                withAnimation(.easeOut(duration: 0.4)) {
                    contentScrollVelocity = 0
                }
            }
            scrollDecayWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: workItem)
        }
        // Reset scroll state on tab change
        .onChange(of: selectedTab) { _, _ in
            contentScrollOffset = 0
            contentScrollVelocity = 0
            lastScrollOffset = 0
            lastScrollTime = Date()
            scrollDecayWorkItem?.cancel()
        }
    }
}
