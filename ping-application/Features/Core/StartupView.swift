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
            LinearGradient(
                colors: [Color(hex: "1FC9C3"), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

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
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
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
                    }
                    .padding(.horizontal, 32)

                    Button(action: {
                        showLoginModal = true
                    }) {
                        Text("Already have an account? Log in")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.bottom, 24)
                }

                Text("By tapping 'Get Started', you agree to our Privacy Policy and Terms of Service.")
                    .font(.system(size: 12))
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
