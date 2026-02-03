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
        .padding(.top, 8) // Reduced top padding
        .padding(.bottom, 8) // Added explicit bottom padding for balance
        .background(Color.clear)
    }
}
