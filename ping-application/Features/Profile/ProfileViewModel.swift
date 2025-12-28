//
//  ProfileViewModel.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/main/page.tsx
//  Updated ViewModel matching RN state management
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var profile: Profile?
    @Published var followers: Int = 0
    @Published var following: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var currentUser: User? {
        user
    }
    
    var profilePicture: ImageSource {
        if let avatarUrl = profile?.avatarUrl, let url = URL(string: avatarUrl) {
            return .url(url)
        }
        return .image("profilepic") // Default placeholder
    }
    
    var creationDate: String? {
        guard let createdAt = user?.createdAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: createdAt)
    }
    
    func load(userId: String) async {
        guard !userId.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        // TODO: Load user and profile from Supabase
        // Match RN implementation:
        // 1. Fetch user from auth
        // 2. Fetch profile from profiles table
        // 3. Fetch follower/following counts
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        isLoading = false
    }
    
    func refreshFollowCounts() async {
        guard let userId = user?.id else { return }
        
        // TODO: Refresh follow counts from Supabase
    }
}

struct Profile: Codable {
    let id: String
    var fullName: String?
    var username: String?
    var pronouns: String?
    var bio: String?
    var location: String?
    var links: String?
    var avatarUrl: String?
    var birthday: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case username
        case pronouns
        case bio
        case location
        case links
        case avatarUrl = "avatar_url"
        case birthday
    }
}
