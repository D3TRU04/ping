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
                let isSelected = selectedTab == tab

                Button(action: {
                    if isSelected {
                        onReselect?(tab)
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0)) {
                            selectedTab = tab
                        }
                    }
                }) {
                    Image(systemName: isSelected ? tab.icon : tab.icon.replacingOccurrences(of: ".fill", with: ""))
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? AppColors.mint : AppColors.textSecondary)
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
            LiquidGlassMaterial(
                shape: .capsule,
                glassIntensity: glassIntensity,
                distortionIntensity: distortionIntensity
            )
        )
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .safeAreaPadding(.bottom, 12)
    }
}
