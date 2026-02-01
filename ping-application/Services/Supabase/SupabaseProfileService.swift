//
//  SupabaseProfileService.swift
//  PingNative
//
//  Profile service for Supabase integration
//  Mirrors ProfileService.swift functionality
//

import Foundation

class SupabaseProfileService: ProfileServiceProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Queries

    func fetchProfile(userId: String) async throws -> User {
        let profile: SupabaseUser = try await client.fetch(
            from: "users",
            query: ["id": "eq.\(userId)"],
            single: true
        )
        return profile.toUser()
    }

    func checkUsernameAvailability(username: String) async throws -> Bool {
        let existing: SupabaseUser? = try await client.fetchOptional(
            from: "users",
            query: ["username": "eq.\(username)"],
            select: "id"
        )
        return existing == nil
    }

    // MARK: - Follow Operations

    func fetchFollowers(userId: String) async throws -> [User] {
        // Get follower IDs without join
        struct Follow: Decodable {
            let followerId: String
        }

        let follows: [Follow] = try await client.fetch(
            from: "follows",
            query: ["following_id": "eq.\(userId)"],
            select: "follower_id"
        )

        guard !follows.isEmpty else { return [] }

        // Fetch user profiles separately
        let followerIds = follows.map { $0.followerId }
        let users: [SupabaseUser] = try await client.fetch(
            from: "users",
            query: ["id": "in.(\(followerIds.joined(separator: ",")))"]
        )

        return users.map { $0.toUser() }
    }

    func fetchFollowing(userId: String) async throws -> [User] {
        // Get following IDs without join
        struct Follow: Decodable {
            let followingId: String
        }

        let follows: [Follow] = try await client.fetch(
            from: "follows",
            query: ["follower_id": "eq.\(userId)"],
            select: "following_id"
        )

        guard !follows.isEmpty else { return [] }

        // Fetch user profiles separately
        let followingIds = follows.map { $0.followingId }
        let users: [SupabaseUser] = try await client.fetch(
            from: "users",
            query: ["id": "in.(\(followingIds.joined(separator: ",")))"]
        )

        return users.map { $0.toUser() }
    }

    func followUser(followerId: String, followingId: String) async throws {
        // Use upsert to handle case where follow already exists (prevents duplicate key error)
        struct FollowResult: Decodable {
            let followerId: String
        }

        let _: FollowResult = try await client.upsert(
            into: "follows",
            values: [
                "follower_id": followerId,
                "following_id": followingId
            ],
            onConflict: "follower_id,following_id"
        )
    }

    func unfollowUser(followerId: String, followingId: String) async throws {
        // Delete the follow record
        try await client.delete(
            from: "follows",
            query: [
                "follower_id": "eq.\(followerId)",
                "following_id": "eq.\(followingId)"
            ]
        )
    }

    func isFollowing(followerId: String, followingId: String) async throws -> Bool {
        struct Follow: Decodable {
            let followerId: String
        }

        let follow: Follow? = try await client.fetchOptional(
            from: "follows",
            query: [
                "follower_id": "eq.\(followerId)",
                "following_id": "eq.\(followingId)"
            ],
            select: "follower_id"
        )

        return follow != nil
    }

    // MARK: - Profile Updates

    func updateProfile(userId: String, updates: ProfileUpdate) async throws -> User {
        var updateValues: [String: Any] = [
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]

        if let fullName = updates.fullName {
            updateValues["full_name"] = fullName
        }
        if let username = updates.username {
            updateValues["username"] = username
        }
        if let pronouns = updates.pronouns {
            updateValues["pronouns"] = pronouns
        }
        if let bio = updates.bio {
            updateValues["bio"] = bio
        }
        if let location = updates.location {
            updateValues["location"] = location
        }
        if let links = updates.links {
            updateValues["links"] = [links] // Convert single string to array
        }
        if let avatarUrl = updates.avatarUrl {
            updateValues["profile_picture"] = avatarUrl
        }
        if let birthday = updates.birthday {
            updateValues["birthday"] = birthday
        }
        if let categoryPreferences = updates.categoryPreferences {
            var prefsDict: [String: Any] = [:]
            if let categories = categoryPreferences.categories {
                prefsDict["categories"] = categories
            }
            if let subcategories = categoryPreferences.subcategories {
                prefsDict["subcategories"] = subcategories
            }
            updateValues["category_preferences"] = prefsDict
        }

        #if DEBUG
        print("📝 Updating profile for user: \(userId)")
        print("   - Updates: \(updateValues)")
        #endif

        let updated: SupabaseUser = try await client.update(
            table: "users",
            values: updateValues,
            query: ["id": "eq.\(userId)"]
        )

        #if DEBUG
        print("✅ Profile updated: \(updated.fullName ?? "nil") / @\(updated.username ?? "nil")")
        #endif

        return updated.toUser()
    }

    // MARK: - Search

    func searchUsers(query: String, limit: Int = 20) async throws -> [ProfileSearchResult] {
        // Use ilike for case-insensitive search on username and full_name
        #if DEBUG
        print("🔍 Searching users with query: '\(query)'")
        #endif

        let results: [SupabaseUser] = try await client.fetch(
            from: "users",
            query: [
                "or": "(username.ilike.*\(query)*,full_name.ilike.*\(query)*)",
                "limit": "\(limit)"
            ],
            select: "id,username,full_name,profile_picture,bio"
        )

        #if DEBUG
        print("🔍 Search returned \(results.count) users")
        for user in results {
            print("   - \(user.username ?? "no username"): \(user.fullName ?? "no name")")
        }
        #endif

        return results.map { user in
            ProfileSearchResult(
                id: user.id,
                username: user.username ?? "",
                fullName: user.fullName,
                avatarUrl: user.profilePicture,
                bio: user.bio
            )
        }
    }

    // MARK: - Account Management

    func deleteAccount(userId: String) async throws {
        // This should trigger cascade deletes due to FK constraints
        // Note: In production, you might want to use an RPC function for this
        // to ensure all related data is properly cleaned up
    }
}

