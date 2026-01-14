//
//  LoginViewModel.swift
//  PingNative
//
//  Source: ping/apps/src/screens/auth/signin/page.tsx
//  Generated Swift equivalent matching RN behavior
//
//  UPDATED: Now uses Clerk authentication
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
    // Use sendOtpWithClerk() instead
    func sendOtp(appEnvironment: AppEnvironment) async {
        print("⚠️ sendOtp is deprecated - use sendOtpWithClerk instead")
        errorMessage = "Please use Clerk authentication"
        isLoading = false
    }

    // NEW: Clerk phone authentication with OTP
    func sendOtpWithClerk(appEnvironment: AppEnvironment) async {
        print("▶️ sendOtpWithClerk triggered with phone: \(phoneNumber)")
        isLoading = true
        errorMessage = nil

        do {
            // Format phone number to E.164 format (e.g., +17134746641)
            let cleanedPhone = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            let formattedPhone = cleanedPhone.hasPrefix("1") ? "+\(cleanedPhone)" : "+1\(cleanedPhone)"
            print("📞 Formatted phone: \(formattedPhone)")

            // Start Clerk phone sign-in
            let signIn = try await SignIn.create(strategy: .identifier(formattedPhone))

            // Prepare and send OTP
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
    
    // DEPRECATED: Old custom OTP verification (replaced by Clerk)
    // Use verifyOtpWithClerk() instead
    func verifyOtp(appEnvironment: AppEnvironment) async {
        print("⚠️ verifyOtp is deprecated - use verifyOtpWithClerk instead")
        errorMessage = "Please use Clerk authentication"
        isLoading = false
    }

    // NEW: Clerk OTP verification
    func verifyOtpWithClerk(appEnvironment: AppEnvironment) async {
        print("▶️ verifyOtpWithClerk triggered with code: \(otpCode)")
        isLoading = true
        errorMessage = nil

        do {
            // Verify the OTP code with Clerk
            guard let signIn = Clerk.shared.client?.signIn else {
                throw ClerkError.noSignInInProgress
            }

            let verifiedSignIn = try await signIn.attemptFirstFactor(strategy: .phoneCode(code: otpCode))

            if verifiedSignIn.status == .complete {
                print("✅ OTP Verified via Clerk")

                // Get the Clerk user
                guard let clerkUser = Clerk.shared.user else {
                    throw ClerkError.noUser
                }

                // Sync Clerk user to Convex
                let userId: String = try await appEnvironment.convexClient.mutation(
                    function: "users:createOrUpdateFromClerk",
                    args: [
                        "clerkUserId": clerkUser.id,
                        "phoneNumber": phoneNumber,
                        "profileImageUrl": clerkUser.imageUrl
                    ]
                )

                // Fetch the user from Convex
                let user: User = try await appEnvironment.convexClient.query(
                    function: "users:getByClerkId",
                    args: ["clerkUserId": clerkUser.id]
                )

                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appEnvironment.currentUser = user
                        appEnvironment.isAuthenticated = true
                        appEnvironment.needsOnboarding = !(user.hasOnboarded ?? false)
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
    // Use loginWithClerk() instead
    func login(appEnvironment: AppEnvironment) async {
        print("⚠️ login is deprecated - use loginWithClerk instead")
        errorMessage = "Please use Clerk authentication"
        isLoading = false
    }

    // NEW: Clerk email/password authentication
    func loginWithClerk(appEnvironment: AppEnvironment) async {
        isLoading = true
        errorMessage = nil
        emailError = nil

        do {
            // Sign in with Clerk using email and password
            let signIn = try await SignIn.create(strategy: .identifier(email, password: password))

            if signIn.status == .complete {
                print("✅ Logged in successfully via Clerk")

                // Get the Clerk user
                guard let clerkUser = Clerk.shared.user else {
                    throw ClerkError.noUser
                }

                // Sync Clerk user to Convex
                let userId: String = try await appEnvironment.convexClient.mutation(
                    function: "users:createOrUpdateFromClerk",
                    args: [
                        "clerkUserId": clerkUser.id,
                        "email": email,
                        "profileImageUrl": clerkUser.imageUrl
                    ]
                )

                // Fetch the user from Convex
                let user: User = try await appEnvironment.convexClient.query(
                    function: "users:getByClerkId",
                    args: ["clerkUserId": clerkUser.id]
                )

                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appEnvironment.currentUser = user
                        appEnvironment.isAuthenticated = true
                        appEnvironment.needsOnboarding = !(user.hasOnboarded ?? false)
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
            // Match RN error handling - show error message
            print("❌ Failed to login via Clerk: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = error.localizedDescription
                emailError = error.localizedDescription
                isLoading = false
            }
        }
    }
}
