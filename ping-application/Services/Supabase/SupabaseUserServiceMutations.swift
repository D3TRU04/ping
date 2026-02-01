//
//  SupabaseUserService+Mutations.swift
//  PingNative
//
//  Mutation operations for user service
//

import Foundation

extension SupabaseUserService {

    // MARK: - Mutation Operations

    /// Create or update user from Clerk
    /// Called when user signs in via Clerk to sync profile
    func createOrUpdateFromClerk(
        clerkUserId: String,
        email: String?,
        phoneNumber: String?,
        profileImageUrl: String?
    ) async throws -> SupabaseUser {
        // Check if user already exists
        if let existing = try await getByClerkId(clerkUserId: clerkUserId) {
            #if DEBUG
            print("👤 Found existing user: \(existing.id)")
            print("   - isOnboarded: \(existing.isOnboarded ?? false)")
            print("   - username: \(existing.username ?? "nil")")
            print("   - fullName: \(existing.fullName ?? "nil")")
            #endif

            // If user is already onboarded, just return existing user
            // No need to update basic Clerk data if profile is complete
            if existing.isOnboarded == true {
                #if DEBUG
                print("👤 User already onboarded, returning existing user")
                #endif
                return existing
            }

            // Update existing user with latest Clerk data
            var updateValues: [String: Any] = [
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ]

            if let email = email {
                updateValues["email"] = email
            }
            if let phoneNumber = phoneNumber {
                updateValues["phone_number"] = phoneNumber
            }
            if let profileImageUrl = profileImageUrl {
                updateValues["profile_picture"] = profileImageUrl
            }

            let updated: SupabaseUser = try await client.update(
                table: "users",
                values: updateValues,
                query: ["id": "eq.\(existing.id)"]
            )

            #if DEBUG
            print("👤 Updated user returned:")
            print("   - isOnboarded: \(updated.isOnboarded ?? false)")
            print("   - username: \(updated.username ?? "nil")")
            #endif

            return updated
        } else {
            // Create new user profile
            // Generate a username from email or use a default
            let username = email?.components(separatedBy: "@").first ?? "user\(Int(Date().timeIntervalSince1970))"

            var insertValues: [String: Any] = [
                "id": UUID().uuidString,
                "clerk_user_id": clerkUserId,
                "username": username,
                "is_onboarded": false
            ]

            if let email = email {
                insertValues["email"] = email
            }
            if let phoneNumber = phoneNumber {
                insertValues["phone_number"] = phoneNumber
            }
            if let profileImageUrl = profileImageUrl {
                insertValues["profile_picture"] = profileImageUrl
            }

            return try await client.insert(
                into: "users",
                values: insertValues
            )
        }
    }

    /// Complete onboarding with profile data
    /// Called at the end of onboarding flow
    func completeOnboarding(
        clerkUserId: String,
        fullName: String,
        birthday: String,
        username: String,
        categoryPreferences: [String],
        subcategoryPreferences: [String]
    ) async throws -> SupabaseUser {
        // Find user by Clerk ID
        guard let user = try await getByClerkId(clerkUserId: clerkUserId) else {
            throw SupabaseUserError.userNotFound
        }

        // Build category preferences JSON
        let preferencesJson: [String: Any] = [
            "categories": categoryPreferences,
            "subcategories": subcategoryPreferences
        ]

        // Convert preferences to JSON data then to string for Supabase
        let preferencesData = try JSONSerialization.data(withJSONObject: preferencesJson)
        guard let _ = String(data: preferencesData, encoding: .utf8) else {
            throw SupabaseUserError.invalidPreferencesFormat
        }

        // Update profile with onboarding data
        let updateValues: [String: Any] = [
            "full_name": fullName,
            "birthday": birthday,
            "username": username,
            "category_preferences": preferencesJson,
            "is_onboarded": true,
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]

        #if DEBUG
        print("📝 Completing onboarding for user: \(user.id)")
        print("   - fullName: \(fullName)")
        print("   - username: \(username)")
        print("   - birthday: \(birthday)")
        #endif

        let updatedUser: SupabaseUser = try await client.update(
            table: "users",
            values: updateValues,
            query: ["id": "eq.\(user.id)"]
        )

        #if DEBUG
        print("✅ Onboarding saved. Updated user: \(updatedUser.fullName ?? "nil") / @\(updatedUser.username ?? "nil")")
        #endif

        return updatedUser
    }

    /// Update user profile
    func updateProfile(
        userId: String,
        updates: ProfileUpdate
    ) async throws -> SupabaseUser {
        var updateValues: [String: Any] = [
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]

        if let fullName = updates.fullName {
            updateValues["full_name"] = fullName
        }
        if let username = updates.username {
            updateValues["username"] = username
        }
        if let bio = updates.bio {
            updateValues["bio"] = bio
        }
        if let avatarUrl = updates.avatarUrl {
            updateValues["profile_picture"] = avatarUrl
        }
        if let location = updates.location {
            updateValues["location"] = location
        }
        if let pronouns = updates.pronouns {
            updateValues["pronouns"] = pronouns
        }
        if let links = updates.links {
            updateValues["links"] = [links]
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

        return try await client.update(
            table: "users",
            values: updateValues,
            query: ["id": "eq.\(userId)"]
        )
    }
}
