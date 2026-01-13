//
//  PingNativeApp.swift
//  PingNative
//
//  Created on 12/3/25.
//

import SwiftUI
import Clerk

@main
struct PingNativeApp: App {
    @StateObject private var appEnvironment = AppEnvironment()
    @State private var clerk = Clerk.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appEnvironment)
                .environment(\.clerk, clerk)
                .task {
                    // Configure Clerk with publishable key
                    clerk.configure(publishableKey: appEnvironment.config.clerkPublishableKey)
                    try? await clerk.load()

                    // Check auth status after Clerk loads
                    await appEnvironment.checkAuthStatus()
                }
        }
    }
}
