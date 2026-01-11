//
//  LoginViewModel.swift
//  PingNative
//
//  Source: ping/apps/src/screens/auth/signin/page.tsx
//  Generated Swift equivalent matching RN behavior
//

import Foundation
import SwiftUI
import Combine

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
    
    func sendOtp(appEnvironment: AppEnvironment) async {
        print("▶️ sendOtp triggered with phone: \(phoneNumber)")
        isLoading = true
        errorMessage = nil
        
        do {
            // Call backend to send OTP
            // Assumes phone number format is correct (e.g. +1...)
            let _ = try await appEnvironment.authService.sendOtp(
                destination: phoneNumber,
                type: .phone
            )
            
            print("✅ OTP Sent successfully")
            
            await MainActor.run {
                withAnimation {
                    isLoading = false
                    step = .otp
                }
            }
        } catch {
            print("❌ Failed to send OTP: \(error.localizedDescription)")
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func verifyOtp(appEnvironment: AppEnvironment) async {
        print("▶️ verifyOtp triggered with code: \(otpCode)")
        isLoading = true
        errorMessage = nil
        
        do {
            // Call backend to verify OTP
            let isVerified = try await appEnvironment.authService.verifyOtp(
                destination: phoneNumber,
                code: otpCode
            )
            
            if isVerified {
                print("✅ OTP Verified")
                
                // TODO: Handle session token if returned by backend (currently verifyOtp returns Bool)
                // If this is a login flow, we need the token.
                // For now, assuming successful verification implies we can proceed (or mock login for demo)
                
                await MainActor.run {
                    appEnvironment.isAuthenticated = true
                    isLoading = false
                }
            } else {
                print("❌ OTP Verification failed (invalid code)")
                await MainActor.run {
                    errorMessage = "Invalid code. Please try again."
                    isLoading = false
                }
            }
        } catch {
            print("❌ Failed to verify OTP: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func login(appEnvironment: AppEnvironment) async {
        isLoading = true
        errorMessage = nil
        emailError = nil
        
        do {
            let user = try await appEnvironment.authService.login(
                email: email,
                password: password
            )
            
            // Update app environment
            appEnvironment.currentUser = user
            appEnvironment.isAuthenticated = true
            
        } catch {
            // Match RN error handling - show error message
            errorMessage = error.localizedDescription
            emailError = error.localizedDescription
        }
        
        isLoading = false
    }
}
