//
//  SecondaryNavBar.swift
//  PingNative
//
//  Clean secondary navigation matching Profile tabs style
//

import SwiftUI

struct SecondaryNavBar: View {
    @Binding var activeTab: SecondaryNavBarTab
    let currentUser: User?

    var body: some View {
        HStack(spacing: 8) {
            // For You Tab
            TabButton(
                title: "For You",
                isActive: activeTab == .forYou,
                action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        activeTab = .forYou
                    }
                }
            )
            
            // Today Tab
            TabButton(
                title: "Today",
                isActive: activeTab == .today,
                action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        activeTab = .today
                    }
                }
            )
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

struct TabButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(isActive ? .white : AppColors.textSecondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Group {
                        if isActive {
                            LinearGradient(
                                colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        } else {
                            Color(hex: "F3F4F6")
                        }
                    }
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isActive ? Color(hex: "1FC9C3") : Color.clear, lineWidth: 1)
                )
                .shadow(
                    color: isActive ? Color(hex: "1FC9C3").opacity(0.25) : Color.clear,
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.95))
    }
}
