//
//  LoginViewModel.swift
//  PingNative
//
//  ViewModel for login flow
//
//  Related files:
//  - LoginViewModel+Clerk.swift - Clerk authentication methods
//

import Foundation
import SwiftUI
import Combine
import Clerk

@MainActor
class LoginViewModel: ObservableObject {
    enum LoginStep {
        case input
        case otp
    }

    @Published var step: LoginStep = .input
    @Published var phoneNumber: String = ""
    @Published var otpCode: String = ""

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var emailError: String?

    init() {
        print("🏗️ LoginViewModel Initialized")
    }

    // DEPRECATED: Old custom OTP flow (replaced by Clerk)
    func sendOtp(appEnvironment: AppEnvironment) async {
        print("⚠️ sendOtp is deprecated - use sendOtpWithClerk instead")
        errorMessage = "Please use Clerk authentication"
        isLoading = false
    }

    // DEPRECATED: Old custom OTP verification (replaced by Clerk)
    func verifyOtp(appEnvironment: AppEnvironment) async {
        print("⚠️ verifyOtp is deprecated - use verifyOtpWithClerk instead")
        errorMessage = "Please use Clerk authentication"
        isLoading = false
    }

    enum ClerkError: Error, LocalizedError {
        case noSignInInProgress
        case noUser

        var errorDescription: String? {
            switch self {
            case .noSignInInProgress:
                return "No sign-in in progress. Please request OTP first."
            case .noUser:
                return "No user found after authentication."
            }
        }
    }

    // DEPRECATED: Old custom login (replaced by Clerk)
    func login(appEnvironment: AppEnvironment) async {
        print("⚠️ login is deprecated - use loginWithClerk instead")
        errorMessage = "Please use Clerk authentication"
        isLoading = false
    }
}
