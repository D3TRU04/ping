//
//  NotificationFilterTabs.swift
//  PingNative
//
//  Filter tabs for notifications screen
//

import SwiftUI

// MARK: - Filter Tabs

struct NotificationFilterTabs: View {
    @Binding var activeFilter: NotificationsViewModel.NotificationFilter
    let counts: NotificationCounts

    var body: some View {
        // MARK: - Filter Pills Row (Leading Aligned)
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
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure leading alignment
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
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .lineLimit(1) // MARK: Fix text wrapping
                .fixedSize(horizontal: true, vertical: false) // MARK: Force horizontal expansion
                .minimumScaleFactor(1.0) // Do NOT shrink text
                .foregroundColor(isSelected ? .white : AppColors.textPrimary.opacity(0.8))
                .padding(.vertical, 12)
                .padding(.horizontal, 16) // Added explicit horizontal padding for expansion
                .background( // Removed fixed width constraint entirely
                    Group {
                        if isSelected {
                            ZStack {
                                GlassSurface(cornerRadius: 30, opacity: 0.1) { Color.clear }
                                AppColors.mint.opacity(0.8)
                            }
                        } else {
                            GlassSurface(cornerRadius: 30, opacity: 0.05) { Color.clear }
                        }
                    }
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.white.opacity(0.4) : Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(
                    color: isSelected ? AppColors.mint.opacity(0.3) : Color.black.opacity(0.05),
                    radius: 12,
                    x: 0,
                    y: 6
                )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }
}
