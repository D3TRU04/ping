//
//  LoginView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/auth/signin/page.tsx
//  Generated Swift equivalent matching RN design
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = LoginViewModel()
    @Binding var showingLogin: Bool
    
    var body: some View {
        ZStack {
            // Background color matching RN: #1FC9C3
            Color(hex: "1FC9C3")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Back button
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.backward")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.08))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 24)
                        .padding(.top, 48)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Logo
                    Text("PING")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(.white)
                        .padding(.bottom, 12)
                    
                    // Email error message
                    if let emailError = viewModel.emailError {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Color(hex: "DC2626"))
                                .font(.system(size: 18))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(emailError)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "DC2626"))
                                
                                Button(action: {
                                    showingLogin = false
                                }) {
                                    Text("Go to Sign In →")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(hex: "DC2626"))
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.emailError = nil
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color(hex: "DC2626"))
                                    .font(.system(size: 18))
                            }
                        }
                        .padding()
                        .background(Color(hex: "FEE2E2"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "DC2626"), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    
                    VStack(spacing: 16) {
                        // Email field
                        HStack(spacing: 10) {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                                .font(.system(size: 20))
                            
                            TextField("Email", text: $viewModel.email)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "2D3436"))
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        
                        // Password field
                        HStack(spacing: 10) {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                                .font(.system(size: 20))
                            
                            SecureField("Password", text: $viewModel.password)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "2D3436"))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button(action: {
                                // TODO: Implement forgot password flow
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Sign In Button
                        Button(action: {
                            Task {
                                await viewModel.login(appEnvironment: appEnvironment)
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1FC9C3")))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            } else {
                                Text("Sign In")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "1FC9C3"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.25), radius: 3.84, x: 0, y: 2)
                        .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    
                    // Sign up link
                    HStack {
                        Text("Don't have an account? ")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        NavigationLink(value: NavigationDestination.signUp) {
                            Text("Create an account")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 32)
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
    }
}
