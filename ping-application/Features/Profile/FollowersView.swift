//
//  FollowersView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/followers/page.tsx (implied)
//  Followers list view
//

import SwiftUI
import Combine

struct FollowersView: View {
    let userId: String
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = FollowersViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "FAF6F2")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Nav Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                    
                    Text("Followers")
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                }
                .padding()
                .background(Color.white)
                
                // Followers List
                if viewModel.loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.followers.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        
                        Text("No followers yet")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.followers) { user in
                        FollowerRow(user: user) {
                            // Navigate to user profile
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.load(userId: userId, appEnvironment: appEnvironment)
        }
    }
}

struct FollowerRow: View {
    let user: User
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar
                if let profilePicture = user.profilePicture, let url = URL(string: profilePicture) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                }

                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.fullName ?? user.username ?? "User")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    if let username = user.username {
                        Text("@\(username)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

@MainActor
class FollowersViewModel: ObservableObject {
    @Published var followers: [User] = []
    @Published var loading: Bool = false
    
    func load(userId: String, appEnvironment: AppEnvironment) async {
        loading = true
        
        do {
            followers = try await appEnvironment.profileService.fetchFollowers(userId: userId)
        } catch {
            // Handle error
        }
        
        loading = false
    }
}

struct FollowingView: View {
    let userId: String
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = FollowingViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "FAF6F2")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Nav Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                    
                    Text("Following")
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                }
                .padding()
                .background(Color.white)
                
                // Following List
                if viewModel.loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.following.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        
                        Text("Not following anyone yet")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.following) { user in
                        FollowerRow(user: user) {
                            // Navigate to user profile
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.load(userId: userId, appEnvironment: appEnvironment)
        }
    }
}

@MainActor
class FollowingViewModel: ObservableObject {
    @Published var following: [User] = []
    @Published var loading: Bool = false
    
    func load(userId: String, appEnvironment: AppEnvironment) async {
        loading = true
        
        do {
            following = try await appEnvironment.profileService.fetchFollowing(userId: userId)
        } catch {
            // Handle error
        }
        
        loading = false
    }
}
