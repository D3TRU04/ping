//
//  NewMessageView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/chat/new-message/page.tsx
//  New message screen for selecting users to start a chat
//

import SwiftUI
import Combine

struct NewMessageView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = NewMessageViewModel()
    let onBack: () -> Void
    let onUserPress: (User) -> Void
    let onGroupChatPress: () -> Void
    let onStartChat: ([User], Bool) -> Void
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Nav Bar
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                    
                    Text("New Message")
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                }
                .padding()
                .background(Color.white)
                
                // Search Input
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $viewModel.searchQuery)
                        .textFieldStyle(.plain)
                        .onChange(of: viewModel.searchQuery) { _ in
                            Task {
                                await viewModel.searchUsers(
                                    query: viewModel.searchQuery,
                                    appEnvironment: appEnvironment
                                )
                            }
                        }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(hex: "F5F6FA"))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                // Selected Users Summary
                if !viewModel.selectedUsers.isEmpty {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(viewModel.selectedUsers.count) \(viewModel.selectedUsers.count == 1 ? "person" : "people") selected")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text(viewModel.selectedUsers.count == 1 ? "Individual chat" : "Group chat")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            onStartChat(viewModel.selectedUsers, viewModel.selectedUsers.count > 1)
                        }) {
                            Text("Start Chat")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppColors.mint)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(hex: "E6F7F5"))
                }
                
                // Users List
                ScrollView {
                    if viewModel.searchQuery.isEmpty {
                        // Suggested Users
                        if !viewModel.suggestedUsers.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Suggested")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                
                                ForEach(viewModel.suggestedUsers) { user in
                                    UserSelectRow(
                                        user: user,
                                        isSelected: viewModel.selectedUsers.contains { $0.id == user.id },
                                        onSelect: {
                                            viewModel.toggleUserSelection(user)
                                        }
                                    )
                                }
                            }
                        }
                    } else {
                        // Search Results
                        if viewModel.loading {
                            ProgressView()
                                .padding()
                        } else if viewModel.searchResults.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 64))
                                    .foregroundColor(.gray)
                                
                                Text("No users found")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 64)
                        } else {
                            ForEach(viewModel.searchResults) { user in
                                UserSelectRow(
                                    user: user,
                                    isSelected: viewModel.selectedUsers.contains { $0.id == user.id },
                                    onSelect: {
                                        viewModel.toggleUserSelection(user)
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadSuggestedUsers(appEnvironment: appEnvironment)
        }
    }
}

struct UserSelectRow: View {
    let user: User
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Avatar
                if let avatar = user.avatar, let url = URL(string: avatar) {
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name ?? user.username ?? "User")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let username = user.username {
                        Text("@\(username)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? AppColors.mint : .gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color(hex: "E6F7F5") : Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

@MainActor
class NewMessageViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [User] = []
    @Published var suggestedUsers: [User] = []
    @Published var selectedUsers: [User] = []
    @Published var loading: Bool = false
    
    func loadSuggestedUsers(appEnvironment: AppEnvironment) async {
        // TODO: Load suggested users (e.g., recent contacts, followers)
        // For now, load all users excluding current user
        do {
            let response: [UserSearchResponse] = try await appEnvironment.supabaseClient.get(
                path: "/rest/v1/profiles",
                queryParams: [
                    "select": "id,username,full_name,avatar_url",
                    "limit": "20"
                ],
                responseType: [UserSearchResponse].self
            )
            
            let currentUserId = appEnvironment.currentUser?.id
            suggestedUsers = response
                .filter { $0.id != currentUserId }
                .map { response in
                    User(
                        id: response.id,
                        name: response.fullName,
                        username: response.username,
                        email: nil,
                        avatar: response.avatarUrl
                    )
                }
        } catch {
            // Handle error
        }
    }
    
    func searchUsers(query: String, appEnvironment: AppEnvironment) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        loading = true
        
        do {
            let response: [UserSearchResponse] = try await appEnvironment.supabaseClient.get(
                path: "/rest/v1/profiles",
                queryParams: [
                    "username": "ilike.\(query)%",
                    "select": "id,username,full_name,avatar_url"
                ],
                responseType: [UserSearchResponse].self
            )
            
            let currentUserId = appEnvironment.currentUser?.id
            searchResults = response
                .filter { $0.id != currentUserId }
                .map { response in
                    User(
                        id: response.id,
                        name: response.fullName,
                        username: response.username,
                        email: nil,
                        avatar: response.avatarUrl
                    )
                }
        } catch {
            searchResults = []
        }
        
        loading = false
    }
    
    func toggleUserSelection(_ user: User) {
        if let index = selectedUsers.firstIndex(where: { $0.id == user.id }) {
            selectedUsers.remove(at: index)
        } else {
            selectedUsers.append(user)
        }
    }
}
