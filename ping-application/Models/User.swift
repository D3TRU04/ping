//
//  User.swift
//  PingNative
//
//  User model for Supabase backend
//

import Foundation

// Represents the stored format of category preferences from the backend
// Handles both new format {categories: [...], subcategories: [...]} and old format {"Category Name": ["Subcategory1"]}
struct StoredCategoryPreferences: Codable {
    var categories: [String]?
    var subcategories: [String]?
    // For legacy data stored in old format
    var legacyFormat: [String: [String]]?

    enum CodingKeys: String, CodingKey {
        case categories
        case subcategories
    }

    init(categories: [String]? = nil, subcategories: [String]? = nil) {
        self.categories = categories
        self.subcategories = subcategories
        self.legacyFormat = nil
    }

    init(from decoder: Decoder) throws {
        // First try to decode as the new format with categories/subcategories keys
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            // Check if it has the new format keys
            if container.contains(.categories) || container.contains(.subcategories) {
                self.categories = try container.decodeIfPresent([String].self, forKey: .categories)
                self.subcategories = try container.decodeIfPresent([String].self, forKey: .subcategories)
                self.legacyFormat = nil
                return
            }
        }

        // Fall back to old format: {"Category Name": ["Subcategory1", "Subcategory2"]}
        let dictContainer = try decoder.singleValueContainer()
        let dict = try dictContainer.decode([String: [String]].self)
        self.legacyFormat = dict
        self.categories = nil
        self.subcategories = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(categories, forKey: .categories)
        try container.encodeIfPresent(subcategories, forKey: .subcategories)
    }

    /// Maps OnboardingData category IDs to database category names
    private static let categoryIdToDbName: [String: String] = [
        "food-drink": "food_drink",
        "shopping-markets": "shopping",
        "creative-arts": "creative_arts",
        "social-nightlife": "social_nightlife",
        "recreation-fitness": "recreation_fitness",
        "nature-outdoors": "nature_outdoors",
        "indoor-adventure": "indoor_activities",
        "sight-seeing": "sight_seeing"
    ]

    /// Maps display names (legacy format) to database category names
    private static let displayNameToDbName: [String: String] = [
        "Food & Drink": "food_drink",
        "Shopping & Markets": "shopping",
        "Creative Arts & Crafts": "creative_arts",
        "Social & Nightlife": "social_nightlife",
        "Recreation & Fitness": "recreation_fitness",
        "Nature & Outdoors": "nature_outdoors",
        "Indoor Adventure": "indoor_activities",
        "Sight-Seeing": "sight_seeing"
    ]

    /// Transforms stored preferences to the format expected by places query
    /// Returns {"db_category_name": ["subcategory_value1", "subcategory_value2"]}
    /// Note: Database stores subcategory VALUES (e.g., "fast_food"), not names (e.g., "Fast Food")
    func toPlacesQueryFormat(using onboardingCategories: [Category]) -> [String: [String]] {
        // If we have legacy format data, convert display names to db names
        if let legacy = legacyFormat, !legacy.isEmpty {
            var result: [String: [String]] = [:]
            for (displayName, subs) in legacy {
                if let dbName = Self.displayNameToDbName[displayName] {
                    // Legacy format might have names, try to convert to values
                    if let category = onboardingCategories.first(where: { Self.displayNameToDbName[$0.name] == dbName }) {
                        let subcatValues = subs.compactMap { subcatName in
                            category.subcategories.first(where: { $0.name == subcatName })?.value
                        }
                        if !subcatValues.isEmpty {
                            result[dbName] = subcatValues
                        } else {
                            // Fallback: use as-is (might already be values)
                            result[dbName] = subs
                        }
                    } else {
                        result[dbName] = subs
                    }
                } else {
                    result[displayName] = subs
                }
            }
            return result
        }

        // Otherwise, transform from new format
        guard let categoryIds = categories, !categoryIds.isEmpty else {
            return [:]
        }

        var result: [String: [String]] = [:]

        for categoryId in categoryIds {
            // Map category ID to database name
            guard let dbCategoryName = Self.categoryIdToDbName[categoryId] else {
                #if DEBUG
                print("⚠️ toPlacesQueryFormat: Unknown category ID: \(categoryId)")
                #endif
                continue
            }

            if let category = onboardingCategories.first(where: { $0.id == categoryId }) {
                // Include ALL subcategories for this category (not just user-selected ones)
                // This ensures we don't miss places due to subcategory mismatch
                let allSubcatValues = category.subcategories.map { $0.value }
                result[dbCategoryName] = allSubcatValues
                #if DEBUG
                print("✅ toPlacesQueryFormat: \(dbCategoryName) -> ALL subcats: \(allSubcatValues)")
                #endif
            }
        }

        #if DEBUG
        print("📋 toPlacesQueryFormat result: \(result)")
        #endif

        return result
    }
}

struct User: Identifiable, Codable {
    let id: String  // Supabase UUID
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
    var categoryPreferences: StoredCategoryPreferences?
    var hasOnboarded: Bool?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id  // Supabase uses id field
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
        case hasOnboarded = "is_onboarded"  // Match Supabase schema
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
        categoryPreferences: StoredCategoryPreferences? = nil,
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
