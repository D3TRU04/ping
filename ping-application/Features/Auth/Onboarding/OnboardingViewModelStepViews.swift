//
//  OnboardingViewModel+StepViews.swift
//  PingNative
//
//  Step view generation and configuration for onboarding
//

import SwiftUI

extension OnboardingViewModel {

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
}
