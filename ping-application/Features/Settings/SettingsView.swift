//
//  SettingsView.swift
//  PingNative
//
//  Main settings screen with account options and logout
//
//  Related files:
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
    @State private var showingLogoutAlert = false
    @State private var isLoggingOut = false
    @State private var showingDeleteAccountAlert = false
    @State private var isDeletingAccount = false

    private func dismiss() {
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
                            .font(.system(size: 16, weight: .medium))
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

    // MARK: - Account Section
    private var accountSection: some View {
        SettingsSectionView(title: "Account") {
            NavigationLink(destination: AccountInfoView().environmentObject(appEnvironment)) {
                SettingsRowContent(
                    icon: "person.circle",
                    title: "Account Info"
                )
            }

            Divider().padding(.leading, 64)

            NavigationLink(destination: NotificationsSettingsView()) {
                SettingsRowContent(
                    icon: "bell",
                    title: "Notifications"
                )
            }

            Divider().padding(.leading, 64)

            NavigationLink(destination: PrivacySettingsView()) {
                SettingsRowContent(
                    icon: "lock",
                    title: "Privacy"
                )
            }

            Divider().padding(.leading, 64)

            Button(action: {
                showingDeleteAccountAlert = true
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(width: 28)

                    Text("Delete Account")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "EF4444"))

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
    }

    // MARK: - Support Section
    private var supportSection: some View {
        SettingsSectionView(title: "Support") {
            NavigationLink(destination: HelpCenterView()) {
                SettingsRowContent(
                    icon: "questionmark.circle",
                    title: "Help Center"
                )
            }

            Divider().padding(.leading, 64)

            NavigationLink(destination: ContactUsView()) {
                SettingsRowContent(
                    icon: "envelope",
                    title: "Contact Us"
                )
            }
        }
    }

    // MARK: - Logout Button
    private var logoutButton: some View {
        Button(action: {
            showingLogoutAlert = true
        }) {
            HStack {
                if isLoggingOut {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Log Out")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "F87171"), Color(hex: "EF4444")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color(hex: "DC2626"), lineWidth: 1.5)
            )
            .shadow(color: Color(hex: "EF4444").opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .disabled(isLoggingOut)
    }

    // MARK: - App Version
    private var appVersion: some View {
        Text("Version 1.0.0")
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(AppColors.textTertiary)
            .padding(.top, 24)
    }

    // MARK: - Actions
    private func logout() async {
        isLoggingOut = true

        do {
            try await Clerk.shared.signOut()

            await MainActor.run {
                appEnvironment.currentUser = nil
                appEnvironment.isAuthenticated = false
                appEnvironment.needsOnboarding = false
                isLoggingOut = false
                dismiss()
            }
        } catch {
            print("Logout failed: \(error.localizedDescription)")
            isLoggingOut = false
        }
    }

    private func deleteAccount() async {
        guard let userId = appEnvironment.currentUser?.id else { return }

        isDeletingAccount = true

        do {
            try await appEnvironment.profileService.deleteAccount(userId: userId)
            try await Clerk.shared.signOut()

            await MainActor.run {
                appEnvironment.currentUser = nil
                appEnvironment.isAuthenticated = false
                appEnvironment.needsOnboarding = false
                isDeletingAccount = false
                dismiss()
            }
        } catch {
            print("Delete account failed: \(error.localizedDescription)")
            isDeletingAccount = false
        }
    }
}
