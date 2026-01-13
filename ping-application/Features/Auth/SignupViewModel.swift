//
//  SignupViewModel.swift
//  PingNative
//
//  Refactored to support multi-step signup (Email vs Phone)
//  matching Onboarding flow style.
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

    // Animation properties
    @Published var progress: CGFloat = 0.2
    
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
    
    // MARK: - Navigation
    
    func selectMethod(_ method: SignupMethod) {
        signupMethod = method
        withAnimation {
            if method == .email {
                currentStep = .emailInput
                progress = 0.4
            } else {
                currentStep = .phoneInput
                progress = 0.5
            }
        }
    }
    
    func nextStep(appEnvironment: AppEnvironment? = nil) async {
        errorMessage = nil
        formErrors = [:]
        
        switch currentStep {
        case .options:
            // Handled by selectMethod
            break
            
        case .emailInput:
            if isFormValid {
                withAnimation {
                    currentStep = .passwordInput
                    progress = 0.6
                }
            } else {
                formErrors["email"] = "Please enter a valid email address"
            }
            
        case .passwordInput:
            if isFormValid {
                withAnimation {
                    currentStep = .confirmPassword
                    progress = 0.8
                }
            } else {
                formErrors["password"] = "Password must be at least 6 characters"
            }
            
        case .confirmPassword:
            if isFormValid {
                if let env = appEnvironment {
                    // Check which signup method (email or phone)
                    if signupMethod == .email {
                        await signupWithEmail(appEnvironment: env)
                    } else if signupMethod == .phone {
                        await sendOtpWithClerk(appEnvironment: env)
                    }
                }
            } else {
                formErrors["confirmPassword"] = "Passwords do not match"
            }
            
        case .phoneInput:
            if isFormValid {
                withAnimation {
                    currentStep = .passwordInput
                    progress = 0.6
                }
            } else {
                formErrors["phoneNumber"] = "Please enter a valid phone number"
            }
            
        case .otpInput:
             if isFormValid {
                 if let env = appEnvironment {
                     await verifyOtpWithClerk(appEnvironment: env)
                 }
             } else {
                 formErrors["otp"] = "Please enter the 6-digit code"
             }
        }
    }
    
    func prevStep() {
        errorMessage = nil
        formErrors = [:]
        
        withAnimation {
            switch currentStep {
            case .options:
                break // Can't go back further here, view should dismiss
            case .emailInput:
                currentStep = .options
                signupMethod = .none
                progress = 0.2
            case .passwordInput:
                if signupMethod == .email {
                    currentStep = .emailInput
                    progress = 0.4
                } else if signupMethod == .phone {
                    currentStep = .phoneInput
                    progress = 0.5
                }
            case .confirmPassword:
                currentStep = .passwordInput
                progress = 0.6
            case .phoneInput:
                currentStep = .options
                signupMethod = .none
                progress = 0.2
            case .otpInput:
                currentStep = .phoneInput
                progress = 0.5
            }
        }
    }

    // MARK: - Email Signup

    func signupWithEmail(appEnvironment: AppEnvironment) async {
        isLoading = true
        errorMessage = nil

        do {
            // Sign up with Clerk using email and password
            let signUp = try await SignUp.create(
                strategy: .standard(emailAddress: email, password: password)
            )

            // Check if signup is complete (no verification needed)
            if signUp.status == .complete {
                print("✅ Signed up successfully via Clerk (Email)")
                try await handleSuccessfulSignup(appEnvironment: appEnvironment)
            } else {
                // If verification is required, handle it
                print("⚠️ Signup requires verification: \(signUp.status)")
                await MainActor.run {
                    errorMessage = "Please check your email for verification."
                    isLoading = false
                }
            }
        } catch {
            print("❌ Failed to signup via Clerk: \(error.localizedDescription)")
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
            // Format phone number to E.164 format
            let cleanedPhone = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            let formattedPhone = cleanedPhone.hasPrefix("1") ? "+\(cleanedPhone)" : "+1\(cleanedPhone)"
            print("📞 Formatted phone: \(formattedPhone)")

            // Start Clerk phone sign-up with password
            let signUp = try await SignUp.create(strategy: .standard(
                password: password,
                phoneNumber: formattedPhone
            ))

            // Prepare phone verification
            try await signUp.prepareVerification(strategy: .phoneCode)

            print("✅ OTP Sent successfully via Clerk (Signup)")

            await MainActor.run {
                withAnimation {
                    isLoading = false
                    currentStep = .otpInput
                    progress = 0.9
                }
            }
        } catch {
            print("❌ Failed to send OTP via Clerk: \(error.localizedDescription)")
            // If user already exists, it might fail. We might want to suggest logging in.
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
                formErrors["phoneNumber"] = error.localizedDescription
            }
        }
    }
    
    func verifyOtpWithClerk(appEnvironment: AppEnvironment) async {
        isLoading = true
        errorMessage = nil

        do {
            guard let signUp = Clerk.shared.client?.signUp else {
                throw SignupError.noSignUpInProgress
            }

            let verifiedSignUp = try await signUp.attemptVerification(strategy: .phoneCode(code: otpCode))

            print("📊 Signup status after OTP verification: \(verifiedSignUp.status)")
            print("📊 Missing fields: \(verifiedSignUp.missingFields)")
            print("📊 Unverified fields: \(verifiedSignUp.unverifiedFields)")

            // Check various completion states
            if verifiedSignUp.status == .complete {
                print("✅ OTP Verified via Clerk (Signup) - Status: Complete")
                try await handleSuccessfulSignup(appEnvironment: appEnvironment)
            } else if verifiedSignUp.status == .missingRequirements {
                print("⚠️ Signup missing requirements after OTP verification")

                let missingFields = verifiedSignUp.missingFields
                print("❌ Missing fields: \(missingFields)")

                await MainActor.run {
                    errorMessage = """
                    Phone signup requires email in your Clerk settings.

                    To fix:
                    1. Go to Clerk Dashboard → User & Authentication
                    2. Make email OPTIONAL (not required)
                    3. Try signing up again
                    """
                    isLoading = false
                }
            } else {
                print("❌ OTP Verification incomplete - Status: \(verifiedSignUp.status)")
                await MainActor.run {
                    errorMessage = "Verification incomplete (Status: \(verifiedSignUp.status)). Please try again."
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

    // MARK: - Helpers
    
    private func handleSuccessfulSignup(appEnvironment: AppEnvironment) async throws {
        // Reload Clerk session to ensure user is available
        print("🔄 Reloading Clerk session...")
        try? await Clerk.shared.load()

        // Get the Clerk user
        guard let clerkUser = Clerk.shared.user else {
            print("❌ No Clerk user found after signup")
            throw SignupError.noUser
        }

        print("✅ Clerk user found: \(clerkUser.id)")

        // Format phone number for Convex storage
        let cleanedPhone = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let formattedPhone = cleanedPhone.isEmpty ? nil : (cleanedPhone.hasPrefix("1") ? "+\(cleanedPhone)" : "+1\(cleanedPhone)")

        // Get email from Clerk user (might be generated from phone) or from form
        let userEmail = clerkUser.emailAddresses.first?.emailAddress ?? email

        // Sync Clerk user to Convex
        // Note: passing both email and phone if available, though one will be empty/nil usually
        let args: [String: Any] = [
            "clerkUserId": clerkUser.id,
            "email": userEmail.isEmpty ? nil : userEmail,
            "phoneNumber": formattedPhone,
            "profileImageUrl": clerkUser.imageUrl
        ].compactMapValues { $0 }

        print("📤 Syncing user to Convex with args: \(args)")

        let _: String = try await appEnvironment.convexClient.mutation(
            function: "users:createOrUpdateFromClerk",
            args: args
        )

        // Fetch the user from Convex
        let user: User = try await appEnvironment.convexClient.query(
            function: "users:getByClerkId",
            args: ["clerkUserId": clerkUser.id]
        )

        print("✅ User fetched from Convex: \(user.id)")

        await MainActor.run {
            appEnvironment.currentUser = user
            appEnvironment.isAuthenticated = true
            appEnvironment.needsOnboarding = !(user.hasOnboarded ?? false)
            isLoading = false
        }
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
}
