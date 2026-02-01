//
//  ProfileStats.swift
//  PingNative
//
//  Profile statistics display component
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
        HStack(spacing: 0) {
            StatItem(label: "Following", value: following.map { "\($0)" })
                .onTapGesture { onPressFollowing?() }

            Divider()
                .frame(height: 30)
                .background(AppColors.borderSubtle)

            StatItem(label: "Followers", value: followers.map { "\($0)" })
                .onTapGesture { onPressFollowers?() }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 24)
    }
}

struct StatItem: View {
    let label: String
    let value: String?

    var body: some View {
        VStack(spacing: 4) {
            if let value = value {
                Text(value)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            } else {
                Text("—")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textTertiary)
            }

            Text(label.uppercased())
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .tracking(1.0)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}
