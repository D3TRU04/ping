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

    // Resend OTP State
    @Published var resendCountdown: Int = 0
    @Published var isResending: Bool = false
    private var resendTimer: Timer?
    
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
    
    // MARK: - Navigation
    
    func selectMethod(_ method: SignupMethod) {
        signupMethod = method
        Task {
            await animateForward {
                if method == .email {
                    self.currentStep = .emailInput
                    self.progress = 0.4
                } else {
                    self.currentStep = .phoneInput
                    self.progress = 0.5
                }
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
                await animateForward {
                    self.currentStep = .passwordInput
                    self.progress = 0.6
                }
            } else {
                formErrors["email"] = "Please enter a valid email address"
            }
            
        case .passwordInput:
            if isFormValid {
                await animateForward {
                    self.currentStep = .confirmPassword
                    self.progress = 0.8
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
                await animateForward {
                    self.currentStep = .passwordInput
                    self.progress = 0.6
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
        
        Task {
            switch currentStep {
            case .options:
                break // Can't go back further here, view should dismiss
            case .emailInput:
                await animateBackward {
                    self.currentStep = .options
                    self.signupMethod = .none
                    self.progress = 0.2
                }
            case .passwordInput:
                await animateBackward {
                    if self.signupMethod == .email {
                        self.currentStep = .emailInput
                        self.progress = 0.4
                    } else if self.signupMethod == .phone {
                        self.currentStep = .phoneInput
                        self.progress = 0.5
                    }
                }
            case .confirmPassword:
                await animateBackward {
                    self.currentStep = .passwordInput
                    self.progress = 0.6
                }
            case .phoneInput:
                await animateBackward {
                    self.currentStep = .options
                    self.signupMethod = .none
                    self.progress = 0.2
                }
            case .otpInput:
                await animateBackward {
                    self.currentStep = .confirmPassword
                    self.progress = 0.8
                }
            }
        }
    }

    // MARK: - Animation Helpers
    
    private func animateForward(_ stepChange: @escaping () -> Void) async {
        // Quick fade out
        fadeAnim = 0
        
        // Change step
        stepChange()
        
        // Reset position for enter
        slideAnim = 15
        
        // Animate in smoothly
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            fadeAnim = 1
            slideAnim = 0
        }
    }
    
    private func animateBackward(_ stepChange: @escaping () -> Void) async {
        // Quick fade out
        fadeAnim = 0
        
        // Change step
        stepChange()
        
        // Reset position for enter
        slideAnim = -15
        
        // Animate in smoothly
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            fadeAnim = 1
            slideAnim = 0
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

            // Prepare email verification - this will send the OTP code
            try await signUp.prepareVerification(strategy: .emailCode)

            print("✅ Email OTP sent successfully via Clerk")

            isLoading = false
            await animateForward {
                self.currentStep = .otpInput
                self.progress = 0.9
            }
            startResendCountdown()
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

            isLoading = false
            await animateForward {
                self.currentStep = .otpInput
                self.progress = 0.9
            }
            startResendCountdown()
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

            // Use the appropriate verification strategy based on signup method
            let verifiedSignUp: SignUp
            if signupMethod == .email {
                print("🔍 Verifying email OTP...")
                verifiedSignUp = try await signUp.attemptVerification(strategy: .emailCode(code: otpCode))
            } else {
                print("🔍 Verifying phone OTP...")
                verifiedSignUp = try await signUp.attemptVerification(strategy: .phoneCode(code: otpCode))
            }

            print("📊 Signup status after OTP verification: \(verifiedSignUp.status)")
            print("📋 Missing fields: \(verifiedSignUp.missingFields)")
            print("📋 Unverified fields: \(verifiedSignUp.unverifiedFields)")

            // Check if signup is complete
            if verifiedSignUp.status == .complete {
                print("✅ OTP Verified via Clerk (Signup) - Status: Complete")
                try await handleSuccessfulSignup(appEnvironment: appEnvironment)
            } else if verifiedSignUp.status == .missingRequirements {
                print("⚠️ Signup has missing requirements, checking what's needed...")
                
                // If only missing optional profile fields, we might still be able to proceed
                // Check if there are any unverified fields that need attention
                if verifiedSignUp.unverifiedFields.isEmpty {
                    // No unverified fields, try to see if we can complete anyway
                    // Some Clerk configs allow completing with missing optional fields
                    print("ℹ️ No unverified fields remaining. Missing fields: \(verifiedSignUp.missingFields)")
                    
                    // If a session was created, the signup might actually be usable
                    if Clerk.shared.session != nil {
                        print("✅ Session exists, proceeding with signup completion")
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
                print("⚠️ Signup incomplete after OTP verification - Status: \(verifiedSignUp.status)")
                await MainActor.run {
                    errorMessage = "Verification incomplete. Please ensure your Clerk settings are configured correctly."
                    isLoading = false
                }
            }
        } catch {
            print("❌ Failed to verify OTP via Clerk: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = error.localizedDescription
                formErrors["otp"] = "Invalid verification code. Please try again."
                isLoading = false
            }
        }
    }

    // MARK: - Resend OTP
    
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
    
    var canResendCode: Bool {
        return resendCountdown == 0 && !isResending
    }
    
    func resendCode(appEnvironment: AppEnvironment) async {
        guard canResendCode else { return }
        
        isResending = true
        errorMessage = nil
        
        do {
            guard let signUp = Clerk.shared.client?.signUp else {
                throw SignupError.noSignUpInProgress
            }
            
            // Resend verification code based on signup method
            if signupMethod == .email {
                print("📧 Resending email verification code...")
                try await signUp.prepareVerification(strategy: .emailCode)
            } else {
                print("📱 Resending phone verification code...")
                try await signUp.prepareVerification(strategy: .phoneCode)
            }
            
            print("✅ Verification code resent successfully")
            
            await MainActor.run {
                isResending = false
                startResendCountdown()
            }
        } catch {
            print("❌ Failed to resend code: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "Failed to resend code: \(error.localizedDescription)"
                isResending = false
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
            withAnimation(.easeInOut(duration: 0.5)) {
                appEnvironment.currentUser = user
                appEnvironment.isAuthenticated = true
                appEnvironment.needsOnboarding = !(user.hasOnboarded ?? false)
                isLoading = false
            }
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
