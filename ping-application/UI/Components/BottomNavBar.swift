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
        case chats = "Chats"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .discover: return "map.fill"
            case .notifications: return "bell.fill"
            case .chats: return "message.fill"
            }
        }
    }
    
    var body: some View {
        HStack {
            ForEach([MainTab.home, .discover, .notifications], id: \.self) { tab in
                Spacer()
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 24))
                            .foregroundColor(selectedTab == tab ? .white : AppColors.mint)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(selectedTab == tab ? AppColors.mint : Color.clear)
                            )
                    }
                }
                Spacer()
            }
            
            // Chats button
            Spacer()
            Button(action: {
                selectedTab = .chats
            }) {
                VStack(spacing: 4) {
                    Image(systemName: MainTab.chats.icon)
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == .chats ? .white : AppColors.mint)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(selectedTab == .chats ? AppColors.mint : Color.clear)
                        )
                }
            }
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 0) // Padding is handled by safe area or explicitly below
        .padding(.horizontal, 16)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppColors.mint.opacity(0.12)),
            alignment: .top
        )
    }
}
