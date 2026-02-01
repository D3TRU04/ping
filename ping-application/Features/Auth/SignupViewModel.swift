//
//  SignupViewModel.swift
//  PingNative
//
//  Core signup view model with state management
//

import Foundation
import SwiftUI
import Combine
import Clerk

@MainActor
class SignupViewModel: ObservableObject {
    enum SignupStep: Equatable {
        case options
        case emailInput
        case passwordInput
        case confirmPassword
        case phoneInput
        case otpInput
    }

    enum SignupMethod {
        case email
        case phone
        case none
    }

    enum SignupError: Error, LocalizedError {
        case noUser
        case noSignUpInProgress

        var errorDescription: String? {
            switch self {
            case .noUser:
                return "No user found after signup."
            case .noSignUpInProgress:
                return "No sign-up in progress."
            }
        }
    }

    // Navigation State
    @Published var currentStep: SignupStep = .options
    @Published var signupMethod: SignupMethod = .none

    // Form Data
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var phoneNumber: String = ""
    @Published var otpCode: String = ""

    // UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var formErrors: [String: String] = [:]

    // Resend OTP State
    @Published var resendCountdown: Int = 0
    @Published var isResending: Bool = false
    var resendTimer: Timer?

    // Animation properties
    @Published var progress: CGFloat = 0.2
    @Published var fadeAnim: Double = 1
    @Published var slideAnim: Double = 0
    @Published var scaleAnim: Double = 1

    var isFormValid: Bool {
        switch currentStep {
        case .options:
            return true
        case .emailInput:
            return !email.isEmpty && email.contains("@")
        case .passwordInput:
            return password.count >= 6
        case .confirmPassword:
            return !confirmPassword.isEmpty && password == confirmPassword
        case .phoneInput:
            return phoneNumber.count >= 10
        case .otpInput:
            return otpCode.count >= 6
        }
    }

    var canResendCode: Bool {
        return resendCountdown == 0 && !isResending
    }
}
