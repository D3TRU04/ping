//
//  ProfileFollowButton.swift
//  PingNative
//
//  Follow/unfollow button component for profiles
//

import SwiftUI

struct ProfileFollowButton: View {
    @Binding var isFollowing: Bool
    let theyFollowMe: Bool
    let currentUserId: String
    let profileUserId: String
    let onFollowChange: ((Bool) -> Void)?
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var loading: Bool = false

    private var isFriend: Bool {
        isFollowing && theyFollowMe
    }

    private var buttonText: String {
        if isFriend {
            return "Friend"
        } else if isFollowing {
            return "Followed"
        } else {
            return "Follow"
        }
    }

    private var buttonIcon: String? {
        if isFriend {
            return "person.2.fill"
        } else if isFollowing {
            return "checkmark"
        } else {
            return nil
        }
    }

    var body: some View {
        Button(action: {
            Task {
                await toggleFollow()
            }
        }) {
            if loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: isFollowing ? AppColors.textPrimary : .white))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                HStack(spacing: 6) {
                    if let icon = buttonIcon {
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .regular))
                    }
                    Text(buttonText)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                }
                .foregroundColor(isFollowing ? AppColors.textPrimary : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .disabled(loading)
        .background(
            Group {
                if isFollowing {
                    // Glass style for followed/friend state
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
                } else {
                    // Solid cyan gradient for follow CTA
                    Capsule().fill(
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
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
        .shadow(color: isFollowing ? Color.black.opacity(0.08) : Color(hex: "1FC9C3").opacity(0.25), radius: 12, x: 0, y: 6)
        .buttonStyle(ScaleButtonStyle(scale: 0.95))
    }

    func toggleFollow() async {
        loading = true

        await MainActor.run {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                isFollowing.toggle()
            }
        }
        onFollowChange?(isFollowing)

        do {
            if isFollowing {
                try await appEnvironment.profileService.followUser(
                    followerId: currentUserId,
                    followingId: profileUserId
                )
                // Send follow notification
                let senderName = appEnvironment.currentUser?.fullName ?? appEnvironment.currentUser?.username ?? "Someone"
                try? await appEnvironment.notificationsService.createNotification(
                    recipientId: profileUserId,
                    senderId: currentUserId,
                    type: "follow",
                    title: "New Follower",
                    message: "\(senderName) started following you",
                    metadata: ["sender_name": senderName, "sender_id": currentUserId]
                )
            } else {
                try await appEnvironment.profileService.unfollowUser(
                    followerId: currentUserId,
                    followingId: profileUserId
                )
            }
        } catch {
            print("Error toggling follow: \(error)")
            await MainActor.run {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    isFollowing.toggle()
                }
            }
            onFollowChange?(isFollowing)
        }

        await MainActor.run {
            loading = false
        }
    }
}
