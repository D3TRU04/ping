//
//  SettingsView+Sections.swift
//  PingNative
//
//  Section views for settings screen
//

import SwiftUI

extension SettingsView {

    // MARK: - Account Section
    var accountSection: some View {
        SettingsSectionView(title: "Account") {
            NavigationLink(destination: AccountInfoView().environmentObject(appEnvironment)) {
                SettingsRowContent(
                    icon: "person.circle",
                    title: "Edit Profile"
                )
            }

            Divider().padding(.leading, 64)

            NavigationLink(destination: NotificationsSettingsView().environmentObject(appEnvironment)) {
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
    var supportSection: some View {
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
    var logoutButton: some View {
        Button(action: {
            showingLogoutAlert = true
        }) {
            HStack {
                if isLoggingOut {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Log Out")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
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
    var appVersion: some View {
        Text("Version 1.0.0")
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(AppColors.textTertiary)
            .padding(.top, 24)
    }
}
