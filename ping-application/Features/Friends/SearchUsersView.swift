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
    @State private var selectedUserId: String?
    @State private var navigateToProfile: Bool = false

    // Consistent background color
    private let backgroundColor = Color(hex: "FAFAFA")

    var body: some View {
        ZStack {
            // Abstract Background
            backgroundColor.ignoresSafeArea()
            
            // Abstract Blobs
            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(Color(hex: "6EE7E7").opacity(0.1))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: -100, y: -100)
                    
                    Circle()
                        .fill(Color(hex: "1FC9C3").opacity(0.1))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: 150, y: 100)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Nav Bar with Search
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(AppColors.textTertiary)
                        
                        TextField("Search users...", text: $viewModel.searchQuery)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
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
                                    .font(.system(size: 18))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(24) // More rounded
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(
                    LinearGradient(
                        colors: [backgroundColor.opacity(0.9), backgroundColor.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Content
                if viewModel.loading {
                    VStack(spacing: 16) {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                            .scaleEffect(1.2)
                        Text("Searching users...")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                    }
                } else if viewModel.searchQuery.isEmpty {
                    // Recent Searches
                    if viewModel.recentSearches.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "6EE7E7").opacity(0.1), Color(hex: "1FC9C3").opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .blur(radius: 10)
                                
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(Color(hex: "B2BEC3"))
                            }
                            
                            VStack(spacing: 8) {
                                Text("Discover People")
                                    .font(.system(size: 22, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("Find friends and see what they're up to")
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text("Recent")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .textCase(.uppercase)
                                        .tracking(1)
                                        .foregroundColor(AppColors.textTertiary)
                                    
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
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                                .padding(.bottom, 16)
                                
                                LazyVStack(spacing: 0) {
                                    ForEach(Array(viewModel.recentSearches.enumerated()), id: \.element.id) { index, user in
                                        UserSearchRow(
                                            user: user,
                                            onTap: {
                                                viewModel.saveRecentSearch(user: user)
                                                selectedUserId = user.id
                                                navigateToProfile = true
                                            },
                                            onRemove: {
                                                withAnimation {
                                                    viewModel.removeRecentSearch(userId: user.id)
                                                }
                                            }
                                        )
                                        
                                        if index < viewModel.recentSearches.count - 1 {
                                                        Divider()
                                                            .padding(.leading, 70)
                                                            .padding(.trailing, 0)
                                                            .opacity(0.4)                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                } else if viewModel.searchResults.isEmpty {
                    VStack(spacing: 14) {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.slash")
                                .font(.system(size: 32, weight: .regular))
                                .foregroundColor(Color(hex: "B2BEC3"))
                        }
                        
                        VStack(spacing: 4) {
                            Text("No users found")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Try a different search")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, user in
                                UserSearchRow(
                                    user: user,
                                    onTap: {
                                        viewModel.saveRecentSearch(user: user)
                                        selectedUserId = user.id
                                        navigateToProfile = true
                                    }
                                )
                                
                                if index < viewModel.searchResults.count - 1 {
                                                Divider()
                                                    .padding(.leading, 70)
                                                    .padding(.trailing, 0)
                                                    .opacity(0.4)                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }
                }
            }

            // Navigation to Profile
            NavigationLink(
                destination: Group {
                    if let userId = selectedUserId {
                        PublicProfileView(userId: userId)
                            .environmentObject(appEnvironment)
                    }
                },
                isActive: $navigateToProfile
            ) {
                EmptyView()
            }
            .hidden()
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
            HStack(spacing: 16) {
                // Avatar - Cleaner, no glow or extra background
                ZStack {
                    Circle()
                        .fill(AppColors.borderSubtle)
                        .frame(width: 54, height: 54)
                    
                    if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 54, height: 54)
                                    .clipShape(Circle())
                            default:
                                Image(systemName: "person.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                
                // User Info
                VStack(alignment: .leading, spacing: 3) {
                    if let fullName = user.fullName, !fullName.isEmpty {
                        Text(fullName)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                    }
                    
                    Text("@\(user.username)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if let onRemove = onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textTertiary)
                            .frame(width: 30, height: 30)
                            .background(Color.black.opacity(0.04))
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary.opacity(0.4))
                }
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle()) // Makes the whole row tappable
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
