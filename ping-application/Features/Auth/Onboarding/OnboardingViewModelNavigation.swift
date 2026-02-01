//
//  OnboardingViewModel+Navigation.swift
//  PingNative
//
//  Navigation methods for onboarding flow
//

import SwiftUI

extension OnboardingViewModel {

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

    func advanceStep() async {
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
}
