//
//  AppEnvironment.swift
//  PingNative
//
//  Created on 12/3/25.
//

import Foundation
import SwiftUI
import Combine

/// Global app environment that provides shared services
class AppEnvironment: ObservableObject {
    let config: AppConfig

    // Convex services (primary)
    let convexClient: ConvexClient
    let keychainService: KeychainService
    let authService: AuthService

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

        // Initialize auth with Convex
        self.authService = AuthService(
            convexClient: convexClient,
            keychainService: keychainService
        )

        // Initialize Convex-migrated services
        self.profileService = ProfileService(convexClient: convexClient)
        self.placesService = PlacesService(convexClient: convexClient)
        self.notificationsService = NotificationsService(convexClient: convexClient)

        // Initialize legacy Supabase services (kept for compatibility)
        self.mapService = MapService(config: config)

        // Check if user is already authenticated
        Task {
            await checkAuthStatus()
        }
    }
    
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
}
