//
//  OnboardingViewModel.swift
//  PingNative
//
//  Source: ping/apps/src/screens/auth/onboarding/hooks/useOnboarding.ts
//  Complete ViewModel matching RN onboarding state management
//

import Foundation
import SwiftUI
import Combine

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
    
    // Animation state
    @Published var fadeAnim: Double = 1
    @Published var slideAnim: Double = 0
    @Published var scaleAnim: Double = 1
    
    var totalSteps: Int {
        // Base steps: auth-options, email, password, name, birthday, username, marketing, category selection
        var total = 8
        // Add one step for each selected category (subcategory selection)
        total += selectedCategories.count
        // Add final step
        total += 1
        return total
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
        case "personal-info":
            if currentStep == 4 {
                return !formData.fullName.trimmingCharacters(in: .whitespaces).isEmpty
            } else if currentStep == 5 {
                return true // Birthday is always valid
            } else if currentStep == 6 {
                return formData.username.count >= 3 && usernameAvailable == true
            }
            return false
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
    
    var currentStepView: AnyView {
        let stepConfig = getCurrentStepConfig()
        
        switch stepConfig.type {
        case "auth-options":
            return AnyView(AuthOptionsStepView(
                onEmailSignup: handleEmailSignup,
                onGoogleSignup: handleGoogleSignup,
                onAppleSignup: handleAppleSignup
            ))
        case "email":
            return AnyView(EmailStepView(
                email: Binding(
                    get: { self.formData.email },
                    set: { self.formData.email = $0 }
                ),
                errors: errors
            ))
        case "password":
            return AnyView(PasswordStepView(
                password: Binding(
                    get: { self.formData.password },
                    set: { self.formData.password = $0 }
                ),
                errors: errors
            ))
        case "personal-info":
            if currentStep == 4 {
                return AnyView(NameStepView(
                    fullName: Binding(
                        get: { self.formData.fullName },
                        set: { self.formData.fullName = $0 }
                    ),
                    errors: errors
                ))
            } else if currentStep == 5 {
                return AnyView(BirthdayStepView(
                    birthday: Binding(
                        get: { self.formData.birthday },
                        set: { self.formData.birthday = $0 }
                    ),
                    showDatePicker: Binding(
                        get: { self.showDatePicker },
                        set: { self.showDatePicker = $0 }
                    ),
                    errors: errors
                ))
            } else if currentStep == 6 {
                return AnyView(UsernameStepView(
                    username: Binding(
                        get: { self.formData.username },
                        set: { self.formData.username = $0 }
                    ),
                    usernameAvailable: usernameAvailable,
                    errors: errors,
                    onUsernameChanged: { username in
                        self.checkUsername(username)
                    }
                ))
            }
            return AnyView(EmptyView())
        case "marketing":
            return AnyView(MarketingStepView(
                titlePart1: stepConfig.titlePart1 ?? "",
                highlightedText: stepConfig.highlightedText ?? "",
                titlePart2: stepConfig.titlePart2 ?? "",
                subtitle: stepConfig.subtitle ?? ""
            ))
        case "category-selection":
            return AnyView(CategorySelectionStepView(
                selectedCategories: Binding(
                    get: { self.selectedCategories },
                    set: { self.selectedCategories = $0 }
                )
            ))
        case "subcategory-selection":
            if let categoryId = stepConfig.categoryId {
                return AnyView(SubcategorySelectionStepView(
                    categoryId: categoryId,
                    selectedSubcategories: Binding(
                        get: { self.selectedSubcategories },
                        set: { self.selectedSubcategories = $0 }
                    )
                ))
            }
            return AnyView(EmptyView())
        case "final":
            return AnyView(FinalStepView(errors: errors))
        default:
            return AnyView(EmptyView())
        }
    }
    
    func getCurrentStepConfig() -> StepConfig {
        if currentStep == 1 {
            return StepConfig(type: "auth-options", title: "Create your account", subtitle: "Choose how you'd like to sign up for Ping")
        }
        if currentStep == 2 {
            return StepConfig(type: "email", title: "What's your email?", subtitle: "We'll use this to create your account and keep you signed in.")
        }
        if currentStep == 3 {
            return StepConfig(type: "password", title: "Create a password", subtitle: "Choose a strong password to keep your account secure.")
        }
        if currentStep == 4 {
            return StepConfig(type: "personal-info", title: "What's your name?", subtitle: "We'd love to know what to call you")
        }
        if currentStep == 5 {
            return StepConfig(type: "personal-info", title: "When's your birthday?", subtitle: "We'll use this to personalize your experience")
        }
        if currentStep == 6 {
            return StepConfig(type: "personal-info", title: "Choose your username", subtitle: "This will be your unique identifier on Ping")
        }
        if currentStep == 7 {
            return StepConfig(
                type: "marketing",
                title: nil,
                subtitle: "Connect with friends and explore the best spots in your city.",
                titlePart1: "Discover amazing places ",
                highlightedText: "together.",
                titlePart2: ""
            )
        }
        if currentStep == 8 {
            return StepConfig(type: "category-selection", title: "What interests you most?", subtitle: "Select the categories that resonate with you")
        }
        
        // Subcategory selection steps
        let subcategoryStepIndex = currentStep - 9
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
        
        // Final step
        return StepConfig(type: "final", title: "You're all set!", subtitle: "Welcome to the Ping community")
    }
    
    func nextStep(appEnvironment: AppEnvironment, onComplete: (() -> Void)? = nil) async {
        if !validateCurrentStep() {
            return
        }

        if currentStep < totalSteps {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                fadeAnim = 0
                slideAnim = 50
                scaleAnim = 0.8
            }

            currentStep += 1

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                fadeAnim = 1
                slideAnim = 0
                scaleAnim = 1
            }
        } else {
            await handleSubmit(appEnvironment: appEnvironment, onComplete: onComplete)
        }
    }
    
    func prevStep() {
        if currentStep > 1 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                fadeAnim = 0
                slideAnim = -50
                scaleAnim = 0.8
            }
            
            currentStep -= 1
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                fadeAnim = 1
                slideAnim = 0
                scaleAnim = 1
            }
        }
    }
    
    func handleEmailSignup() {
        currentStep = 2
    }
    
    func handleGoogleSignup() {
        // TODO: Implement Google OAuth
    }
    
    func handleAppleSignup() {
        // TODO: Implement Apple OAuth
    }
    
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
        case "personal-info":
            if currentStep == 4 && formData.fullName.trimmingCharacters(in: .whitespaces).isEmpty {
                newErrors["fullName"] = "Full name is required"
            }
            if currentStep == 6 {
                if formData.username.trimmingCharacters(in: .whitespaces).isEmpty {
                    newErrors["username"] = "Username is required"
                } else if formData.username.count < 3 {
                    newErrors["username"] = "Username must be at least 3 characters"
                } else if !formData.username.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }) {
                    newErrors["username"] = "Username can only contain letters, numbers, and underscores"
                }
            }
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
            // TODO: Check username availability via Supabase
            // When implemented, this will make the actual API call
            usernameAvailable = true // Placeholder
        }
    }
    
    func handleSubmit(appEnvironment: AppEnvironment, onComplete: (() -> Void)? = nil) async {
        loading = true
        errors["submit"] = nil // Clear previous errors

        print("🔵 Starting signup process...")
        print("📧 Email: \(formData.email)")
        print("🔑 Password length: \(formData.password.count)")

        do {
            // Sign up user
            print("🔵 Calling authService.signup()...")
            let user = try await appEnvironment.authService.signup(
                email: formData.email.trimmingCharacters(in: .whitespaces),
                password: formData.password
            )

            print("✅ Signup successful! User ID: \(user.id)")

            // Update profile
            // TODO: Update profile with formData (birthday, username, categories, etc.)

            // Update app environment
            appEnvironment.currentUser = user
            appEnvironment.isAuthenticated = true

            print("✅ App environment updated, isAuthenticated: \(appEnvironment.isAuthenticated)")

            // Call completion handler to dismiss view
            print("🔵 Calling onComplete() to dismiss view...")
            onComplete?()

        } catch {
            print("❌ Signup failed: \(error.localizedDescription)")
            errors["submit"] = error.localizedDescription
        }

        loading = false
        print("🔵 Loading finished, loading = \(loading)")
    }
}

struct OnboardingFormData {
    var email: String = ""
    var password: String = ""
    var fullName: String = ""
    var birthday: Date = Date()
    var username: String = ""
    var phoneNumber: String = ""
    var profilePicture: String? = nil
    var selectedCategories: [String] = []
    var selectedSubcategories: [String] = []
}

struct StepConfig {
    let type: String
    let title: String?
    let subtitle: String?
    var titlePart1: String? = nil
    var highlightedText: String? = nil
    var titlePart2: String? = nil
    var categoryId: String? = nil
}
