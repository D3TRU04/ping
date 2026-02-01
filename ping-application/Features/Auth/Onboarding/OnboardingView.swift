//
//  OnboardingView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/auth/onboarding/page.tsx
//  Complete multi-step onboarding flow matching RN implementation
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and progress bar
                HStack(spacing: 24) {
                    Button(action: {
                        if viewModel.currentStep > 1 {
                            viewModel.prevStep()
                        } else {
                            // On step 1, sign out and go back to Get Started
                            Task {
                                await appEnvironment.logout()
                            }
                        }
                    }) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(8)
                    }

                    // Progress bar
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "F3F4F6"))
                            .frame(height: 6)

                        GeometryReader { geometry in
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * viewModel.progress)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.progress)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)
                
                // Step content
                ScrollView {
                    VStack(spacing: 0) {
                        viewModel.currentStepView
                            .padding(.horizontal, 32)
                            .padding(.vertical, 24)
                            .opacity(viewModel.fadeAnim)
                            .offset(x: viewModel.slideAnim)
                            .scaleEffect(viewModel.scaleAnim)
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.currentStep)
                
                // Bottom navigation button
                if viewModel.showContinueButton {
                    VStack {
                        Button(action: {
                            Task {
                                await viewModel.nextStep(appEnvironment: appEnvironment) {
                                    dismiss()
                                }
                            }
                        }) {
                            if viewModel.loading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                            } else {
                                Text(viewModel.currentStep == viewModel.totalSteps ? "Get Started" : "Continue")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                            }
                        }
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: "1FC9C3"), lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
                        .disabled(viewModel.loading || !viewModel.canProceed)
                        .opacity(viewModel.canProceed ? 1.0 : 0.6)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.canProceed)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .navigationBarHidden(true)
    }
}
