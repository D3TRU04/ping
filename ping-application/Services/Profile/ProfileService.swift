//
//  ProfileService.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/services/ (implied)
//  Profile service for Supabase integration
//

import Foundation

class ProfileService {
    private let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    func fetchProfile(userId: String) async throws -> Profile {
        let response: [ProfileResponse] = try await supabaseClient.get(
            path: "/rest/v1/profiles",
            queryParams: [
                "id": "eq.\(userId)"
            ],
            responseType: [ProfileResponse].self
        )
        
        guard let profile = response.first else {
            throw ProfileError.notFound
        }
        
        return profile.toProfile()
    }
    
    func updateProfile(userId: String, updates: ProfileUpdate) async throws -> Profile {
        let response: [ProfileResponse] = try await supabaseClient.patch(
            path: "/rest/v1/profiles",
            body: updates,
            queryParams: ["id": "eq.\(userId)"],
            responseType: [ProfileResponse].self
        )
        
        guard let profile = response.first else {
            throw ProfileError.updateFailed
        }
        
        return profile.toProfile()
    }
    
    func checkUsernameAvailability(username: String) async throws -> Bool {
        let response: [ProfileResponse] = try await supabaseClient.get(
            path: "/rest/v1/profiles",
            queryParams: [
                "username": "eq.\(username)",
                "select": "id"
            ],
            responseType: [ProfileResponse].self
        )
        
        return response.isEmpty
    }
    
    func fetchFollowers(userId: String) async throws -> [User] {
        // Fetch followers from follows table
        let response: [FollowResponse] = try await supabaseClient.get(
            path: "/rest/v1/follows",
            queryParams: [
                "following_id": "eq.\(userId)",
                "select": "follower:profiles(*)"
            ],
            responseType: [FollowResponse].self
        )
        
        return response.compactMap { $0.follower }
    }
    
    func fetchFollowing(userId: String) async throws -> [User] {
        // Fetch following from follows table
        let response: [FollowResponse] = try await supabaseClient.get(
            path: "/rest/v1/follows",
            queryParams: [
                "follower_id": "eq.\(userId)",
                "select": "following:profiles(*)"
            ],
            responseType: [FollowResponse].self
        )
        
        return response.compactMap { $0.following }
    }
    
    func followUser(followerId: String, followingId: String) async throws {
        let request = FollowRequest(followerId: followerId, followingId: followingId)
        let _: EmptyResponse = try await supabaseClient.post(
            path: "/rest/v1/follows",
            body: request,
            queryParams: nil,
            responseType: EmptyResponse.self
        )
    }
    
    func unfollowUser(followerId: String, followingId: String) async throws {
        let _: EmptyResponse = try await supabaseClient.delete(
            path: "/rest/v1/follows",
            queryParams: [
                "follower_id": "eq.\(followerId)",
                "following_id": "eq.\(followingId)"
            ],
            responseType: EmptyResponse.self
        )
    }
    
    func isFollowing(followerId: String, followingId: String) async throws -> Bool {
        let response: [FollowResponse] = try await supabaseClient.get(
            path: "/rest/v1/follows",
            queryParams: [
                "follower_id": "eq.\(followerId)",
                "following_id": "eq.\(followingId)"
            ],
            responseType: [FollowResponse].self
        )
        
        return !response.isEmpty
    }
}

struct ProfileResponse: Codable {
    let id: String
    let fullName: String?
    let username: String?
    let pronouns: String?
    let bio: String?
    let location: String?
    let links: String?
    let avatarUrl: String?
    let birthday: Date?
    let categoryPreferences: [String: [String]]?
    
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
        case categoryPreferences = "category_preferences"
    }
    
    func toProfile() -> Profile {
        Profile(
            id: id,
            fullName: fullName,
            username: username,
            pronouns: pronouns,
            bio: bio,
            location: location,
            links: links,
            avatarUrl: avatarUrl,
            birthday: birthday
        )
    }
}

struct ProfileUpdate: Codable {
    var fullName: String?
    var username: String?
    var pronouns: String?
    var bio: String?
    var location: String?
    var links: String?
    var avatarUrl: String?
    var birthday: Date?
    var categoryPreferences: [String: [String]]?
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case username
        case pronouns
        case bio
        case location
        case links
        case avatarUrl = "avatar_url"
        case birthday
        case categoryPreferences = "category_preferences"
    }
}

struct FollowResponse: Codable {
    let follower: User?
    let following: User?
}

struct FollowRequest: Codable {
    let followerId: String
    let followingId: String
    
    enum CodingKeys: String, CodingKey {
        case followerId = "follower_id"
        case followingId = "following_id"
    }
}

enum ProfileError: LocalizedError {
    case notFound
    case updateFailed
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Profile not found"
        case .updateFailed:
            return "Failed to update profile"
        }
    }
}
