//
//  ProfileService.swift
//  PingNative
//
//  Profile service for Convex integration
//

import Foundation

class ProfileService {
    private let convexClient: ConvexClient

    init(convexClient: ConvexClient) {
        self.convexClient = convexClient
    }
    
    func fetchProfile(userId: String) async throws -> User {
        let user: User = try await convexClient.query(
            function: "profiles:getProfile",
            args: ["userId": userId]
        )

        return user
    }
    
    func updateProfile(userId: String, updates: ProfileUpdate) async throws -> User {
        var args: [String: Any] = ["userId": userId]

        // Add only non-nil updates to args
        if let fullName = updates.fullName { args["fullName"] = fullName }
        if let username = updates.username { args["username"] = username }
        if let pronouns = updates.pronouns { args["pronouns"] = pronouns }
        if let bio = updates.bio { args["bio"] = bio }
        if let location = updates.location { args["location"] = location }
        if let links = updates.links { args["links"] = links }
        if let profilePicture = updates.avatarUrl { args["profilePicture"] = profilePicture }
        if let birthday = updates.birthday { args["birthday"] = birthday }
        if let categoryPreferences = updates.categoryPreferences {
            // Convert struct to dictionary for JSON serialization
            var prefsDict: [String: [String]] = [:]
            if let categories = categoryPreferences.categories {
                prefsDict["categories"] = categories
            }
            if let subcategories = categoryPreferences.subcategories {
                prefsDict["subcategories"] = subcategories
            }
            args["categoryPreferences"] = prefsDict
        }

        let user: User = try await convexClient.mutation(
            function: "profiles:updateProfile",
            args: args
        )

        return user
    }
    
    func checkUsernameAvailability(username: String) async throws -> Bool {
        let isAvailable: Bool = try await convexClient.query(
            function: "profiles:checkUsernameAvailability",
            args: ["username": username]
        )

        return isAvailable
    }
    
    func fetchFollowers(userId: String) async throws -> [User] {
        let followers: [User] = try await convexClient.query(
            function: "profiles:getFollowers",
            args: ["userId": userId]
        )

        return followers
    }
    
    func fetchFollowing(userId: String) async throws -> [User] {
        let following: [User] = try await convexClient.query(
            function: "profiles:getFollowing",
            args: ["userId": userId]
        )

        return following
    }
    
    func followUser(followerId: String, followingId: String) async throws {
        struct FollowResult: Codable {
            let _id: String
        }

        let _: FollowResult = try await convexClient.mutation(
            function: "profiles:followUser",
            args: [
                "followerId": followerId,
                "followingId": followingId
            ]
        )
    }
    
    func unfollowUser(followerId: String, followingId: String) async throws {
        struct UnfollowResult: Codable {
            let success: Bool
        }

        let _: UnfollowResult = try await convexClient.mutation(
            function: "profiles:unfollowUser",
            args: [
                "followerId": followerId,
                "followingId": followingId
            ]
        )
    }
    
    func isFollowing(followerId: String, followingId: String) async throws -> Bool {
        let isFollowing: Bool = try await convexClient.query(
            function: "profiles:isFollowing",
            args: [
                "followerId": followerId,
                "followingId": followingId
            ]
        )

        return isFollowing
    }
    
    func deleteAccount(userId: String) async throws {
        struct DeleteResult: Codable {
            let success: Bool
        }

        let _: DeleteResult = try await convexClient.mutation(
            function: "profiles:deleteAccount",
            args: ["userId": userId]
        )
    }

    func searchUsers(query: String, limit: Int = 20) async throws -> [ProfileSearchResult] {
        struct SearchResult: Codable {
            let id: String
            let username: String?
            let fullName: String?
            let profilePicture: String?
            let bio: String?

            enum CodingKeys: String, CodingKey {
                case id = "_id"
                case username
                case fullName
                case profilePicture
                case bio
            }
        }

        let results: [SearchResult] = try await convexClient.query(
            function: "profiles:searchUsers",
            args: ["query": query, "limit": limit]
        )

        return results.map { result in
            ProfileSearchResult(
                id: result.id,
                username: result.username ?? "",
                fullName: result.fullName,
                avatarUrl: result.profilePicture,
                bio: result.bio
            )
        }
    }
}

// MARK: - Profile Search Result (used by SearchUsersView)
struct ProfileSearchResult: Identifiable, Codable {
    let id: String
    let username: String
    let fullName: String?
    let avatarUrl: String?
    let bio: String?
}

// MARK: - Profile Update Model

struct ProfileUpdate: Codable {
    var fullName: String?
    var username: String?
    var pronouns: String?
    var bio: String?
    var location: String?
    var links: String?
    var avatarUrl: String?  // Maps to profilePicture in Convex
    var birthday: String?
    var categoryPreferences: StoredCategoryPreferences?
}

// MARK: - Profile Errors

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
