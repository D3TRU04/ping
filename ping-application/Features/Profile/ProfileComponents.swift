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
    let onEditProfile: (() -> Void)? // Added for own profile
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
        self.onFollowChange = onFollowChange
        self.onEditProfile = onEditProfile
        self.children = children()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Spacer for top nav
            Spacer().frame(height: 40)
            
            // Profile Picture with Subtle Diffusion
            ZStack {
                // Diffusion Glow
                Circle()
                    .fill(Color(hex: "1FC9C3").opacity(0.15))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                // Avatar Container
                Circle()
                    .fill(Color.white)
                    .frame(width: 128, height: 128)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
                
                if !imageLoaded {
                    ProgressView()
                }
                
                profileImageView
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .onAppear {
                        imageLoaded = true
                    }
            }
            .padding(.bottom, 24)
            
            // Info Section
            VStack(spacing: 8) {
                // Name & Pronouns
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
                
                // Username
                Text("@\(username)")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                // Joined Date
                if let creationDate = creationDate {
                    Text("Joined \(creationDate)")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.top, 2)
                }
                
                // Bio
                if let bio = bio {
                    Text(bio)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                }
                
                // Metadata (Location, Link) - simplified
                if location != nil || links != nil {
                    HStack(spacing: 16) {
                        if let location = location {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 14))
                                Text(location)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(AppColors.textTertiary)
                        }
                        
                        if let links = links {
                            HStack(spacing: 4) {
                                Image(systemName: "link")
                                    .font(.system(size: 14))
                                Text(links)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
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
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
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
                    .padding(.horizontal, 32)
                    .padding(.top, 12)
                } else if showFollowButton, let currentUserId = currentUserId, let profileUserId = profileUserId {
                    FollowButton(
                        currentUserId: currentUserId,
                        profileUserId: profileUserId,
                        onFollowChange: onFollowChange
                    )
                    .padding(.top, 12)
                }
            }
            
            // Children (Stats, Tabs)
            if let children = children {
                children
                    .padding(.top, 16)
            }
        }
    }
    
    @ViewBuilder
    private var profileImageView: some View {
        switch profilePicture {
        case .url(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Color(hex: "F3F4F6")
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textTertiary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(hex: "F3F4F6"))
                @unknown default:
                    Color(hex: "F3F4F6")
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
    let placesCount: Int // Added for 3rd column
    let onPressFollowing: (() -> Void)?
    let onPressFollowers: (() -> Void)?
    
    init(following: Int, followers: Int, placesCount: Int = 0, onPressFollowing: (() -> Void)? = nil, onPressFollowers: (() -> Void)? = nil) {
        self.following = following
        self.followers = followers
        self.placesCount = placesCount
        self.onPressFollowing = onPressFollowing
        self.onPressFollowers = onPressFollowers
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Following
            StatItem(label: "Following", value: "\(following)")
                .onTapGesture { onPressFollowing?() }
            
            Divider()
                .frame(height: 30)
                .background(AppColors.borderSubtle)
            
            // Followers
            StatItem(label: "Followers", value: "\(followers)")
                .onTapGesture { onPressFollowers?() }
            
            Divider()
                .frame(height: 30)
                .background(AppColors.borderSubtle)
                
            // Places (3rd Column)
            StatItem(label: "Places", value: "\(placesCount)")
        }
        .padding(.vertical, 8)
        // Removed background and shadow
        .padding(.horizontal, 24)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Text(label.uppercased())
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .tracking(1.0)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
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
        HStack(spacing: 8) {
            ForEach(tabs, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        activeTab = tab
                    }
                }) {
                    Text(tab.rawValue)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(activeTab == tab ? .white : AppColors.textSecondary)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            activeTab == tab ?
                                LinearGradient(
                                    colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ) :
                                LinearGradient(
                                    colors: [Color(hex: "F3F4F6"), Color(hex: "F3F4F6")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(activeTab == tab ? Color(hex: "1FC9C3") : Color.clear, lineWidth: 1)
                        )
                        .shadow(color: activeTab == tab ? Color(hex: "1FC9C3").opacity(0.25) : Color.clear, radius: 10, x: 0, y: 5)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}

// MARK: - FollowButton
struct FollowButton: View {
    let currentUserId: String
    let profileUserId: String
    let onFollowChange: ((Bool) -> Void)?
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var isFollowing: Bool = false
    @State private var loading: Bool = false
    @State private var checkingStatus: Bool = true
    
    var body: some View {
        Button(action: {
            Task {
                await toggleFollow()
            }
        }) {
            if loading || checkingStatus {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: isFollowing ? AppColors.textPrimary : .white))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(isFollowing ? AppColors.textPrimary : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
        }
        .disabled(loading || checkingStatus)
        .background(
            isFollowing ?
                LinearGradient(colors: [Color(hex: "F3F4F6"), Color(hex: "F3F4F6")], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")], startPoint: .top, endPoint: .bottom)
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(isFollowing ? AppColors.borderSubtle : Color.clear, lineWidth: 1)
        )
        .shadow(color: isFollowing ? Color.clear : Color(hex: "1FC9C3").opacity(0.25), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 32)
        .task {
            await checkFollowStatus()
        }
    }
    
    func checkFollowStatus() async {
        checkingStatus = true
        do {
            isFollowing = try await appEnvironment.profileService.isFollowing(
                followerId: currentUserId,
                followingId: profileUserId
            )
        } catch {
            print("❌ Error checking follow status: \(error)")
        }
        checkingStatus = false
    }
    
    func toggleFollow() async {
        loading = true
        
        // Optimistic update
        let wasFollowing = isFollowing
        isFollowing.toggle()
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
            print("❌ Error toggling follow: \(error)")
            // Revert on error
            isFollowing = wasFollowing
            onFollowChange?(isFollowing)
        }
        
        loading = false
    }
}