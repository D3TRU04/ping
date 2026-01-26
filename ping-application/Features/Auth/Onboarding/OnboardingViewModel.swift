//
//  OnboardingViewModel.swift
//  PingNative
//
//  ViewModel for onboarding flow state management
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

    // MARK: - Current Step View
    var currentStepView: AnyView {
        let stepConfig = getCurrentStepConfig()

        switch stepConfig.type {
        case "auth-options":
            return AnyView(AuthOptionsStepView(
                onEmailSignup: handleEmailSignup,
                onPhoneSignup: handlePhoneSignup
            ))
        case "email":
            return AnyView(EmailStepView(
                email: Binding(get: { self.formData.email }, set: { self.formData.email = $0 }),
                errors: errors
            ))
        case "password":
            return AnyView(PasswordStepView(
                password: Binding(get: { self.formData.password }, set: { self.formData.password = $0 }),
                errors: errors
            ))
        case "phone-number":
            return AnyView(PhoneNumberStepView(
                phoneNumber: Binding(get: { self.formData.phoneNumber }, set: { self.formData.phoneNumber = $0 }),
                errors: errors
            ))
        case "name":
            return AnyView(NameStepView(
                fullName: Binding(get: { self.formData.fullName }, set: { self.formData.fullName = $0 }),
                errors: errors
            ))
        case "birthday":
            return AnyView(BirthdayStepView(
                birthday: Binding(get: { self.formData.birthday }, set: { self.formData.birthday = $0 }),
                showDatePicker: Binding(get: { self.showDatePicker }, set: { self.showDatePicker = $0 }),
                errors: errors
            ))
        case "username":
            return AnyView(UsernameStepView(
                username: Binding(get: { self.formData.username }, set: { self.formData.username = $0 }),
                usernameAvailable: usernameAvailable,
                errors: errors,
                onUsernameChanged: { username in self.checkUsername(username) }
            ))
        case "marketing":
            return AnyView(MarketingStepView(
                titlePart1: stepConfig.titlePart1 ?? "",
                highlightedText: stepConfig.highlightedText ?? "",
                titlePart2: stepConfig.titlePart2 ?? "",
                subtitle: stepConfig.subtitle ?? ""
            ))
        case "category-selection":
            return AnyView(CategorySelectionStepView(
                selectedCategories: Binding(get: { self.selectedCategories }, set: { self.selectedCategories = $0 })
            ))
        case "subcategory-selection":
            if let categoryId = stepConfig.categoryId {
                return AnyView(SubcategorySelectionStepView(
                    categoryId: categoryId,
                    selectedSubcategories: Binding(get: { self.selectedSubcategories }, set: { self.selectedSubcategories = $0 })
                ))
            }
            return AnyView(EmptyView())
        case "final":
            return AnyView(FinalStepView(errors: errors))
        default:
            return AnyView(EmptyView())
        }
    }

    // MARK: - Step Configuration
    func getCurrentStepConfig() -> StepConfig {
        if currentStep <= stepSequence.count {
            let stepType = stepSequence[currentStep - 1]

            switch stepType {
            case "auth-options":
                return StepConfig(type: "auth-options", title: "Create your account", subtitle: "Choose how you'd like to sign up for Ping")
            case "email":
                return StepConfig(type: "email", title: "What's your email?", subtitle: "We'll use this to create your account and keep you signed in.")
            case "password":
                return StepConfig(type: "password", title: "Create a password", subtitle: "Choose a strong password to keep your account secure.")
            case "phone-number":
                return StepConfig(type: "phone-number", title: "What's your number?", subtitle: "We'll use this to verify your account.")
            case "name":
                return StepConfig(type: "name", title: "What's your name?", subtitle: "We'd love to know what to call you")
            case "birthday":
                return StepConfig(type: "birthday", title: "When's your birthday?", subtitle: "We'll use this to personalize your experience")
            case "username":
                return StepConfig(type: "username", title: "Choose your username", subtitle: "This will be your unique identifier on Ping")
            case "marketing":
                return StepConfig(
                    type: "marketing",
                    title: nil,
                    subtitle: "Connect with friends and explore the best spots in your city.",
                    titlePart1: "Discover amazing places ",
                    highlightedText: "together.",
                    titlePart2: ""
                )
            case "category-selection":
                return StepConfig(type: "category-selection", title: "What interests you most?", subtitle: "Select the categories that resonate with you")
            default:
                break
            }
        }

        let subcategoryStepIndex = currentStep - stepSequence.count - 1
        if subcategoryStepIndex >= 0 && subcategoryStepIndex < selectedCategories.count {
            let categoryId = selectedCategories[subcategoryStepIndex]
            let category = OnboardingData.categories.first { $0.id == categoryId }
            return StepConfig(
                type: "subcategory-selection",
                title: category?.name ?? "Select Interests",
                subtitle: category?.description ?? "Choose your specific interests",
                categoryId: categoryId
            )
        }

        return StepConfig(type: "final", title: "You're all set!", subtitle: "Welcome to the Ping community")
    }

    // MARK: - Navigation
    func nextStep(appEnvironment: AppEnvironment, onComplete: (() -> Void)? = nil) async {
        if !validateCurrentStep() { return }

        if currentStep < totalSteps {
            await advanceStep()
        } else {
            await handleSubmit(appEnvironment: appEnvironment, onComplete: onComplete)
        }
    }

    func prevStep() {
        Task { @MainActor in
            if currentStep > 1 {
                fadeAnim = 0
                currentStep -= 1
                slideAnim = -15

                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    fadeAnim = 1
                    slideAnim = 0
                }
            }
        }
    }

    func handleEmailSignup() {
        signupMethod = .email
        Task { @MainActor in await advanceStep() }
    }

    func handlePhoneSignup() {
        signupMethod = .phone
        Task { @MainActor in await advanceStep() }
    }

    private func advanceStep() async {
        fadeAnim = 0
        currentStep += 1
        slideAnim = 15

        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            fadeAnim = 1
            slideAnim = 0
        }
    }

    func handleGoogleSignup() {}
    func handleAppleSignup() {}

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

    func checkUsername(_ username: String) {
        if username.count < 3 {
            usernameAvailable = nil
            return
        }

        Task {
            usernameAvailable = true
        }
    }

    // MARK: - Submit
    func handleSubmit(appEnvironment: AppEnvironment, onComplete: (() -> Void)? = nil) async {
        loading = true
        errors["submit"] = nil

        do {
            guard let clerkUser = Clerk.shared.user else {
                throw OnboardingError.noClerkUser
            }

            let updatedUser: User = try await appEnvironment.convexClient.mutation(
                function: "users:completeOnboarding",
                args: [
                    "clerkUserId": clerkUser.id,
                    "fullName": formData.fullName,
                    "birthday": ISO8601DateFormatter().string(from: formData.birthday),
                    "username": formData.username,
                    "categoryPreferences": selectedCategories,
                    "subcategoryPreferences": selectedSubcategories
                ]
            )

            appEnvironment.currentUser = updatedUser
            appEnvironment.needsOnboarding = false
            onComplete?()

        } catch {
            errors["submit"] = error.localizedDescription
        }

        loading = false
    }
}
