//
//  LoginModalView.swift
//  PingNative
//
//  Modal view for user login with phone/email
//

import SwiftUI

struct LoginModalView: View {
    @Binding var showLoginModal: Bool
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel = LoginViewModel()
    @State private var isEmailMode: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with Close Button
            HStack {
                Spacer()
                Button(action: {
                    showLoginModal = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(10)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .white.opacity(0.9), location: 0.0),
                                            .init(color: .white.opacity(0.5), location: 0.5),
                                            .init(color: .white.opacity(0.7), location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 64)

            if viewModel.step == .input {
                LoginInputStepView(
                    viewModel: viewModel,
                    isEmailMode: $isEmailMode,
                    appEnvironment: appEnvironment
                )
            } else {
                LoginOtpStepView(
                    viewModel: viewModel,
                    appEnvironment: appEnvironment
                )
            }

            Spacer()

            // Footer Terms
            VStack(spacing: 6) {
                Text("By continuing, you agree to our")
                    .foregroundColor(AppColors.textTertiary)
                HStack(spacing: 4) {
                    Text("Terms of Service")
                        .underline()
                    Text("and")
                        .foregroundColor(AppColors.textTertiary)
                    Text("Privacy Policy")
                        .underline()
                }
                .foregroundColor(AppColors.textSecondary)
            }
            .font(.system(size: 12, design: .rounded))
            .padding(.bottom, 48)
        }
        .background(Color.white)
        .interactiveDismissDisabled(false)
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.step)
    }
}
