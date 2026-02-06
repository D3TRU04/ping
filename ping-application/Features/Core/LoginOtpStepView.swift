//
//  LoginOtpStepView.swift
//  PingNative
//
//  OTP verification step view for login modal
//

import SwiftUI

struct LoginOtpStepView: View {
    @ObservedObject var viewModel: LoginViewModel
    var appEnvironment: AppEnvironment

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("OTP")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Code sent to \(viewModel.phoneNumber)")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, 8)
            .padding(.bottom, 40)

            HStack(spacing: 12) {
                Image(systemName: "lock.shield")
                    .foregroundColor(AppColors.textSecondary)
                    .font(.system(size: 20))

                TextField("6-digit code", text: $viewModel.otpCode)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .keyboardType(.numberPad)
                    .onChange(of: viewModel.otpCode) { newValue in
                        if newValue.count > 6 {
                            viewModel.otpCode = String(newValue.prefix(6))
                        }
                    }
            }
            .frame(height: 64)
            .padding(.horizontal, 20)
            .glassInputStyle()
            .padding(.horizontal, 24)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(AppColors.error)
                    .padding(.top, 8)
            }

            Spacer().frame(height: 24)

            GlassCTAButton(
                title: "Verify",
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.otpCode.count != 6
            ) {
                Task {
                    await viewModel.verifyOtpWithClerk(appEnvironment: appEnvironment)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
