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
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(10)
                        .background(Color(hex: "F3F4F6"))
                        .clipShape(Circle())
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
            .font(.system(size: 12))
            .padding(.bottom, 48)
        }
        .background(Color.white)
        .interactiveDismissDisabled(false)
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.step)
    }
}
