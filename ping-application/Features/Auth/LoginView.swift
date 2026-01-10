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
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Back button
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.backward")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.textPrimary)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                        .padding(.leading, 24)
                        .padding(.top, 48)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    .frame(height: 60)
                    
                    // Logo
                    Text("PING")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.bottom, 12)
                    
                    // Email error message
                    if let emailError = viewModel.emailError {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(AppColors.error)
                                .font(.system(size: 18))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(emailError)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.error)
                                
                                Button(action: {
                                    showingLogin = false
                                }) {
                                    Text("Go to Sign In →")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppColors.error)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.emailError = nil
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(AppColors.error)
                                    .font(.system(size: 18))
                            }
                        }
                        .padding()
                        .background(AppColors.error.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.error, lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                    
                    VStack(spacing: 20) {
                        // Email field
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.system(size: 20))
                            
                            TextField("Email", text: $viewModel.email)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        .padding()
                        .background(Color(hex: "F3F4F6"))
                        .cornerRadius(16)
                        
                        // Password field
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.system(size: 20))
                            
                            SecureField("Password", text: $viewModel.password)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        .padding()
                        .background(Color(hex: "F3F4F6"))
                        .cornerRadius(16)
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button(action: {
                                // TODO: Implement forgot password flow
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        
                        // Sign In Button
                        Button(action: {
                            Task {
                                await viewModel.login(appEnvironment: appEnvironment)
                            }
                        }) {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign In")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primaryAction)
                            .clipShape(Capsule())
                        }
                        .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
                        .opacity((viewModel.email.isEmpty || viewModel.password.isEmpty) ? 0.6 : 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    
                    // Sign up link
                    HStack {
                        Text("Don't have an account? ")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                        
                        NavigationLink(value: NavigationDestination.signUp) {
                            Text("Create an account")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
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
