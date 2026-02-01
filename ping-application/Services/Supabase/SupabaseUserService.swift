//
//  SupabaseUserService.swift
//  PingNative
//
//  User service for Supabase backend
//  User service for profile operations
//
//  Authentication is handled by Clerk
//  This service handles user profile data in Supabase
//

import Foundation

/// User service for Supabase profile operations
/// Handles user mutations and queries
class SupabaseUserService {
    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Query Operations

    /// Get user by Supabase profile ID
    func getById(userId: String) async throws -> SupabaseUser {
        return try await client.fetch(
            from: "users",
            query: ["id": "eq.\(userId)"],
            single: true
        )
    }

    /// Get user by email
    func getByEmail(email: String) async throws -> SupabaseUser? {
        return try await client.fetchOptional(
            from: "users",
            query: ["email": "eq.\(email)"]
        )
    }

    /// Get user by username
    func getByUsername(username: String) async throws -> SupabaseUser? {
        return try await client.fetchOptional(
            from: "users",
            query: ["username": "eq.\(username)"]
        )
    }

    /// Get user by Clerk ID
    /// This is the primary lookup method when using Clerk auth
    func getByClerkId(clerkUserId: String) async throws -> SupabaseUser? {
        let user: SupabaseUser? = try await client.fetchOptional(
            from: "users",
            query: ["clerk_user_id": "eq.\(clerkUserId)"]
        )

        #if DEBUG
        if let user = user {
            print("📥 getByClerkId returned user:")
            print("   - id: \(user.id)")
            print("   - fullName: \(user.fullName ?? "nil")")
            print("   - username: \(user.username ?? "nil")")
            print("   - isOnboarded: \(user.isOnboarded ?? false)")
        } else {
            print("📥 getByClerkId: No user found for clerkUserId: \(clerkUserId)")
        }
        #endif

        return user
    }

    /// Check if username is available
    func isUsernameAvailable(username: String) async throws -> Bool {
        let existing: SupabaseUser? = try await client.fetchOptional(
            from: "users",
            query: ["username": "eq.\(username)"],
            select: "id"
        )
        return existing == nil
    }
}
