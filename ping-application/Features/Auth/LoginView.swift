//
//  LoginView.swift
//  PingNative
//
//  Login view for user authentication
//
//  Related files:
//  - LoginErrorView.swift - Error message component
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
                    
                    if let emailError = viewModel.emailError {
                        LoginErrorView(
                            errorMessage: emailError,
                            onDismiss: { viewModel.emailError = nil },
                            onSignIn: { showingLogin = false }
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                    
                    VStack(spacing: 20) {
                        if viewModel.step == .input {
                            // Phone Number field
                            HStack(spacing: 12) {
                                Image(systemName: "phone")
                                    .foregroundColor(AppColors.textSecondary)
                                    .font(.system(size: 20))
                                
                                TextField("Phone Number", text: $viewModel.phoneNumber)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textPrimary)
                                    .keyboardType(.phonePad)
                            }
                            .padding()
                            .background(Color(hex: "F3F4F6"))
                            .cornerRadius(16)
                            
                            // Continue Button
                            PrimaryButton(
                                title: "Continue",
                                action: {
                                    print("🔘 UI: Continue Button Tapped")
                                    Task {
                                        print("⚡️ UI: Calling viewModel.sendOtpWithClerk()")
                                        await viewModel.sendOtpWithClerk(appEnvironment: appEnvironment)
                                    }
                                },
                                isLoading: viewModel.isLoading,
                                isDisabled: false // Debug: Force enabled
                            )

                            // Debug Fallback Button
                            Button("Debug Continue") {
                                print("🔘 UI: Debug Button Tapped")
                                Task {
                                    await viewModel.sendOtpWithClerk(appEnvironment: appEnvironment)
                                }
                            }
                            .padding()
                        } else {
                            // OTP Step
                            VStack(spacing: 8) {
                                Text("OTP")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("Code sent to \(viewModel.phoneNumber)")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.bottom, 10)
                            
                            // OTP field
                            HStack(spacing: 12) {
                                Image(systemName: "lock.shield")
                                    .foregroundColor(AppColors.textSecondary)
                                    .font(.system(size: 20))
                                
                                TextField("6-digit code", text: $viewModel.otpCode)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textPrimary)
                                    .keyboardType(.numberPad)
                                    .onChange(of: viewModel.otpCode) { newValue in
                                        if newValue.count > 6 {
                                            viewModel.otpCode = String(newValue.prefix(6))
                                        }
                                    }
                            }
                            .padding()
                            .background(Color(hex: "F3F4F6"))
                            .cornerRadius(16)
                            
                            // Verify Button
                            PrimaryButton(
                                title: "Verify",
                                action: {
                                    Task {
                                        await viewModel.verifyOtpWithClerk(appEnvironment: appEnvironment)
                                    }
                                },
                                isLoading: viewModel.isLoading,
                                isDisabled: viewModel.otpCode.count != 6
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.step)
                    
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
