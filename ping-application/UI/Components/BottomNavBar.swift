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
                            .foregroundColor(isSelected ? AppColors.mint : AppColors.textPrimary.opacity(0.7))
                            .scaleEffect(isSelected ? 1.15 : 1.0)
                            .frame(width: 60, height: 44)
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
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            GlassSurface(cornerRadius: 44, opacity: 0.2) {
                Color.white.opacity(0.4)
            }
        )
        .clipShape(Capsule())
        .overlay(
            ZStack {
                Capsule()
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.95), location: 0.0),
                                .init(color: .white.opacity(0.6), location: 0.3),
                                .init(color: .white.opacity(0.4), location: 0.6),
                                .init(color: .white.opacity(0.7), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                Capsule()
                    .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                    .padding(1)
            }
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .safeAreaPadding(.bottom, 12)
    }
}
