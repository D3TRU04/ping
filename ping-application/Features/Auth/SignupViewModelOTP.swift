//
//  SignupViewModel+OTP.swift
//  PingNative
//
//  OTP verification and resend logic for signup
//

import Foundation
import SwiftUI
import Clerk

extension SignupViewModel {

    func verifyOtpWithClerk(appEnvironment: AppEnvironment) async {
        isLoading = true
        errorMessage = nil

        do {
            guard let signUp = Clerk.shared.client?.signUp else {
                throw SignupError.noSignUpInProgress
            }

            let verifiedSignUp: SignUp
            if signupMethod == .email {
                print("Verifying email OTP...")
                verifiedSignUp = try await signUp.attemptVerification(strategy: .emailCode(code: otpCode))
            } else {
                print("Verifying phone OTP...")
                verifiedSignUp = try await signUp.attemptVerification(strategy: .phoneCode(code: otpCode))
            }

            print("Signup status after OTP verification: \(verifiedSignUp.status)")

            if verifiedSignUp.status == .complete {
                print("OTP Verified via Clerk (Signup) - Status: Complete")
                try await handleSuccessfulSignup(appEnvironment: appEnvironment)
            } else if verifiedSignUp.status == .missingRequirements {
                print("Signup has missing requirements, checking what's needed...")

                if verifiedSignUp.unverifiedFields.isEmpty {
                    print("No unverified fields remaining. Missing fields: \(verifiedSignUp.missingFields)")

                    if Clerk.shared.session != nil {
                        print("Session exists, proceeding with signup completion")
                        try await handleSuccessfulSignup(appEnvironment: appEnvironment)
                    } else {
                        await MainActor.run {
                            errorMessage = "Additional information required. Missing: \(verifiedSignUp.missingFields.joined(separator: ", "))"
                            isLoading = false
                        }
                    }
                } else {
                    await MainActor.run {
                        errorMessage = "Please verify: \(verifiedSignUp.unverifiedFields.joined(separator: ", "))"
                        isLoading = false
                    }
                }
            } else {
                print("Signup incomplete after OTP verification - Status: \(verifiedSignUp.status)")
                await MainActor.run {
                    errorMessage = "Verification incomplete. Please ensure your Clerk settings are configured correctly."
                    isLoading = false
                }
            }
        } catch {
            print("Failed to verify OTP via Clerk: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = error.localizedDescription
                formErrors["otp"] = "Invalid verification code. Please try again."
                isLoading = false
            }
        }
    }

    func startResendCountdown() {
        resendCountdown = 20
        resendTimer?.invalidate()
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                if self.resendCountdown > 0 {
                    self.resendCountdown -= 1
                } else {
                    timer.invalidate()
                }
            }
        }
    }

    func resendCode(appEnvironment: AppEnvironment) async {
        guard canResendCode else { return }

        isResending = true
        errorMessage = nil

        do {
            guard let signUp = Clerk.shared.client?.signUp else {
                throw SignupError.noSignUpInProgress
            }

            if signupMethod == .email {
                print("Resending email verification code...")
                try await signUp.prepareVerification(strategy: .emailCode)
            } else {
                print("Resending phone verification code...")
                try await signUp.prepareVerification(strategy: .phoneCode)
            }

            print("Verification code resent successfully")

            await MainActor.run {
                isResending = false
                startResendCountdown()
            }
        } catch {
            print("Failed to resend code: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "Failed to resend code: \(error.localizedDescription)"
                isResending = false
            }
        }
    }

    func handleSuccessfulSignup(appEnvironment: AppEnvironment) async throws {
        print("Reloading Clerk session...")
        try? await Clerk.shared.load()

        guard let clerkUser = Clerk.shared.user else {
            print("No Clerk user found after signup")
            throw SignupError.noUser
        }

        print("Clerk user found: \(clerkUser.id)")

        let cleanedPhone = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let formattedPhone = cleanedPhone.isEmpty ? nil : (cleanedPhone.hasPrefix("1") ? "+\(cleanedPhone)" : "+1\(cleanedPhone)")

        let userEmail = clerkUser.emailAddresses.first?.emailAddress ?? email

        print("Syncing user to Supabase")

        let supabaseUser = try await appEnvironment.userService.createOrUpdateFromClerk(
            clerkUserId: clerkUser.id,
            email: userEmail.isEmpty ? nil : userEmail,
            phoneNumber: formattedPhone,
            profileImageUrl: clerkUser.imageUrl
        )

        let user = supabaseUser.toUser()

        print("User fetched from Supabase: \(user.id)")

        // Signup flow: always show onboarding for new accounts
        // Check if user has already completed onboarding (edge case: re-signup with existing account)
        let alreadyOnboarded = (user.hasOnboarded ?? false) || (user.fullName != nil && !user.fullName!.isEmpty)

        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.5)) {
                appEnvironment.currentUser = user
                appEnvironment.isAuthenticated = true
                appEnvironment.needsOnboarding = !alreadyOnboarded
                isLoading = false
            }
        }
    }
}
