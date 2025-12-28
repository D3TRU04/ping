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
        VStack(spacing: 12) {
            // Profile Picture
            ZStack {
                Circle()
                    .fill(Color(hex: "E0E7EF"))
                    .frame(width: 90, height: 90)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
                
                if !imageLoaded {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                }
                
                profileImageView
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .onAppear {
                        imageLoaded = true
                    }
            }
            
            // Name and Pronouns
            HStack(spacing: 8) {
                Text(fullName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.text)
                
                if let pronouns = pronouns {
                    Text("(\(pronouns))")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            
            // Username
            Text("@\(username)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            
            // Member since
            if let creationDate = creationDate {
                Text("Member since \(creationDate)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.7))
            }
            
            // Bio
            if let bio = bio {
                Text(bio)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            
            // Location and Links
            HStack(spacing: 16) {
                if let location = location {
                    HStack(spacing: 4) {
                        Text("📍")
                        Text(location)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                if let links = links {
                    HStack(spacing: 4) {
                        Text("🔗")
                        Text(links)
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
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
            }
            
            // Children (ProfileStats, ProfileTabs)
            if let children = children {
                children
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private var profileImageView: some View {
        switch profilePicture {
        case .url(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                @unknown default:
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
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
        HStack(spacing: 48) {
            Button(action: {
                onPressFollowing?()
            }) {
                VStack(spacing: 4) {
                    Text("\(following)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.text)
                    
                    Text("Following")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1, height: 32)
            
            Button(action: {
                onPressFollowers?()
            }) {
                VStack(spacing: 4) {
                    Text("\(followers)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.text)
                    
                    Text("Followers")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
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
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(activeTab == tab ? AppColors.text : AppColors.textSecondary)
                        
                        Rectangle()
                            .fill(activeTab == tab ? AppColors.text : Color.clear)
                            .frame(height: 1)
                            .frame(width: 32)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.vertical, 16)
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
                    .padding(.vertical, 10)
            } else {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
        }
        .background(isFollowing ? Color.gray : AppColors.mint)
        .cornerRadius(12)
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
