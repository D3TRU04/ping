//
//  StartupView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/core/startup/page.tsx
//  Generated Swift equivalent
//

import SwiftUI

struct StartupView: View {
    @State private var showLoginModal = false
    @State private var loginDetent: PresentationDetent = .medium
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background color matching RN: #1FC9C3
            Color(hex: "1FC9C3")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Logo
                Text("PING")
                    .font(.system(size: 100, weight: .black))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                
                Spacer()
                
                // Main Buttons Container
                VStack(spacing: 16) {
                    // Get Started Button
                    NavigationLink(value: NavigationDestination.onboarding) {
                        Text("Get Started")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "1FC9C3"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 32)
                    
                    // Login Text
                    Button(action: {
                        showLoginModal = true
                    }) {
                        Text("Already have an account? Log in")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 32)
                }
                
                // Privacy Policy Text
                Text("By tapping 'Get Started', you agree to our Privacy Policy and Terms of Service.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showLoginModal) {
            NavigationStack {
                LoginModalView(showLoginModal: $showLoginModal)
                    .onAppear { loginDetent = .medium }
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        switch destination {
                        case .signIn:
                            LoginView(showingLogin: .constant(true))
                                .onAppear { loginDetent = .large }
                        case .signUp:
                            SignupView(showingLogin: .constant(false))
                                .onAppear { loginDetent = .large }
                        case .onboarding:
                            OnboardingView()
                        }
                    }
            }
            .presentationDetents([.medium, .large], selection: $loginDetent)
            .presentationDragIndicator(.visible)
        }
    }
}

struct LoginModalView: View {
    @Binding var showLoginModal: Bool
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Sign In")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    showLoginModal = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .padding(8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
            
            // Login Options
            VStack(spacing: 16) {
                // Apple Sign In
                Button(action: {
                    // Handle Apple sign in
                    showLoginModal = false
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "applelogo")
                            .font(.system(size: 20))
                            .foregroundColor(.white)

                        Text("Sign in with Apple")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .cornerRadius(24)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Google Sign In
                Button(action: {
                    // Handle Google sign in
                    showLoginModal = false
                }) {
                    HStack(spacing: 12) {
                        // Google icon placeholder - use SF Symbols or custom icon
                        Image(systemName: "globe")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "4285F4"))

                        Text("Sign in with Google")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                    )
                    .cornerRadius(24)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Email Sign In
                NavigationLink(value: NavigationDestination.signIn) {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)

                        Text("Continue with email")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "1FC9C3"))
                    .cornerRadius(24)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // Terms
            VStack(spacing: 4) {
                (Text("By continuing you agree to Ping's ")
                    .font(.system(size: 14))
                    .foregroundColor(.gray) +
                 Text("Terms and Conditions")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "1FC9C3"))
                    .underline() +
                 Text(" and ")
                    .font(.system(size: 14))
                    .foregroundColor(.gray) +
                 Text("Privacy Policy")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "1FC9C3"))
                    .underline())
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .interactiveDismissDisabled(false)
        .navigationBarHidden(true)
    }
}
