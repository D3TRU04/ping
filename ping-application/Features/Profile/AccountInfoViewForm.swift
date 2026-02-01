//
//  AccountInfoView+Form.swift
//  PingNative
//
//  Form logic and actions for account info view
//

import SwiftUI

extension AccountInfoView {

    func loadUserData() {
        guard let user = appEnvironment.currentUser else { return }

        fullName = user.fullName ?? ""
        username = user.username ?? ""
        pronouns = user.pronouns ?? ""
        bio = user.bio ?? ""
        location = user.location ?? ""
        website = user.links?.first ?? ""
    }

    func saveProfile() {
        guard let userId = appEnvironment.currentUser?.id else { return }

        isLoading = true

        Task {
            do {
                let updates = ProfileUpdate(
                    fullName: fullName.isEmpty ? nil : fullName,
                    username: username.isEmpty ? nil : username,
                    bio: bio.isEmpty ? nil : bio,
                    avatarUrl: nil,
                    location: location.isEmpty ? nil : location,
                    pronouns: pronouns.isEmpty ? nil : pronouns,
                    links: website.isEmpty ? nil : website,
                    birthday: nil,
                    categoryPreferences: nil
                )

                let updatedUser = try await appEnvironment.profileService.updateProfile(userId: userId, updates: updates)

                // Update both local state and refresh from server to ensure consistency
                await MainActor.run {
                    appEnvironment.currentUser = updatedUser
                }

                // Refresh from server to ensure we have the latest data
                await appEnvironment.refreshUser()

                await MainActor.run {
                    isLoading = false
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}
