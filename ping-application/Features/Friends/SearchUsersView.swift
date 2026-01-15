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
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Nav Bar with Search
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textTertiary)
                        
                        TextField("Search", text: $viewModel.searchQuery)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($isFocused)
                            .onChange(of: viewModel.searchQuery) { _ in
                                Task {
                                    await viewModel.searchUsers(
                                        query: viewModel.searchQuery,
                                        appEnvironment: appEnvironment
                                    )
                                }
                            }
                        
                        if !viewModel.searchQuery.isEmpty {
                            Button(action: { viewModel.searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(hex: "F5F5F7")) // Lighter gray for cleaner look
                    .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                
                Divider()
                    .opacity(0.5)
                
                // Content
                if viewModel.loading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(AppColors.mint)
                        Spacer()
                    }
                } else if viewModel.searchQuery.isEmpty {
                    // Recent Searches
                    if viewModel.recentSearches.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(Color(hex: "E5E5EA"))
                            
                            Text("Search for users")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text("Recent")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation {
                                            viewModel.clearRecentSearches()
                                        }
                                    }) {
                                        Text("Clear")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(AppColors.mint)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                
                                LazyVStack(spacing: 0) {
                                    ForEach(viewModel.recentSearches) { user in
                                        UserSearchRow(
                                            user: user,
                                            onTap: {
                                                viewModel.saveRecentSearch(user: user)
                                                // Navigate to profile handled by parent or navigation link
                                            },
                                            onRemove: {
                                                withAnimation {
                                                    viewModel.removeRecentSearch(userId: user.id)
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                } else if viewModel.searchResults.isEmpty {
                    VStack {
                        Spacer()
                        Text("No users found")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
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
                        .padding(.top, 8)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            isFocused = true
        }
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
                ZStack {
                    Circle()
                        .fill(Color(hex: "F3F4F6"))
                        .frame(width: 44, height: 44)
                    
                    if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                            default:
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                
                // User Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.username)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let fullName = user.fullName, !fullName.isEmpty {
                        Text(fullName)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                if let onRemove = onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textTertiary)
                            .frame(width: 44, height: 44) // Larger touch target
                            .contentShape(Rectangle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle()) // Full row tappable
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
        guard !query.isEmpty, query.count >= 2 else {
            searchResults = []
            return
        }
        
        loading = true
        
        do {
            let results = try await appEnvironment.profileService.searchUsers(query: query, limit: 20)
            
            // Convert ProfileSearchResult to UserSearchResult
            searchResults = results.map { result in
                UserSearchResult(
                    id: result.id,
                    username: result.username,
                    fullName: result.fullName,
                    avatarUrl: result.avatarUrl
                )
            }
        } catch {
            print("❌ Error searching users: \(error)")
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
