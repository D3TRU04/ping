//
//  SignupView.swift
//  PingNative
//
//  Created on 12/3/25.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SignupViewModel()
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
                    .frame(height: 40)
                    
                    // Logo/Title
                    VStack(spacing: 12) {
                        Text("PING")
                            .font(.system(size: 48, weight: .black))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Create your account")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.bottom, 40)
                    
                    VStack(spacing: 20) {
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
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
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
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
                        }
                        
                        // Confirm Password field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.shield")
                                    .foregroundColor(AppColors.textSecondary)
                                    .font(.system(size: 20))
                                
                                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppColors.textPrimary)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                            .padding()
                            .background(Color(hex: "F3F4F6"))
                            .cornerRadius(16)
                        }
                        
                        // Error message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.error)
                                .padding(.horizontal)
                        }
                        
                        // Sign up button
                        Button(action: {
                            Task {
                                await viewModel.signup(appEnvironment: appEnvironment)
                            }
                        }) {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Create Account")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primaryAction)
                            .clipShape(Capsule())
                        }
                        .disabled(viewModel.isLoading || !viewModel.isFormValid)
                        .opacity(!viewModel.isFormValid ? 0.6 : 1)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    
                    // Login link
                    HStack {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                        Button("Log In") {
                            dismiss()
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.bottom, 32)
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
    }
}
