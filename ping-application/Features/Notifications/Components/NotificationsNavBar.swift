//
//  NotificationsNavBar.swift
//  PingNative
//
//  Navigation bar for notifications screen
//

import SwiftUI

struct NotificationsNavBar: View {
    var body: some View {
        HStack(alignment: .center) {
            Text("Notifications")
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [Color(hex: "FAFAFA").opacity(0.95), Color(hex: "FAFAFA").opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
