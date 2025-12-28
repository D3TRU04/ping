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
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var emailError: String?
    
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
