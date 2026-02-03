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
        GlassDock {
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
                        VStack(spacing: 4) {
                            Image(systemName: isSelected ? tab.icon : tab.icon.replacingOccurrences(of: ".fill", with: ""))
                                .font(.system(size: 24, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(isSelected ? AppColors.mint : AppColors.textPrimary.opacity(0.4))
                                .scaleEffect(isSelected ? 1.15 : 1.0)
                                .frame(width: 60, height: 44)
                                // Glow effect for selected icon
                                .shadow(color: isSelected ? AppColors.mint.opacity(0.6) : .clear, radius: 8, x: 0, y: 0)
                            
                            if isSelected {
                                Circle()
                                    .fill(AppColors.mint)
                                    .frame(width: 4, height: 4)
                                    .shadow(color: AppColors.mint.opacity(0.8), radius: 4, x: 0, y: 0)
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        // MARK: - Bottom Dock Safe Area Spacing
        .safeAreaPadding(.bottom, 12) // Respects bottom safe area, adds 12pt separation
    }
}
