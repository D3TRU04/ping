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
        HStack(spacing: 0) {
            // ForYou button
            Button(action: {
                activeTab = .forYou
            }) {
                Text("For You")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(activeTab == .forYou ? AppColors.mint : Color(hex: "B3B3B3"))
                    .padding(.vertical, 6)
                    .overlay(
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(activeTab == .forYou ? AppColors.mint : Color.clear)
                            .offset(y: 15)
                    )
            }
            .padding(.horizontal, 12)

            // Today button
            Button(action: {
                activeTab = .today
            }) {
                Text("Today")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(activeTab == .today ? AppColors.mint : Color(hex: "B3B3B3"))
                    .padding(.vertical, 6)
                    .overlay(
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(activeTab == .today ? AppColors.mint : Color.clear)
                            .offset(y: 15)
                    )
            }
            .padding(.horizontal, 12)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.1)),
            alignment: .bottom
        )
    }
}
