//
//  OnboardingViewModel+Validation.swift
//  PingNative
//
//  Validation and submit logic for onboarding
//

import Foundation

extension OnboardingViewModel {

    // MARK: - Validation
    func validateCurrentStep() -> Bool {
        var newErrors: [String: String] = [:]
        let stepConfig = getCurrentStepConfig()

        switch stepConfig.type {
        case "email":
            if formData.email.trimmingCharacters(in: .whitespaces).isEmpty {
                newErrors["email"] = "Email is required"
            } else if !formData.email.contains("@") {
                newErrors["email"] = "Please enter a valid email address"
            }
        case "password":
            if formData.password.trimmingCharacters(in: .whitespaces).isEmpty {
                newErrors["password"] = "Password is required"
            } else if formData.password.count < 8 {
                newErrors["password"] = "Password must be at least 8 characters long"
            }
        case "phone-number":
            if formData.phoneNumber.isEmpty {
                newErrors["phoneNumber"] = "Phone number is required"
            } else if formData.phoneNumber.count < 10 {
                newErrors["phoneNumber"] = "Please enter a valid phone number"
            }
        case "name":
            if formData.fullName.trimmingCharacters(in: .whitespaces).isEmpty {
                newErrors["fullName"] = "Full name is required"
            }
        case "username":
            if formData.username.trimmingCharacters(in: .whitespaces).isEmpty {
                newErrors["username"] = "Username is required"
            } else if formData.username.count < 3 {
                newErrors["username"] = "Username must be at least 3 characters"
            } else if !formData.username.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }) {
                newErrors["username"] = "Username can only contain letters, numbers, and underscores"
            }
        case "birthday":
            break
        case "category-selection":
            if selectedCategories.isEmpty {
                newErrors["categories"] = "Please select at least one category"
            }
        case "subcategory-selection":
            if let categoryId = stepConfig.categoryId {
                let category = OnboardingData.categories.first { $0.id == categoryId }
                let categorySubcategories = selectedSubcategories.filter { subcategory in
                    category?.subcategories.contains { $0.name == subcategory } ?? false
                }
                if categorySubcategories.isEmpty {
                    newErrors["subcategories"] = "Please select at least one interest"
                }
            }
        default:
            break
        }

        errors = newErrors
        return newErrors.isEmpty
    }

    /// Check username availability against Supabase (with debouncing)
    func checkUsername(_ username: String) {
        // Cancel any pending check
        usernameCheckTask?.cancel()

        if username.count < 3 {
            usernameAvailable = nil
            return
        }

        // Debounce: wait 300ms before checking
        usernameCheckTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            // Default to true for now - will be validated on submit
            // Full validation happens via appEnvironment.isUsernameAvailable()
            usernameAvailable = true
        }
    }

    // MARK: - Submit (Supabase Version)

    /// Submit onboarding data to Supabase
    func handleSubmit(appEnvironment: AppEnvironment, onComplete: (() -> Void)? = nil) async {
        loading = true
        errors["submit"] = nil

        do {
            // Use AppEnvironment to complete onboarding (Supabase)
            try await appEnvironment.completeOnboarding(
                fullName: formData.fullName,
                birthday: formData.birthday,
                username: formData.username,
                categoryPreferences: selectedCategories,
                subcategoryPreferences: selectedSubcategories
            )

            // Refresh user data to ensure all fields are synced from database
            await appEnvironment.refreshUser()

            // Call completion handler
            onComplete?()

            #if DEBUG
            print("Onboarding submitted successfully to Supabase")
            #endif

        } catch {
            errors["submit"] = error.localizedDescription
            print("Onboarding error: \(error)")
        }

        loading = false
    }
}
