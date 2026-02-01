//
//  ProfileCard.swift
//  PingNative
//
//  Profile card component displaying user info and avatar
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
    let showUsernameUnderName: Bool
    let isFollowing: Binding<Bool>?
    let theyFollowMe: Bool
    let onFollowChange: ((Bool) -> Void)?
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
        showUsernameUnderName: Bool = true,
        isFollowing: Binding<Bool>? = nil,
        theyFollowMe: Bool = false,
        onFollowChange: ((Bool) -> Void)? = nil,
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
        self.showUsernameUnderName = showUsernameUnderName
        self.isFollowing = isFollowing
        self.theyFollowMe = theyFollowMe
        self.onFollowChange = onFollowChange
        self.onEditProfile = onEditProfile
        self.children = children()
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 48)

            // Profile Picture with Subtle Diffusion
            ZStack {
                Circle()
                    .fill(Color(hex: "1FC9C3").opacity(0.15))
                    .frame(width: 110, height: 110)
                    .blur(radius: 20)

                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )

                if !imageLoaded {
                    ProgressView()
                }

                ProfileImageView(source: profilePicture)
                    .frame(width: 94, height: 94)
                    .clipShape(Circle())
                    .onAppear {
                        imageLoaded = true
                    }
            }
            .padding(.bottom, 20)

            // Info Section
            VStack(spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(fullName)
                        .font(.system(size: 26, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    if let pronouns = pronouns {
                        Text(pronouns)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }

                if showUsernameUnderName {
                    Text("@\(username)")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }

                if let creationDate = creationDate {
                    Text("Joined \(creationDate)")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.top, 2)
                }

                if location != nil || links != nil {
                    HStack(spacing: 16) {
                        if let location = location {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 14))
                                Text(location)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                            }
                            .foregroundColor(AppColors.textTertiary)
                        }
                    }
                    .padding(.top, 12)
                }

                // Primary CTA (Edit or Follow)
                if let onEditProfile = onEditProfile {
                    Button(action: onEditProfile) {
                        Text("Edit Profile")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: "1FC9C3"), lineWidth: 1)
                            )
                            .shadow(color: Color(hex: "1FC9C3").opacity(0.25), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 100)
                    .padding(.top, 12)
                } else if showFollowButton, let currentUserId = currentUserId, let profileUserId = profileUserId {
                    ProfileFollowButton(
                        isFollowing: isFollowing ?? .constant(false),
                        theyFollowMe: theyFollowMe,
                        currentUserId: currentUserId,
                        profileUserId: profileUserId,
                        onFollowChange: onFollowChange
                    )
                    .padding(.top, 12)
                }
            }

            if let children = children {
                children
                    .padding(.top, 16)
            }
        }
    }

}
