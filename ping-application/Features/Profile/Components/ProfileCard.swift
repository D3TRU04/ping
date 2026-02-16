//
//  ProfileCard.swift
//  PingNative
//
//  Profile card component displaying user info and avatar
//  Threads-style: avatar top-left, vertical info stack, full-width actions
//
//  Related files:
//  - ProfileCardImageView.swift - Image source and profile image view
//

import SwiftUI

struct ProfileCard: View {
    let profilePicture: ImageSource
    let fullName: String
    let pronouns: String?
    let username: String
    let creationDate: String?
    let bio: String?
    let location: String?
    let links: String?
    let currentUserId: String?
    let profileUserId: String?
    let showFollowButton: Bool
    let isFollowing: Binding<Bool>?
    let theyFollowMe: Bool
    let following: Int?
    let followers: Int?
    let onFollowChange: ((Bool) -> Void)?
    let onPressFollowing: (() -> Void)?
    let onPressFollowers: (() -> Void)?
    let onEditProfile: (() -> Void)?
    let children: AnyView?

    @State private var imageLoaded: Bool = false

    init(
        profilePicture: ImageSource,
        fullName: String,
        pronouns: String? = nil,
        username: String,
        creationDate: String? = nil,
        bio: String? = nil,
        location: String? = nil,
        links: String? = nil,
        currentUserId: String? = nil,
        profileUserId: String? = nil,
        showFollowButton: Bool = false,
        isFollowing: Binding<Bool>? = nil,
        theyFollowMe: Bool = false,
        following: Int? = nil,
        followers: Int? = nil,
        onFollowChange: ((Bool) -> Void)? = nil,
        onPressFollowing: (() -> Void)? = nil,
        onPressFollowers: (() -> Void)? = nil,
        onEditProfile: (() -> Void)? = nil,
        @ViewBuilder children: () -> AnyView = { AnyView(EmptyView()) }
    ) {
        self.profilePicture = profilePicture
        self.fullName = fullName
        self.pronouns = pronouns
        self.username = username
        self.creationDate = creationDate
        self.bio = bio
        self.location = location
        self.links = links
        self.currentUserId = currentUserId
        self.profileUserId = profileUserId
        self.showFollowButton = showFollowButton
        self.isFollowing = isFollowing
        self.theyFollowMe = theyFollowMe
        self.following = following
        self.followers = followers
        self.onFollowChange = onFollowChange
        self.onPressFollowing = onPressFollowing
        self.onPressFollowers = onPressFollowers
        self.onEditProfile = onEditProfile
        self.children = children()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Avatar
            ZStack {
                if !imageLoaded {
                    ProgressView()
                }

                ProfileImageView(source: profilePicture)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .shadow(color: AppColors.cardShadow, radius: 4, x: 0, y: 2)
                    .onAppear {
                        imageLoaded = true
                    }
            }
            .padding(.bottom, 12)

            // Full Name + Pronouns
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(fullName)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                if let pronouns = pronouns, !pronouns.isEmpty {
                    Text(pronouns)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)
                }
            }

            // Username
            Text("@\(username)")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .padding(.top, 2)

            // Bio
            if let bio = bio, !bio.isEmpty {
                Text(bio)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)
            }

            // Location
            if let location = location, !location.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14))
                    Text(location)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                }
                .foregroundColor(AppColors.textTertiary)
                .padding(.top, 8)
            }

            // Follower stats
            ProfileStats(
                following: following,
                followers: followers,
                onPressFollowing: onPressFollowing,
                onPressFollowers: onPressFollowers
            )
            .padding(.top, 12)

            // Action button area
            if showFollowButton, let currentUserId = currentUserId, let profileUserId = profileUserId {
                // Public profile: follow button
                ProfileFollowButton(
                    isFollowing: isFollowing ?? .constant(false),
                    theyFollowMe: theyFollowMe,
                    currentUserId: currentUserId,
                    profileUserId: profileUserId,
                    onFollowChange: onFollowChange
                )
                .padding(.top, 16)
            } else if !showFollowButton, let onEditProfile = onEditProfile {
                // Own profile: edit button
                Button(action: onEditProfile) {
                    Text("Edit profile")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
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
                        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(ScaleButtonStyle(scale: 0.95))
                .padding(.top, 16)
            }

            // Children (tabs, mutual buttons, etc.)
            if let children = children {
                children
                    .padding(.top, 16)
            }
        }
        .padding(.horizontal, 24)
    }
}
