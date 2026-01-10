//
//  SecondaryNavBar.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/components/SecondaryNavBar.tsx
//  Secondary navigation bar with ForYou and Today tabs
//

import SwiftUI

struct SecondaryNavBar: View {
    @Binding var activeTab: SecondaryNavBarTab
    let currentUser: User?

    var body: some View {
        HStack(spacing: 24) {
            // ForYou button
            Button(action: {
                activeTab = .forYou
            }) {
                VStack(spacing: 4) {
                    Text("For You")
                        .font(.system(size: 20, weight: activeTab == .forYou ? .bold : .medium))
                        .foregroundColor(activeTab == .forYou ? AppColors.textPrimary : AppColors.textTertiary)
                    
                    if activeTab == .forYou {
                        Circle()
                            .fill(AppColors.textPrimary)
                            .frame(width: 6, height: 6)
                    } else {
                        Color.clear.frame(height: 6)
                    }
                }
            }

            // Today button
            Button(action: {
                activeTab = .today
            }) {
                VStack(spacing: 4) {
                    Text("Today")
                        .font(.system(size: 20, weight: activeTab == .today ? .bold : .medium))
                        .foregroundColor(activeTab == .today ? AppColors.textPrimary : AppColors.textTertiary)
                    
                    if activeTab == .today {
                        Circle()
                            .fill(AppColors.textPrimary)
                            .frame(width: 6, height: 6)
                    } else {
                        Color.clear.frame(height: 6)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, AppTheme.padding)
        .padding(.bottom, 12)
        .background(AppColors.background)
    }
}
