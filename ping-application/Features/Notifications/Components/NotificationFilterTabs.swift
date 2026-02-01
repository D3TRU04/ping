//
//  NotificationFilterTabs.swift
//  PingNative
//
//  Filter tabs for notifications screen
//

import SwiftUI

struct NotificationFilterTabs: View {
    @Binding var activeFilter: NotificationsViewModel.NotificationFilter
    let counts: NotificationCounts

    var body: some View {
        HStack(spacing: 8) {
            FilterTabButton(
                title: "All",
                count: counts.total,
                isSelected: activeFilter == .all,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        activeFilter = .all
                    }
                }
            )

            FilterTabButton(
                title: "Unread",
                count: counts.unread,
                isSelected: activeFilter == .unread,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        activeFilter = .unread
                    }
                }
            )

            FilterTabButton(
                title: "Read",
                count: counts.total - counts.unread,
                isSelected: activeFilter == .read,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        activeFilter = .read
                    }
                }
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}

struct FilterTabButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(title) (\(count))")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ?
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .top,
                            endPoint: .bottom
                        ) :
                        LinearGradient(
                            colors: [Color(hex: "F3F4F6"), Color(hex: "F3F4F6")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color(hex: "1FC9C3") : Color.clear, lineWidth: 1)
                )
                .shadow(color: isSelected ? Color(hex: "1FC9C3").opacity(0.25) : Color.clear, radius: 10, x: 0, y: 5)
        }
    }
}
