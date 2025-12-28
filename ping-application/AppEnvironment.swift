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

    // Legacy Supabase services (will be migrated)
    let supabaseClient: SupabaseClient
    let mapService: MapService
    let notificationsService: NotificationsService
    let chatService: ChatService
    let placesService: PlacesService
    let profileService: ProfileService

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

        // Initialize legacy Supabase services (temporary - will be migrated)
        self.supabaseClient = SupabaseClient(config: config)
        self.mapService = MapService(config: config)
        self.notificationsService = NotificationsService(supabaseClient: supabaseClient)
        self.chatService = ChatService(supabaseClient: supabaseClient)
        self.placesService = PlacesService(supabaseClient: supabaseClient)
        self.profileService = ProfileService(supabaseClient: supabaseClient)

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
