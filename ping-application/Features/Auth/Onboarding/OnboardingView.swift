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
            LiquidGlassBackground()
            
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
                            .font(.system(size: 20, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(8)
                    }

                    // Progress bar
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.3))
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
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Step content
                ScrollView {
                    VStack(spacing: 0) {
                        viewModel.currentStepView
                            .padding(.horizontal, 24)
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
                        GlassCTAButton(
                            title: viewModel.currentStep == viewModel.totalSteps ? "Get Started" : "Continue",
                            isLoading: viewModel.loading,
                            isDisabled: !viewModel.canProceed
                        ) {
                            Task {
                                await viewModel.nextStep(appEnvironment: appEnvironment) {
                                    dismiss()
                                }
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: viewModel.canProceed)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .navigationBarHidden(true)
    }
}
