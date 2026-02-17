//
//  StartupView.swift
//  PingNative
//
//  App startup/landing view with login options
//

import SwiftUI

struct StartupView: View {
    @State private var showLoginModal = false
    private let loginModalDetent: PresentationDetent = .fraction(0.55)
    @State private var loginDetent: PresentationDetent = .fraction(0.55)
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack {
                Spacer()

                Image("ping-logo-white")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320, height: 320)
                    .brightness(0.2)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 40)

                Spacer()

                VStack(spacing: 20) {
                    NavigationLink(value: NavigationDestination.signUp) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                ZStack {
                                    Capsule().fill(Color.white.opacity(0.12))
                                    Capsule().fill(
                                        LinearGradient(
                                            stops: [
                                                .init(color: .white.opacity(0.2), location: 0.0),
                                                .init(color: .white.opacity(0.05), location: 0.3),
                                                .init(color: .white.opacity(0.0), location: 0.5),
                                                .init(color: .white.opacity(0.02), location: 1.0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    Capsule().fill(
                                        LinearGradient(
                                            colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .center
                                        )
                                    )
                                }
                            )
                            .clipShape(Capsule())
                            .overlay(
                                ZStack {
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                stops: [
                                                    .init(color: .white.opacity(1.0), location: 0.0),
                                                    .init(color: .white.opacity(0.7), location: 0.3),
                                                    .init(color: .white.opacity(0.5), location: 0.6),
                                                    .init(color: .white.opacity(0.85), location: 1.0)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                    Capsule()
                                        .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                                        .padding(1)
                                }
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(ScaleButtonStyle(scale: 0.97))
                    .padding(.horizontal, 24)

                    Button(action: {
                        showLoginModal = true
                    }) {
                        Text("Already have an account? Log in")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.bottom, 24)
                }

                Text("By tapping 'Get Started', you agree to our Privacy Policy and Terms of Service.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)
                    .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showLoginModal) {
            NavigationStack {
                LoginModalView(showLoginModal: $showLoginModal)
                    .onAppear { loginDetent = loginModalDetent }
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
            .presentationDetents([loginModalDetent, .large], selection: $loginDetent)
            .presentationDragIndicator(.visible)
        }
    }
}
