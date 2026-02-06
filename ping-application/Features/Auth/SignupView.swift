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
            LiquidGlassBackground()
            
            VStack(spacing: 0) {
                // Header with back button and progress bar
                HStack(spacing: 24) {
                    Button(action: {
                        if viewModel.currentStep == .options {
                            dismiss()
                        } else {
                            viewModel.prevStep()
                        }
                    }) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 20, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(8)
                    }

                    // Progress bar (Hidden on options step if desired, but OnboardingView shows it)
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 6)

                        GeometryReader { geometry in
                            Capsule()
                                .fill(Color(hex: "1FC9C3"))
                                .frame(width: geometry.size.width * viewModel.progress)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.progress)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Step Content
                ScrollView {
                    VStack(spacing: 0) {
                        currentStepView
                            .padding(.horizontal, 24)
                            .padding(.vertical, 24)
                            .opacity(viewModel.fadeAnim)
                            .offset(x: viewModel.slideAnim)
                            .scaleEffect(viewModel.scaleAnim)
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.currentStep)
                
                // Bottom navigation button (Hidden on Options step)
                if viewModel.currentStep != .options {
                    VStack {
                        // Error Message Display
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(AppColors.error)
                                .padding(.bottom, 8)
                                .multilineTextAlignment(.center)
                        }

                        GlassCTAButton(
                            title: buttonText,
                            isLoading: viewModel.isLoading
                        ) {
                            Task {
                                await viewModel.nextStep(appEnvironment: appEnvironment)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private var currentStepView: some View {
        switch viewModel.currentStep {
        case .options:
            AuthOptionsStepView(
                onEmailSignup: {
                    viewModel.selectMethod(.email)
                },
                onPhoneSignup: {
                    viewModel.selectMethod(.phone)
                }
            )
            
        case .emailInput:
            EmailStepView(
                email: $viewModel.email,
                errors: viewModel.formErrors
            )
            
        case .passwordInput:
            PasswordStepView(
                password: $viewModel.password,
                errors: viewModel.formErrors
            )
            
        case .confirmPassword:
            ConfirmPasswordStepView(
                password: $viewModel.confirmPassword,
                errors: viewModel.formErrors
            )
            
        case .phoneInput:
            PhoneNumberStepView(
                phoneNumber: $viewModel.phoneNumber,
                errors: viewModel.formErrors
            )
            
        case .otpInput:
            OtpStepView(
                otpCode: $viewModel.otpCode,
                destination: viewModel.signupMethod == .email ? viewModel.email : viewModel.phoneNumber,
                errors: viewModel.formErrors,
                resendCountdown: viewModel.resendCountdown,
                isResending: viewModel.isResending,
                onResendCode: {
                    Task {
                        await viewModel.resendCode(appEnvironment: appEnvironment)
                    }
                }
            )
        }
    }
    
    private var buttonText: String {
        switch viewModel.currentStep {
        case .confirmPassword, .otpInput:
            return "Create Account"
        default:
            return "Continue"
        }
    }
}
