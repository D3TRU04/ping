//
//  SettingsView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/settings/page.tsx
//  Settings screen matching RN implementation
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var isLoggingOut: Bool = false
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
                VStack(spacing: 24) {
                    // Account Section
                    SettingsSection(title: "Account") {
                        SettingsRow(
                            icon: "person",
                            label: "Account Info",
                            action: {
                                // Navigate to AccountInfo
                            }
                        )
                        
                        SettingsRow(
                            icon: "bell",
                            label: "Notifications",
                            action: {
                                // Navigate to NotificationsSettings
                            }
                        )
                    }
                    
                    // Privacy & Security Section
                    SettingsSection(title: "Privacy & Security") {
                        SettingsRow(
                            icon: "lock",
                            label: "Privacy & Security",
                            action: {
                                // Navigate to PrivacySecurity
                            }
                        )
                        
                        SettingsRow(
                            icon: "paintbrush",
                            label: "Appearance",
                            action: {
                                // Navigate to AppearanceSettings
                            }
                        )
                    }
                    
                    // Support Section
                    SettingsSection(title: "Support") {
                        SettingsRow(
                            icon: "info.circle",
                            label: "About Ping",
                            action: {
                                // Navigate to AboutPing
                            }
                        )
                    }
                    
                    // Logout Button
                    Button(action: {
                        Task {
                            await handleLogout()
                        }
                    }) {
                        if isLoggingOut {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        } else {
                            Text("Log Out")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    }
                    .background(Color.red)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .padding(.vertical, 16)
            }
            
            // Top Nav Bar
            VStack {
                SettingsTopNavBar()
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    func handleLogout() async {
        isLoggingOut = true
        
        // Navigate to Startup immediately
        await appEnvironment.logout()
        
        isLoggingOut = false
    }
}

struct SettingsTopNavBar: View {
    let title: String?
    @Environment(\.dismiss) var dismiss
    
    init(title: String? = nil) {
        self.title = title
    }
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
            
            Text(title ?? "Settings")
                .font(.system(size: 20, weight: .bold))
            
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
