//
//  PreferencesViewModel.swift
//  PingNative
//
//  View model for preferences management
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PreferencesViewModel: ObservableObject {
    @Published var currentCategories: [String] = []
    @Published var currentSubcategories: [String] = []
    @Published var isSaving: Bool = false
    @Published var saveSuccess: Bool = false
    @Published var errorMessage: String?

    func loadCurrentPreferences(userId: String, profileService: ProfileServiceProtocol) async {
        guard !userId.isEmpty else { return }

        do {
            let user = try await profileService.fetchProfile(userId: userId)

            if let categoryPreferences = user.categoryPreferences {
                // Check for legacy format first
                if let legacy = categoryPreferences.legacyFormat, !legacy.isEmpty {
                    var categoryIds: [String] = []
                    var subcats: [String] = []

                    for (categoryName, subs) in legacy {
                        if let category = OnboardingData.categories.first(where: { $0.name == categoryName }) {
                            categoryIds.append(category.id)
                        }
                        subcats.append(contentsOf: subs)
                    }

                    currentCategories = categoryIds
                    currentSubcategories = subcats
                } else {
                    currentCategories = categoryPreferences.categories ?? []
                    currentSubcategories = categoryPreferences.subcategories ?? []
                }
            }
        } catch {
            print("Error loading preferences: \(error)")
            errorMessage = "Failed to load current preferences"
        }
    }

    func savePreferences(
        userId: String,
        categories: [String],
        subcategories: [String],
        profileService: ProfileServiceProtocol
    ) async {
        guard !userId.isEmpty else {
            errorMessage = "User ID not found"
            return
        }

        guard !categories.isEmpty else {
            errorMessage = "Please select at least one category"
            return
        }

        isSaving = true
        saveSuccess = false
        errorMessage = nil

        do {
            let categoryPreferences = ProfileUpdate.CategoryPreferencesUpdate(
                categories: categories,
                subcategories: subcategories
            )

            let updates = ProfileUpdate(categoryPreferences: categoryPreferences)
            _ = try await profileService.updateProfile(userId: userId, updates: updates)

            saveSuccess = true
        } catch {
            print("Error saving preferences: \(error)")
            errorMessage = "Failed to save preferences. Please try again."
        }

        isSaving = false
    }
}
