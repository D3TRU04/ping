//
//  NotificationsEmptyStateView.swift
//  PingNative
//
//  Empty state view for notifications screen
//

import SwiftUI

struct NotificationsEmptyStateView: View {
    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "F3F4F6"))
                        .frame(width: 80, height: 80)

                    Image(systemName: "bell.slash")
                        .font(.system(size: 32, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "B2BEC3"))
                }
                .padding(.bottom, 8)

                VStack(spacing: 8) {
                    Text("No notifications")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Text("You're all caught up! New notifications will appear here.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260)
                }
            }

            Spacer()

            // Extra space for bottom nav bar
            Spacer().frame(height: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
