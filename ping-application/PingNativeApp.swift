//
//  PingNativeApp.swift
//  PingNative
//
//  Created on 12/3/25.
//

import SwiftUI

@main
struct PingNativeApp: App {
    @StateObject private var appEnvironment = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appEnvironment)
        }
    }
}
