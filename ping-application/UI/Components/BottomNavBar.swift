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
    
    private var backgroundColor: Color {
        isSatelliteMode ? Color.black.opacity(0.6) : Color.white
    }
    
    private var unselectedColor: Color {
        isSatelliteMode ? Color.white.opacity(0.5) : AppColors.textTertiary
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
                    VStack(spacing: 4) {
                        Image(systemName: isSelected ? tab.icon : tab.icon.replacingOccurrences(of: ".fill", with: ""))
                            .font(.system(size: 24, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? AppColors.mint : unselectedColor)
                            .scaleEffect(isSelected ? 1.15 : 1.0)
                            .frame(width: 60, height: 44)
                        
                        if isSelected {
                            Circle()
                                .fill(AppColors.mint)
                                .frame(width: 4, height: 4)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal, 60)
        .padding(.bottom, 8)
    }
}
