//
//  SupabaseUserModels.swift
//  PingNative
//
//  Model types for user service
//

import Foundation

// MARK: - Supabase User Model

/// User model for Supabase users table
/// Matches the PostgreSQL schema created earlier
/// User model for Supabase users table
/// Note: No CodingKeys needed - SupabaseClient uses .convertFromSnakeCase
/// which automatically converts full_name → fullName, etc.
struct SupabaseUser: Identifiable, Codable {
    let id: String
    var clerkUserId: String?
    var email: String?
    var username: String?
    var fullName: String?
    var bio: String?
    var profilePicture: String?
    var birthday: String?
    var phoneNumber: String?
    var location: String?
    var pronouns: String?
    var links: [String]?
    var categoryPreferences: StoredCategoryPreferences?
    var isOnboarded: Bool?
    var createdAt: Date?
    var updatedAt: Date?
}

// MARK: - Errors

enum SupabaseUserError: LocalizedError {
    case userNotFound
    case invalidPreferencesFormat
    case usernameNotAvailable

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidPreferencesFormat:
            return "Invalid preferences format"
        case .usernameNotAvailable:
            return "Username is not available"
        }
    }
}

// MARK: - Conversion Extension

extension SupabaseUser {
    /// Convert to the app's User model for compatibility
    func toUser() -> User {
        return User(
            id: id,
            email: email,
            username: username,
            fullName: fullName,
            bio: bio,
            profilePicture: profilePicture,
            birthday: birthday,
            phoneNumber: phoneNumber,
            location: location,
            pronouns: pronouns,
            links: links,
            categoryPreferences: categoryPreferences,
            hasOnboarded: isOnboarded,
            createdAt: createdAt
        )
    }
}
