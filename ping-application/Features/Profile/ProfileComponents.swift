//
//  ProfileComponents.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/components/
//  ProfileCard, ProfileStats, ProfileTabs matching RN implementation
//

import SwiftUI

// MARK: - ProfileCard
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
    let onFollowChange: ((Bool) -> Void)?
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
        onFollowChange: ((Bool) -> Void)? = nil,
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
        self.onFollowChange = onFollowChange
        self.children = children()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Picture
            ZStack {
                Circle()
                    .fill(AppColors.background)
                    .frame(width: 96, height: 96)
                    .overlay(
                        Circle()
                            .stroke(AppColors.borderSubtle, lineWidth: 1)
                    )
                
                if !imageLoaded {
                    ProgressView()
                }
                
                profileImageView
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())
                    .onAppear {
                        imageLoaded = true
                    }
            }
            
            // Name and Pronouns
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Text(fullName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let pronouns = pronouns {
                        Text("(\(pronouns))")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                
                // Username
                Text("@\(username)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // Member since
            if let creationDate = creationDate {
                Text("Joined \(creationDate)")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textTertiary)
            }
            
            // Bio
            if let bio = bio {
                Text(bio)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .lineSpacing(4)
            }
            
            // Location and Links
            HStack(spacing: 24) {
                if let location = location {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(AppColors.textTertiary)
                            .font(.system(size: 14))
                        Text(location)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                if let links = links {
                    HStack(spacing: 6) {
                        Image(systemName: "link")
                            .foregroundColor(AppColors.textTertiary)
                            .font(.system(size: 14))
                        Text(links)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textPrimary)
                            .underline()
                    }
                }
            }
            
            // Follow Button
            if showFollowButton, let currentUserId = currentUserId, let profileUserId = profileUserId {
                FollowButton(
                    currentUserId: currentUserId,
                    profileUserId: profileUserId,
                    onFollowChange: onFollowChange
                )
                .padding(.top, 8)
            }
            
            // Children (ProfileStats, ProfileTabs)
            if let children = children {
                children
                    .padding(.top, 16)
            }
        }
        .padding(.top, 24)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var profileImageView: some View {
        switch profilePicture {
        case .url(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(AppColors.textTertiary)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(AppColors.textTertiary)
                @unknown default:
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        case .image(let name):
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}

enum ImageSource {
    case url(URL?)
    case image(String)
}

// MARK: - ProfileStats
struct ProfileStats: View {
    let following: Int
    let followers: Int
    let onPressFollowing: (() -> Void)?
    let onPressFollowers: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 60) {
            Button(action: {
                onPressFollowing?()
            }) {
                VStack(spacing: 4) {
                    Text("\(following)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("FOLLOWING")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            
            Rectangle()
                .fill(AppColors.borderSubtle)
                .frame(width: 1, height: 32)
            
            Button(action: {
                onPressFollowers?()
            }) {
                VStack(spacing: 4) {
                    Text("\(followers)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("FOLLOWERS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
        .padding(.vertical, 16)
    }
}

// MARK: - ProfileTabs
enum ProfileTabType: String {
    case saved = "Saved"
    case been = "Been"
    case likes = "Likes"
}

struct ProfileTabs: View {
    @Binding var activeTab: ProfileTabType
    let tabs: [ProfileTabType]
    
    init(activeTab: Binding<ProfileTabType>, tabs: [ProfileTabType] = [.saved, .been, .likes]) {
        self._activeTab = activeTab
        self.tabs = tabs
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button(action: {
                    activeTab = tab
                }) {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(.system(size: 16, weight: activeTab == tab ? .bold : .medium))
                            .foregroundColor(activeTab == tab ? AppColors.textPrimary : AppColors.textTertiary)
                        
                        if activeTab == tab {
                            Circle()
                                .fill(AppColors.textPrimary)
                                .frame(width: 4, height: 4)
                        } else {
                            Color.clear.frame(height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppColors.borderSubtle)
                .padding(.horizontal, 24),
            alignment: .bottom
        )
    }
}

// MARK: - FollowButton
struct FollowButton: View {
    let currentUserId: String
    let profileUserId: String
    let onFollowChange: ((Bool) -> Void)?
    @State private var isFollowing: Bool = false
    @State private var loading: Bool = false
    
    var body: some View {
        Button(action: {
            Task {
                await toggleFollow()
            }
        }) {
            if loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isFollowing ? AppColors.textPrimary : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
        .background(isFollowing ? AppColors.background : AppColors.primaryAction)
        .overlay(
            Capsule()
                .stroke(isFollowing ? AppColors.borderSubtle : Color.clear, lineWidth: 1)
        )
        .clipShape(Capsule())
        .padding(.horizontal, 32)
        .task {
            await checkFollowStatus()
        }
    }
    
    func checkFollowStatus() async {
        // TODO: Check follow status from Supabase
    }
    
    func toggleFollow() async {
        loading = true
        // TODO: Toggle follow in Supabase
        isFollowing.toggle()
        onFollowChange?(isFollowing)
        loading = false
    }
}
