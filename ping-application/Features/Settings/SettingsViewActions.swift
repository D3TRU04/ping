//
//  SettingsView+Actions.swift
//  PingNative
//
//  Action methods for settings screen
//

import Foundation
import Clerk

extension SettingsView {

    func logout() async {
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

    func deleteAccount() async {
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
