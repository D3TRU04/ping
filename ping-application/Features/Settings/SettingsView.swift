//
//  SettingsView.swift
//  PingNative
//
//  Main settings screen with account options and logout
//
//  Related files:
//  - SettingsView+Sections.swift - Section views
//  - SettingsView+Actions.swift - Logout and delete actions
//  - PrivacySettingsView.swift - Privacy settings
//  - HelpCenterView.swift - FAQ and help articles
//  - ContactUsView.swift - Contact form
//

import SwiftUI
import Clerk

struct SettingsView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var environmentDismiss
    var onDismiss: (() -> Void)? = nil
    @State var showingLogoutAlert = false
    @State var isLoggingOut = false
    @State var showingDeleteAccountAlert = false
    @State var isDeletingAccount = false

    func dismiss() {
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            environmentDismiss()
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "FAFAFA")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        accountSection
                        supportSection
                        logoutButton
                        appVersion
                        Spacer().frame(height: 40)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    Task {
                        await logout()
                    }
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.")
            }
        }
    }
}
