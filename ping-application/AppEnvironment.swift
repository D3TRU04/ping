//
//  AppEnvironment.swift
//  PingNative
//
//  Global app environment using Clerk + Supabase
//

import Foundation
import SwiftUI
import Combine
import Clerk

/// Global app environment that provides shared services
/// Uses Clerk for authentication and Supabase for data
class AppEnvironment: ObservableObject {
    let config: AppConfig

    // Supabase services (primary)
    let supabaseClient: SupabaseClient
    let userService: SupabaseUserService
    let keychainService: KeychainService

    // Supabase domain services
    let profileService: SupabaseProfileService
    let placesService: SupabasePlacesService
    let collectionsService: SupabaseCollectionsService
    let notificationsService: SupabaseNotificationsService
    let groupsService: SupabaseGroupsService

    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var session: Session?
    @Published var loading: Bool = true
    @Published var needsOnboarding: Bool = false

    @MainActor
    init() {
        // Load configuration
        self.config = AppConfig.load()

        // Initialize core services
        self.keychainService = KeychainService()
        self.supabaseClient = SupabaseClient(
            supabaseUrl: config.supabaseURL,
            supabaseKey: config.supabaseAnonKey
        )

        // Initialize Supabase domain services
        self.userService = SupabaseUserService(client: supabaseClient)
        self.profileService = SupabaseProfileService(client: supabaseClient)
        self.placesService = SupabasePlacesService(client: supabaseClient)
        self.collectionsService = SupabaseCollectionsService(client: supabaseClient)
        self.notificationsService = SupabaseNotificationsService(client: supabaseClient)
        self.groupsService = SupabaseGroupsService(client: supabaseClient)

        // Auth check happens in PingNativeApp after Clerk loads
    }

    // MARK: - Authentication

    /// Check authentication status and sync user with Supabase
    /// Called after Clerk SDK is loaded
    @MainActor
    func checkAuthStatus() async {
        // Check if Clerk user is authenticated
        if let clerkUser = Clerk.shared.user {
            do {
                // Extract user data from Clerk
                let email = clerkUser.emailAddresses.first?.emailAddress
                let phoneNumber = clerkUser.phoneNumbers.first?.phoneNumber
                let profileImageUrl = clerkUser.imageUrl

                // Create or update Supabase profile
                let supabaseUser = try await userService.createOrUpdateFromClerk(
                    clerkUserId: clerkUser.id,
                    email: email,
                    phoneNumber: phoneNumber,
                    profileImageUrl: profileImageUrl
                )

                // Convert to app User model
                self.currentUser = supabaseUser.toUser()
                self.isAuthenticated = true
                // Returning user (app launch): never show onboarding
                // Onboarding is only shown during signup flow
                self.needsOnboarding = false
                self.loading = false

                #if DEBUG
                print("✅ User authenticated (returning): \(supabaseUser.id)")
                print("   - isOnboarded from Supabase: \(supabaseUser.isOnboarded ?? false)")
                print("   - needsOnboarding set to: false (returning user)")
                print("   - username: \(supabaseUser.username ?? "nil")")
                print("   - fullName: \(supabaseUser.fullName ?? "nil")")
                #endif

            } catch {
                print("❌ Error syncing user to Supabase: \(error)")
                // Even if Supabase sync fails, Clerk user is authenticated
                // Mark as authenticated but needs onboarding (will retry sync)
                self.isAuthenticated = true
                self.needsOnboarding = true
                self.loading = false
                print("⚠️ User authenticated via Clerk but Supabase sync failed - will retry")
            }
        } else {
            self.isAuthenticated = false
            self.loading = false
        }
    }

    /// Complete onboarding and update user profile
    @MainActor
    func completeOnboarding(
        fullName: String,
        birthday: Date,
        username: String,
        categoryPreferences: [String],
        subcategoryPreferences: [String]
    ) async throws {
        guard let clerkUser = Clerk.shared.user else {
            throw OnboardingError.noClerkUser
        }

        // Format birthday as ISO8601 string
        let birthdayString = ISO8601DateFormatter().string(from: birthday)

        // Call Supabase to complete onboarding
        let updatedUser = try await userService.completeOnboarding(
            clerkUserId: clerkUser.id,
            fullName: fullName,
            birthday: birthdayString,
            username: username,
            categoryPreferences: categoryPreferences,
            subcategoryPreferences: subcategoryPreferences
        )

        // Update local state
        self.currentUser = updatedUser.toUser()
        self.needsOnboarding = false

        #if DEBUG
        print("✅ Onboarding completed for: \(updatedUser.username ?? "unknown")")
        #endif
    }

    /// Logout user
    @MainActor
    func logout() async {
        do {
            try await Clerk.shared.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
            self.needsOnboarding = false

            #if DEBUG
            print("✅ User logged out")
            #endif
        } catch {
            print("❌ Error signing out: \(error)")
        }
    }

    /// Refresh user data from Supabase
    /// Note: This does not change needsOnboarding state - that's only set during auth flows
    @MainActor
    func refreshUser() async {
        guard let clerkUser = Clerk.shared.user else { return }

        do {
            if let supabaseUser = try await userService.getByClerkId(clerkUserId: clerkUser.id) {
                self.currentUser = supabaseUser.toUser()
                // Don't change needsOnboarding here - preserve existing state

                #if DEBUG
                print("🔄 User refreshed: \(supabaseUser.id)")
                print("   - username: \(supabaseUser.username ?? "nil")")
                print("   - fullName: \(supabaseUser.fullName ?? "nil")")
                #endif
            }
        } catch {
            print("❌ Error refreshing user: \(error)")
        }
    }

    /// Check if a username is available
    func isUsernameAvailable(_ username: String) async throws -> Bool {
        return try await userService.isUsernameAvailable(username: username)
    }
}

