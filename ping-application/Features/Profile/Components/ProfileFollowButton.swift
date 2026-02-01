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
                    .progressViewStyle(CircularProgressViewStyle(tint: isFollowing ? AppColors.mint : .white))
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
                .foregroundColor(isFollowing ? AppColors.mint : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .disabled(loading)
        .background(
            isFollowing ?
                AnyShapeStyle(Color.white) :
                AnyShapeStyle(LinearGradient(colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")], startPoint: .top, endPoint: .bottom))
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AppColors.mint, lineWidth: isFollowing ? 1.5 : 0)
        )
        .shadow(color: isFollowing ? Color.clear : Color(hex: "1FC9C3").opacity(0.25), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 100)
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
