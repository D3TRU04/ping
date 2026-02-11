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
    let following: Int?
    let followers: Int?
    let onFollowChange: ((Bool) -> Void)?
    let onPressFollowing: (() -> Void)?
    let onPressFollowers: (() -> Void)?
    let onEditProfile: (() -> Void)?
    let children: AnyView?
    /// When true, card leaves a placeholder for the avatar; the actual avatar is drawn in the parent (ProfileView) on top of the nav bar.
    let alignAvatarWithNavBar: Bool
    /// Top padding for the identity row, replacing fixed spacers for better layout control
    let topContentPadding: CGFloat

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
        following: Int? = nil,
        followers: Int? = nil,
        onFollowChange: ((Bool) -> Void)? = nil,
        onPressFollowing: (() -> Void)? = nil,
        onPressFollowers: (() -> Void)? = nil,
        onEditProfile: (() -> Void)? = nil,
        alignAvatarWithNavBar: Bool = false,
        topContentPadding: CGFloat = 60,
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
        self.following = following
        self.followers = followers
        self.onFollowChange = onFollowChange
        self.onPressFollowing = onPressFollowing
        self.onPressFollowers = onPressFollowers
        self.onEditProfile = onEditProfile
        self.alignAvatarWithNavBar = alignAvatarWithNavBar
        self.topContentPadding = topContentPadding
        self.children = children()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Identity row: text left, avatar right (under settings button)
            // Uses custom alignment to center the first line of text (Name) with the Avatar center
            HStack(alignment: .profileNameCenter, spacing: 16) {
                // Info Section (leading)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(fullName)
                            .font(.system(size: 20, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        if let pronouns = pronouns {
                            Text(pronouns)
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                    .alignmentGuide(.profileNameCenter) { d in d[VerticalAlignment.center] }

                    if showUsernameUnderName {
                        Text("@\(username)")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    if let bio = bio, !bio.isEmpty {
                        Text(bio)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 14)
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
                    if showFollowButton, let currentUserId = currentUserId, let profileUserId = profileUserId {
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .alignmentGuide(.profileNameCenter) { d in d[.profileNameCenter] }

                // Right Column: Avatar + Stats (trailing)
                VStack(alignment: .trailing, spacing: 16) {
                    // Profile Picture (trailing). When alignAvatarWithNavBar, parent draws avatar on top of nav bar; here we keep layout space.
                    if alignAvatarWithNavBar {
                        Color.clear
                            .frame(width: 80, height: 80)
                            .alignmentGuide(.profileNameCenter) { d in d[VerticalAlignment.center] }
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 72, height: 72)
                                .shadow(color: AppColors.cardShadow, radius: 4, x: 0, y: 2)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )

                            if !imageLoaded {
                                ProgressView()
                            }

                            ProfileImageView(source: profilePicture)
                                .frame(width: 66, height: 66)
                                .clipShape(Circle())
                                .onAppear {
                                    imageLoaded = true
                                }
                        }
                        .alignmentGuide(.profileNameCenter) { d in d[VerticalAlignment.center] }
                    }
                    
                    // Stats under avatar
                    ProfileStats(
                        following: following,
                        followers: followers,
                        onPressFollowing: onPressFollowing,
                        onPressFollowers: onPressFollowers
                    )
                }
            }
            .padding(.leading, 24)
            .padding(.trailing, 24)
            .padding(.top, topContentPadding)

            if let children = children {
                children
                    .padding(.top, 16)
            }
        }
    }

}

extension VerticalAlignment {
    private enum ProfileNameCenterAlignment: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[VerticalAlignment.center]
        }
    }
    static let profileNameCenter = VerticalAlignment(ProfileNameCenterAlignment.self)
}
