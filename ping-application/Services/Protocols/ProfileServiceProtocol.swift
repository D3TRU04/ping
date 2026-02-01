//
//  ProfileServiceProtocol.swift
//  PingNative
//
//  Protocol and types for profile service
//

import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile(userId: String) async throws -> User
    func checkUsernameAvailability(username: String) async throws -> Bool
    func fetchFollowers(userId: String) async throws -> [User]
    func fetchFollowing(userId: String) async throws -> [User]
    func followUser(followerId: String, followingId: String) async throws
    func unfollowUser(followerId: String, followingId: String) async throws
    func isFollowing(followerId: String, followingId: String) async throws -> Bool
    func updateProfile(userId: String, updates: ProfileUpdate) async throws -> User
    func searchUsers(query: String, limit: Int) async throws -> [ProfileSearchResult]
    func deleteAccount(userId: String) async throws
}

// MARK: - Profile Types

struct ProfileUpdate {
    var fullName: String?
    var username: String?
    var bio: String?
    var avatarUrl: String?
    var location: String?
    var pronouns: String?
    var links: String?
    var birthday: String?
    var categoryPreferences: CategoryPreferencesUpdate?

    struct CategoryPreferencesUpdate {
        var categories: [String]?
        var subcategories: [String]?
    }
}

struct ProfileSearchResult: Identifiable {
    let id: String
    let username: String
    let fullName: String?
    let avatarUrl: String?
    let bio: String?
}
