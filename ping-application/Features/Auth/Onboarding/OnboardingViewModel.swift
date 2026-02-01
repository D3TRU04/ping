//
//  OnboardingViewModel.swift
//  PingNative
//
//  ViewModel for onboarding flow state management
//  Uses Clerk + Supabase for authentication and data
//
//  Related files:
//  - OnboardingModels.swift - Form data and step config models
//  - Components/ - Step view components
//

import Foundation
import SwiftUI
import Combine
import Clerk

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 1
    @Published var formData = OnboardingFormData()
    @Published var loading: Bool = false
    @Published var usernameAvailable: Bool? = nil
    @Published var showDatePicker: Bool = false
    @Published var errors: [String: String] = [:]
    @Published var selectedCategories: [String] = []
    @Published var selectedSubcategories: [String] = []

    enum SignupMethod {
        case email
        case phone
    }
    @Published var signupMethod: SignupMethod = .email

    // Animation state
    @Published var fadeAnim: Double = 1
    @Published var slideAnim: Double = 0
    @Published var scaleAnim: Double = 1

    // Username check debouncing
    var usernameCheckTask: Task<Void, Never>?

    // MARK: - Step Sequence
    var stepSequence: [String] {
        var steps: [String] = []
        steps.append("name")
        steps.append("birthday")
        steps.append("username")
        steps.append("marketing")
        steps.append("category-selection")
        return steps
    }

    var totalSteps: Int {
        var baseCount = stepSequence.count
        baseCount += selectedCategories.count
        baseCount += 1
        return baseCount
    }

    var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(currentStep) / Double(totalSteps)
    }

    var showContinueButton: Bool {
        let stepConfig = getCurrentStepConfig()
        return stepConfig.type != "auth-options"
    }

    var canProceed: Bool {
        let stepConfig = getCurrentStepConfig()

        switch stepConfig.type {
        case "email":
            return !formData.email.trimmingCharacters(in: .whitespaces).isEmpty && formData.email.contains("@")
        case "password":
            return !formData.password.trimmingCharacters(in: .whitespaces).isEmpty && formData.password.count >= 8
        case "phone-number":
            return formData.phoneNumber.count >= 10
        case "name":
            return !formData.fullName.trimmingCharacters(in: .whitespaces).isEmpty
        case "username":
            return formData.username.count >= 3 && usernameAvailable == true
        case "birthday":
            return true
        case "category-selection":
            return selectedCategories.count > 0
        case "subcategory-selection":
            if let categoryId = stepConfig.categoryId {
                let category = OnboardingData.categories.first { $0.id == categoryId }
                let categorySubcategories = selectedSubcategories.filter { subcategory in
                    category?.subcategories.contains { $0.name == subcategory } ?? false
                }
                return categorySubcategories.count > 0
            }
            return false
        default:
            return true
        }
    }
}
