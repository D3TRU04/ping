//
//  UserSearchResultRow.swift
//  PingNative
//
//  User search result row component
//

import SwiftUI

struct UserSearchResultRow: View {
    let user: ProfileSearchResult

    var body: some View {
        HStack(spacing: 14) {
            UserAvatar(avatarUrl: user.avatarUrl)

            UserInfo(user: user)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppColors.textTertiary.opacity(0.4))
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - User Avatar
private struct UserAvatar: View {
    let avatarUrl: String?

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 54, height: 54)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.9), location: 0.0),
                                    .init(color: .white.opacity(0.5), location: 0.4),
                                    .init(color: .white.opacity(0.3), location: 0.7),
                                    .init(color: .white.opacity(0.7), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )

            if let avatarUrl = avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 54, height: 54)
                            .clipShape(Circle())
                    default:
                        Image(systemName: "person.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
    }
}

// MARK: - User Info
private struct UserInfo: View {
    let user: ProfileSearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            if let fullName = user.fullName {
                Text(fullName)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
            }

            Text("@\(user.username)")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)

            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textTertiary)
                    .lineLimit(1)
            }
        }
    }
}
