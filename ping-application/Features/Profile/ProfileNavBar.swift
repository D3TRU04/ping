//
//  ProfileNavBar.swift
//  PingNative
//
//  Created on 2025-01-13
//

import SwiftUI

struct ProfileNavBar: View {
    let username: String
    let onSettingsTap: () -> Void
    var isFollowListMode: Bool = false
    var onBackTap: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center) {
            if isFollowListMode {
                GlassCircleButton(icon: "arrow.backward", action: { onBackTap?() })
            } else {
                // Invisible spacer to balance the hamburger button for true centering
                Color.clear
                    .frame(width: 48, height: 48)
            }

            Spacer()

            Text("@\(username)")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            if isFollowListMode {
                Color.clear
                    .frame(width: 48, height: 48)
            } else {
                GlassCircleButton(icon: "line.3.horizontal", action: onSettingsTap)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 0)
        .padding(.bottom, 16)
        .background(Color.clear)
    }
}
