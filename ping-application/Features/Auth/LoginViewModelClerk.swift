//
//  LoginViewModel+Clerk.swift
//  PingNative
//
//  Clerk authentication methods for login
//

import Foundation
import SwiftUI
import Clerk

extension LoginViewModel {

    // Clerk phone authentication with OTP
    func sendOtpWithClerk(appEnvironment: AppEnvironment) async {
        print("▶️ sendOtpWithClerk triggered with phone: \(phoneNumber)")
        isLoading = true
        errorMessage = nil

        do {
            let cleanedPhone = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            let formattedPhone = cleanedPhone.hasPrefix("1") ? "+\(cleanedPhone)" : "+1\(cleanedPhone)"
            print("📞 Formatted phone: \(formattedPhone)")

            let signIn = try await SignIn.create(strategy: .identifier(formattedPhone))
            try await signIn.prepareFirstFactor(strategy: .phoneCode())

            print("✅ OTP Sent successfully via Clerk")

            await MainActor.run {
                withAnimation {
                    isLoading = false
                    step = .otp
                }
            }
        } catch {
            print("❌ Failed to send OTP via Clerk: \(error.localizedDescription)")
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    // Clerk OTP verification
    func verifyOtpWithClerk(appEnvironment: AppEnvironment) async {
        print("▶️ verifyOtpWithClerk triggered with code: \(otpCode)")
        isLoading = true
        errorMessage = nil

        do {
            guard let signIn = Clerk.shared.client?.signIn else {
                throw ClerkError.noSignInInProgress
            }

            let verifiedSignIn = try await signIn.attemptFirstFactor(strategy: .phoneCode(code: otpCode))

            if verifiedSignIn.status == .complete {
                print("✅ OTP Verified via Clerk")

                guard let clerkUser = Clerk.shared.user else {
                    throw ClerkError.noUser
                }

                let supabaseUser = try await appEnvironment.userService.createOrUpdateFromClerk(
                    clerkUserId: clerkUser.id,
                    email: nil,
                    phoneNumber: phoneNumber,
                    profileImageUrl: clerkUser.imageUrl
                )

                let user = supabaseUser.toUser()

                // Login flow: never show onboarding (user already has an account)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appEnvironment.currentUser = user
                        appEnvironment.isAuthenticated = true
                        appEnvironment.needsOnboarding = false
                        isLoading = false
                    }
                }
            } else {
                print("❌ OTP Verification incomplete")
                await MainActor.run {
                    errorMessage = "Verification incomplete. Please try again."
                    isLoading = false
                }
            }
        } catch {
            print("❌ Failed to verify OTP via Clerk: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    // Clerk email/password authentication
    func loginWithClerk(appEnvironment: AppEnvironment) async {
        isLoading = true
        errorMessage = nil
        emailError = nil

        do {
            let signIn = try await SignIn.create(strategy: .identifier(email, password: password))

            if signIn.status == .complete {
                print("✅ Logged in successfully via Clerk")

                guard let clerkUser = Clerk.shared.user else {
                    throw ClerkError.noUser
                }

                let supabaseUser = try await appEnvironment.userService.createOrUpdateFromClerk(
                    clerkUserId: clerkUser.id,
                    email: email,
                    phoneNumber: nil,
                    profileImageUrl: clerkUser.imageUrl
                )

                let user = supabaseUser.toUser()

                // Login flow: never show onboarding (user already has an account)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appEnvironment.currentUser = user
                        appEnvironment.isAuthenticated = true
                        appEnvironment.needsOnboarding = false
                        isLoading = false
                    }
                }
            } else {
                print("❌ Login incomplete")
                await MainActor.run {
                    errorMessage = "Login incomplete. Please try again."
                    emailError = errorMessage
                    isLoading = false
                }
            }
        } catch {
            print("❌ Failed to login via Clerk: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = error.localizedDescription
                emailError = error.localizedDescription
                isLoading = false
            }
        }
    }
}
