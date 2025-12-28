//
//  AboutPingView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/settings/about/page.tsx (implied)
//  About Ping screen
//

import SwiftUI

struct AboutPingView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FAF6F2"), Color(hex: "F5F5F5")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Logo
                    Text("PING")
                        .font(.system(size: 60, weight: .black))
                        .foregroundColor(.white)
                        .padding(.top, 32)
                    
                    // App Info
                    VStack(spacing: 8) {
                        Text("Ping")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("Version 1.0.0")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    // Description
                    Text("Discover amazing places together. Connect with friends and explore the best spots in your city.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    // Links
                    VStack(spacing: 16) {
                        LinkRow(
                            icon: "doc.text",
                            label: "Terms of Service",
                            url: URL(string: "https://ping.app/terms")!
                        )
                        
                        LinkRow(
                            icon: "lock.shield",
                            label: "Privacy Policy",
                            url: URL(string: "https://ping.app/privacy")!
                        )
                        
                        LinkRow(
                            icon: "questionmark.circle",
                            label: "Help & Support",
                            url: URL(string: "https://ping.app/support")!
                        )
                        
                        LinkRow(
                            icon: "star",
                            label: "Rate App",
                            url: URL(string: "https://apps.apple.com/app/ping")!
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // Copyright
                    Text("© 2025 Ping. All rights reserved.")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.bottom, 32)
                }
            }
            
            // Top Nav Bar
            VStack {
                SettingsTopNavBar(title: "About Ping")
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

struct LinkRow: View {
    let icon: String
    let label: String
    let url: URL
    
    var body: some View {
        Link(destination: url) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                    .frame(width: 32)
                
                Text(label)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}
