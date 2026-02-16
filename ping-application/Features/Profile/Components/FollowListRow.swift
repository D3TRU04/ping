//
//  FollowListRow.swift
//  PingNative
//
//  Individual row in the inline followers/following list
//

import SwiftUI

struct FollowListRow: View {
    let user: User
    let currentUserId: String
    let isFollowing: Bool
    let theyFollowMe: Bool
    let onToggleFollow: () -> Void
    var onTapUser: (() -> Void)? = nil

    private var isSelf: Bool {
        user.id == currentUserId
    }

    private var isFriend: Bool {
        isFollowing && theyFollowMe
    }

    private var buttonText: String {
        if isFriend {
            return "Friend"
        } else if isFollowing {
            return "Following"
        } else {
            return "Follow"
        }
    }

    private var profileImage: ImageSource {
        if let pictureUrl = user.profilePicture, let url = URL(string: pictureUrl) {
            return .url(url)
        }
        return .placeholder
    }

    var body: some View {
        HStack(spacing: 12) {
            // Avatar + Name (tappable for navigation)
            HStack(spacing: 12) {
                ProfileImageView(source: profileImage)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(user.fullName ?? "User")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    Text("@\(user.username ?? "")")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { onTapUser?() }

            Spacer()

            // Follow button (hidden for self)
            if !isSelf {
                Button(action: onToggleFollow) {
                    Text(buttonText)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                Capsule().fill(Color.white.opacity(0.12))
                                Capsule().fill(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .white.opacity(0.2), location: 0.0),
                                            .init(color: .white.opacity(0.05), location: 0.3),
                                            .init(color: .white.opacity(0.0), location: 0.5),
                                            .init(color: .white.opacity(0.02), location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                            }
                        )
                        .clipShape(Capsule())
                        .overlay(
                            ZStack {
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            stops: [
                                                .init(color: .white.opacity(1.0), location: 0.0),
                                                .init(color: .white.opacity(0.7), location: 0.3),
                                                .init(color: .white.opacity(0.5), location: 0.6),
                                                .init(color: .white.opacity(0.85), location: 1.0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                                Capsule()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                                    .padding(1)
                            }
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(ScaleButtonStyle(scale: 0.95))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}
