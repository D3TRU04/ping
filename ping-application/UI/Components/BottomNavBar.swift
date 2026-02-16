//
//  BottomNavBar.swift
//  PingNative
//
//  Source: ping/apps/src/components/BottomNavBar.tsx
//  Generated Swift equivalent matching RN design
//

import SwiftUI

struct BottomNavBar: View {
    @Binding var selectedTab: MainTab
    let currentUser: User?
    var isSatelliteMode: Bool = false
    var isProfileShowing: Bool = false
    var onReselect: ((MainTab) -> Void)? = nil
    var glassIntensity: CGFloat = 0
    var distortionIntensity: CGFloat = 0

    enum MainTab: String, CaseIterable {
        case home = "Home"
        case discover = "Discover"
        case notifications = "Notifications"

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .discover: return "map.fill"
            case .notifications: return "bell.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach([MainTab.home, .discover, .notifications], id: \.self) { tab in
                let isSelected = selectedTab == tab && !(tab == .home && isProfileShowing)

                Button(action: {
                    if selectedTab == tab {
                        // Already on this tab — pop navigation or scroll to top
                        onReselect?(tab)
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0)) {
                            selectedTab = tab
                        }
                    }
                }) {
                    Image(systemName: isSelected ? tab.icon : tab.icon.replacingOccurrences(of: ".fill", with: ""))
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? AppColors.mint : (isSatelliteMode ? .white.opacity(0.7) : AppColors.textSecondary))
                        .shadow(color: isSelected ? AppColors.mint.opacity(0.7) : .clear, radius: 8, x: 0, y: 0)
                        .shadow(color: isSelected ? AppColors.mint.opacity(0.4) : .clear, radius: 16, x: 0, y: 0)
                        .frame(width: 44, height: 24)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            ZStack {
                LiquidGlassMaterial(
                    shape: .capsule,
                    glassIntensity: glassIntensity,
                    distortionIntensity: distortionIntensity
                )
                .opacity(isSatelliteMode ? 0 : 1)

                Color.black.opacity(0.6)
                    .opacity(isSatelliteMode ? 1 : 0)
            }
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.5), location: 0.0),
                            .init(color: .white.opacity(0.3), location: 0.3),
                            .init(color: .white.opacity(0.2), location: 0.6),
                            .init(color: .white.opacity(0.4), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
                .opacity(isSatelliteMode ? 1 : 0)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isSatelliteMode)
        .safeAreaPadding(.bottom, 12)
    }
}
