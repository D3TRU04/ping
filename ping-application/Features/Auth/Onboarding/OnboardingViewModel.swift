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
    
    enum SignupMethod {
        case email
        case phone
    }
    @Published var signupMethod: SignupMethod = .email
    
    // Animation state
    @Published var fadeAnim: Double = 1
    @Published var slideAnim: Double = 0
    @Published var scaleAnim: Double = 1
    
    // Dynamic Step Sequence
    var stepSequence: [String] {
        var steps = ["auth-options"]
        
        if signupMethod == .email {
            steps.append("email")
            steps.append("password")
            // steps.append("phone-number") // Removed for email flow
        } else {
            steps.append("phone-number")
        }
        
        steps.append("name")
        steps.append("birthday")
        steps.append("username")
        steps.append("marketing")
        steps.append("category-selection")
        
        // Subcategories are handled dynamically based on selection
        return steps
    }
    
    var totalSteps: Int {
        var baseCount = stepSequence.count
        // Add subcategory steps
        baseCount += selectedCategories.count
        // Add final step
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
            return true // Birthday is always valid
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
                onPhoneSignup: handlePhoneSignup
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
        case "phone-number":
            return AnyView(PhoneNumberStepView(
                phoneNumber: Binding(
                    get: { self.formData.phoneNumber },
                    set: { self.formData.phoneNumber = $0 }
                ),
                errors: errors
            ))
        case "name":
            return AnyView(NameStepView(
                fullName: Binding(
                    get: { self.formData.fullName },
                    set: { self.formData.fullName = $0 }
                ),
                errors: errors
            ))
        case "birthday":
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
        case "username":
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
        // Handle standard steps based on sequence
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
        
        // Subcategory selection steps
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
        
        // Final step
        return StepConfig(type: "final", title: "You're all set!", subtitle: "Welcome to the Ping community")
    }
    
    func nextStep(appEnvironment: AppEnvironment, onComplete: (() -> Void)? = nil) async {
        if !validateCurrentStep() {
            return
        }

        if currentStep < totalSteps {
            await advanceStep()
        } else {
            await handleSubmit(appEnvironment: appEnvironment, onComplete: onComplete)
        }
    }
    
    func prevStep() {
        Task { @MainActor in
            if currentStep > 1 {
                // Animate Out (Slide Right)
                withAnimation(.easeIn(duration: 0.25)) {
                    fadeAnim = 0
                    slideAnim = 50
                    scaleAnim = 0.95
                }
                
                try? await Task.sleep(nanoseconds: 250_000_000) // 0.25s
                
                currentStep -= 1
                
                // Reset for Enter (Slide from Left)
                slideAnim = -50
                scaleAnim = 0.95
                
                // Animate In
                withAnimation(.easeOut(duration: 0.25)) {
                    fadeAnim = 1
                    slideAnim = 0
                    scaleAnim = 1
                }
            }
        }
    }
    
    func handleEmailSignup() {
        signupMethod = .email
        Task { @MainActor in
            await advanceStep()
        }
    }
    
    func handlePhoneSignup() {
        signupMethod = .phone
        Task { @MainActor in
            await advanceStep()
        }
    }
    
    private func advanceStep() async {
        // Animate Out (Slide Left)
        withAnimation(.easeIn(duration: 0.25)) {
            fadeAnim = 0
            slideAnim = -50
            scaleAnim = 0.95
        }
        
        try? await Task.sleep(nanoseconds: 250_000_000) // 0.25s
        
        currentStep += 1
        
        // Reset for Enter (Slide from Right)
        slideAnim = 50
        scaleAnim = 0.95
        
        // Animate In
        withAnimation(.easeOut(duration: 0.25)) {
            fadeAnim = 1
            slideAnim = 0
            scaleAnim = 1
        }
    }
    
    func handleGoogleSignup() {}
    func handleAppleSignup() {}
    
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
            // TODO: Check username availability via Backend (Convex)
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
