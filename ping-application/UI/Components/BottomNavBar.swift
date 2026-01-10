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
        HStack(spacing: 40) {
            ForEach([MainTab.home, .discover, .notifications], id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == tab ? AppColors.primaryAction : AppColors.textTertiary)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .padding(.bottom, 20)
    }
}
