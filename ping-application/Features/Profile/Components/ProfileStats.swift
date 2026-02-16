//
//  ProfileStats.swift
//  PingNative
//
//  Profile statistics display component
//  Inline "X followers · X following" text
//

import SwiftUI

struct ProfileStats: View {
    let following: Int?
    let followers: Int?
    let onPressFollowing: (() -> Void)?
    let onPressFollowers: (() -> Void)?

    init(following: Int?, followers: Int?, onPressFollowing: (() -> Void)? = nil, onPressFollowers: (() -> Void)? = nil) {
        self.following = following
        self.followers = followers
        self.onPressFollowing = onPressFollowing
        self.onPressFollowers = onPressFollowers
    }

    var body: some View {
        HStack(spacing: 4) {
            Button(action: { onPressFollowers?() }) {
                (Text(followers.map { "\($0)" } ?? "0")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                + Text(" followers")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary))
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())

            Text("·")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)

            Button(action: { onPressFollowing?() }) {
                (Text(following.map { "\($0)" } ?? "0")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                + Text(" following")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary))
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
    }
}
