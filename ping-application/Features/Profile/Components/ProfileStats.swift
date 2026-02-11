//
//  ProfileStats.swift
//  PingNative
//
//  Profile statistics display component
//  Refactored to vertical stack under avatar with updated typography
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
        VStack(alignment: .trailing, spacing: 12) {
            // Following Row
            Button(action: { onPressFollowing?() }) {
                (Text(following.map { "\($0)" } ?? "—")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                + Text(" following")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .baselineOffset(-2))
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())

            // Followers Row
            Button(action: { onPressFollowers?() }) {
                (Text(followers.map { "\($0)" } ?? "—")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                + Text(" followers")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .baselineOffset(-2))
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
    }
}
