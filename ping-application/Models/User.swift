//
//  User.swift
//  PingNative
//
//  User model for Convex backend
//

import Foundation

struct User: Identifiable, Codable {
    let id: String  // Convex _id
    var clerkUserId: String?  // Clerk user ID (for Clerk integration)
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
    var categoryPreferences: [String: [String]]?
    var hasOnboarded: Bool?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "_id"  // Convex uses _id field
        case clerkUserId  // Clerk user ID
        case email
        case username
        case fullName
        case bio
        case profilePicture
        case birthday
        case phoneNumber
        case location
        case pronouns
        case links
        case categoryPreferences
        case hasOnboarded = "isOnboarded"  // Match Convex schema
        case createdAt
    }

    // Regular initializer for creating User instances programmatically
    init(
        id: String,
        email: String? = nil,
        username: String? = nil,
        fullName: String? = nil,
        bio: String? = nil,
        profilePicture: String? = nil,
        birthday: String? = nil,
        phoneNumber: String? = nil,
        location: String? = nil,
        pronouns: String? = nil,
        links: [String]? = nil,
        categoryPreferences: [String: [String]]? = nil,
        hasOnboarded: Bool? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.fullName = fullName
        self.bio = bio
        self.profilePicture = profilePicture
        self.birthday = birthday
        self.phoneNumber = phoneNumber
        self.location = location
        self.pronouns = pronouns
        self.links = links
        self.categoryPreferences = categoryPreferences
        self.hasOnboarded = hasOnboarded
        self.createdAt = createdAt
    }
}
