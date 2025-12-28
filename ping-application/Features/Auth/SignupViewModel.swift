//
//  SignupViewModel.swift
//  PingNative
//
//  Created on 12/3/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SignupViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    func signup(appEnvironment: AppEnvironment) async {
        isLoading = true
        errorMessage = nil
        
        // Validate passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            isLoading = false
            return
        }
        
        // Validate password length
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        do {
            let user = try await appEnvironment.authService.signup(
                email: email,
                password: password
            )
            
            // Update app environment
            appEnvironment.currentUser = user
            appEnvironment.isAuthenticated = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
