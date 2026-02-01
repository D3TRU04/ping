//
//  SignupViewModel+Auth.swift
//  PingNative
//
//  Authentication logic for email and phone signup
//

import Foundation
import SwiftUI
import Clerk

extension SignupViewModel {

    // MARK: - Email Signup

    func signupWithEmail(appEnvironment: AppEnvironment) async {
        isLoading = true
        errorMessage = nil

        do {
            let signUp = try await SignUp.create(
                strategy: .standard(emailAddress: email, password: password)
            )

            try await signUp.prepareVerification(strategy: .emailCode)

            print("Email OTP sent successfully via Clerk")

            isLoading = false
            await animateForward {
                self.currentStep = .otpInput
                self.progress = 0.9
            }
            startResendCountdown()
        } catch {
            print("Failed to signup via Clerk: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    // MARK: - Phone Signup

    func sendOtpWithClerk(appEnvironment: AppEnvironment) async {
        isLoading = true
        errorMessage = nil

        do {
            let cleanedPhone = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            let formattedPhone = cleanedPhone.hasPrefix("1") ? "+\(cleanedPhone)" : "+1\(cleanedPhone)"
            print("Formatted phone: \(formattedPhone)")

            let signUp = try await SignUp.create(strategy: .standard(
                password: password,
                phoneNumber: formattedPhone
            ))

            try await signUp.prepareVerification(strategy: .phoneCode)

            print("OTP Sent successfully via Clerk (Signup)")

            isLoading = false
            await animateForward {
                self.currentStep = .otpInput
                self.progress = 0.9
            }
            startResendCountdown()
        } catch {
            print("Failed to send OTP via Clerk: \(error.localizedDescription)")
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
                formErrors["phoneNumber"] = error.localizedDescription
            }
        }
    }

}
