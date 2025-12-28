//
//  SearchUsersView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/friends/search/page.tsx
//  User search screen with recent searches
//

import SwiftUI
import Combine

struct SearchUsersView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = SearchUsersViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Nav Bar with Search
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.mint)
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search by username", text: $viewModel.searchQuery)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
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
                    .cornerRadius(25)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                
                // Content
                if viewModel.loading {
                    VStack {
                        Spacer()
                        ProgressView()
                        Text("Searching...")
                            .foregroundColor(AppColors.mint)
                            .padding(.top, 8)
                        Spacer()
                    }
                } else if viewModel.searchQuery.isEmpty {
                    // Recent Searches
                    if viewModel.recentSearches.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 64))
                                .foregroundColor(AppColors.mint)
                            
                            Text("Search for users by username")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text("Your recent searches will appear here")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Recents")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewModel.clearRecentSearches()
                                    }) {
                                        Text("Clear All")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.mint)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                ForEach(viewModel.recentSearches) { user in
                                    UserSearchRow(
                                        user: user,
                                        onTap: {
                                            viewModel.saveRecentSearch(user: user)
                                            // Navigate to profile
                                        },
                                        onRemove: {
                                            viewModel.removeRecentSearch(userId: user.id)
                                        }
                                    )
                                }
                            }
                        }
                    }
                } else if viewModel.searchResults.isEmpty {
                    VStack {
                        Spacer()
                        Text("No users found.")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.searchResults) { user in
                                UserSearchRow(
                                    user: user,
                                    onTap: {
                                        viewModel.saveRecentSearch(user: user)
                                        // Navigate to profile
                                    }
                                )
                            }
                        }
                    }
                }
                
                // Bottom Nav Bar
                VStack {
                    Spacer()
                    BottomNavBar(
                        selectedTab: .constant(.home),
                        currentUser: appEnvironment.currentUser
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadRecentSearches()
        }
    }
}

struct UserSearchRow: View {
    let user: UserSearchResult
    let onTap: () -> Void
    var onRemove: (() -> Void)? = nil
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar
                if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                
                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    Text("@\(user.username)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let fullName = user.fullName {
                        Text(fullName)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if let onRemove = onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

@MainActor
class SearchUsersViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [UserSearchResult] = []
    @Published var recentSearches: [UserSearchResult] = []
    @Published var loading: Bool = false
    
    private let recentSearchesKey = "recent_searches"
    
    func searchUsers(query: String, appEnvironment: AppEnvironment) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        loading = true
        
        do {
            // Search users from Supabase
            let response: [UserSearchResponse] = try await appEnvironment.supabaseClient.get(
                path: "/rest/v1/profiles",
                queryParams: [
                    "username": "ilike.\(query)%",
                    "select": "id,username,full_name,avatar_url"
                ],
                responseType: [UserSearchResponse].self
            )
            
            // Filter out current user
            let currentUserId = appEnvironment.currentUser?.id
            searchResults = response
                .filter { $0.id != currentUserId }
                .map { $0.toUserSearchResult() }
        } catch {
            // Handle error
            searchResults = []
        }
        
        loading = false
    }
    
    func loadRecentSearches() async {
        if let data = UserDefaults.standard.data(forKey: recentSearchesKey),
           let decoded = try? JSONDecoder().decode([UserSearchResponse].self, from: data) {
            recentSearches = decoded.map { $0.toUserSearchResult() }
        }
    }
    
    func saveRecentSearch(user: UserSearchResult) {
        // Remove duplicate if exists
        recentSearches.removeAll { $0.id == user.id }
        recentSearches.insert(user, at: 0)
        
        // Keep only last 5
        if recentSearches.count > 5 {
            recentSearches = Array(recentSearches.prefix(5))
        }
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(recentSearches.map { $0.toResponse() }),
           let decoded = try? JSONDecoder().decode([UserSearchResponse].self, from: encoded) {
            if let saved = try? JSONEncoder().encode(decoded) {
                UserDefaults.standard.set(saved, forKey: recentSearchesKey)
            }
        }
    }
    
    func removeRecentSearch(userId: String) {
        recentSearches.removeAll { $0.id == userId }
        
        if let encoded = try? JSONEncoder().encode(recentSearches.map { $0.toResponse() }),
           let decoded = try? JSONDecoder().decode([UserSearchResponse].self, from: encoded) {
            if let saved = try? JSONEncoder().encode(decoded) {
                UserDefaults.standard.set(saved, forKey: recentSearchesKey)
            }
        }
    }
    
    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }
}

struct UserSearchResult: Identifiable, Codable {
    let id: String
    let username: String
    let fullName: String?
    let avatarUrl: String?
    
    func toResponse() -> UserSearchResponse {
        UserSearchResponse(
            id: id,
            username: username,
            fullName: fullName,
            avatarUrl: avatarUrl
        )
    }
}

struct UserSearchResponse: Codable {
    let id: String
    let username: String
    let fullName: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
    }
    
    func toUserSearchResult() -> UserSearchResult {
        UserSearchResult(
            id: id,
            username: username,
            fullName: fullName,
            avatarUrl: avatarUrl
        )
    }
}
