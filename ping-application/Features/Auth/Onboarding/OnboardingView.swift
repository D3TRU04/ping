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
            // Background color matching RN: #1FC9C3
            Color(hex: "1FC9C3")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and progress bar
                HStack {
                    Button(action: {
                        if viewModel.currentStep > 1 {
                            viewModel.prevStep()
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 32)
                    .padding(.top, 16)

                    Spacer()

                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 2)

                            Rectangle()
                                .fill(Color.white)
                                .frame(width: geometry.size.width * viewModel.progress, height: 2)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.progress)
                        }
                    }
                    .frame(height: 2)
                    .padding(.trailing, 32)
                    .padding(.top, 16)
                }
                
                // Step content
                ScrollView {
                    VStack(spacing: 0) {
                        viewModel.currentStepView
                            .padding(.horizontal, 32)
                            .padding(.vertical, 24)
                            .opacity(viewModel.fadeAnim)
                            .offset(y: viewModel.slideAnim)
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
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1FC9C3")))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            } else {
                                Text(viewModel.currentStep == viewModel.totalSteps ? "Get Started" : "Continue")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "1FC9C3"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .disabled(viewModel.loading || !viewModel.canProceed)
                        .opacity(viewModel.canProceed ? 1.0 : 0.5)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.canProceed)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .navigationBarHidden(true)
    }
}
