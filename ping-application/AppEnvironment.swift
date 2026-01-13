//
//  AppEnvironment.swift
//  PingNative
//
//  Created on 12/3/25.
//

import Foundation
import SwiftUI
import Combine
import Clerk

/// Global app environment that provides shared services
class AppEnvironment: ObservableObject {
    let config: AppConfig

    // Convex services (primary)
    let convexClient: ConvexClient
    let keychainService: KeychainService

    // COMMENTED OUT: Custom auth (replaced by Clerk)
    // let authService: AuthService

    // Convex-migrated services
    let profileService: ProfileService
    let placesService: PlacesService
    let notificationsService: NotificationsService

    // Legacy Supabase services (still using for compatibility)
    let mapService: MapService

    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var session: Session?
    @Published var loading: Bool = true
    @Published var needsOnboarding: Bool = false  // NEW: Track onboarding state

    @MainActor
    init() {
        // Load configuration
        self.config = AppConfig.load()

        // Initialize Convex services
        self.keychainService = KeychainService()
        self.convexClient = ConvexClient(
            deploymentUrl: config.convexDeploymentUrl,
            keychainService: keychainService
        )

        // COMMENTED OUT: Custom auth (replaced by Clerk)
        // self.authService = AuthService(
        //     convexClient: convexClient,
        //     keychainService: keychainService
        // )

        // Initialize Convex-migrated services
        self.profileService = ProfileService(convexClient: convexClient)
        self.placesService = PlacesService(convexClient: convexClient)
        self.notificationsService = NotificationsService(convexClient: convexClient)

        // Initialize legacy Supabase services (kept for compatibility)
        self.mapService = MapService(config: config)

        // Auth check happens in PingNativeApp after Clerk loads
    }
    
    @MainActor
    func checkAuthStatus() async {
        // Check if Clerk user is authenticated
        if let clerkUser = Clerk.shared.user {
            // Fetch Convex user by Clerk ID
            do {
                let user: User = try await convexClient.query(
                    function: "users:getByClerkId",
                    args: ["clerkUserId": clerkUser.id]
                )
                self.currentUser = user
                self.isAuthenticated = true
                self.needsOnboarding = !(user.hasOnboarded ?? false)
                self.loading = false
            } catch {
                print("❌ Error fetching user from Convex: \(error)")
                self.isAuthenticated = false
                self.loading = false
            }
        } else {
            self.isAuthenticated = false
            self.loading = false
        }
    }

    @MainActor
    func logout() async {
        do {
            try await Clerk.shared.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
            self.needsOnboarding = false
        } catch {
            print("❌ Error signing out: \(error)")
        }
    }

    /* COMMENTED OUT: Custom auth methods (replaced by Clerk)
    @MainActor
    func checkAuthStatus() async {
        if let user = await authService.getCurrentUser() {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }

    @MainActor
    func logout() async {
        await authService.logout()
        self.currentUser = nil
        self.isAuthenticated = false
    }
    */
}
