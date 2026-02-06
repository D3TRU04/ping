//
//  StartupView.swift
//  PingNative
//
//  App startup/landing view with login options
//

import SwiftUI

struct StartupView: View {
    @State private var showLoginModal = false
    @State private var loginDetent: PresentationDetent = .medium
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack {
                Spacer()

                Image("1")
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
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                ZStack {
                                    LinearGradient(
                                        colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    LinearGradient(
                                        stops: [
                                            .init(color: .white.opacity(0.25), location: 0.0),
                                            .init(color: .white.opacity(0.05), location: 0.4),
                                            .init(color: .clear, location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
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
                                                    .init(color: .white.opacity(0.9), location: 0.0),
                                                    .init(color: .white.opacity(0.5), location: 0.3),
                                                    .init(color: .white.opacity(0.3), location: 0.6),
                                                    .init(color: .white.opacity(0.7), location: 1.0)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                    Capsule()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                        .padding(1)
                                }
                            )
                            .shadow(color: Color(hex: "1FC9C3").opacity(0.35), radius: 20, x: 0, y: 10)
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
                    .foregroundColor(AppColors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)
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
