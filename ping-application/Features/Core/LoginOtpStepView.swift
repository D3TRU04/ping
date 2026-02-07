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
                Text("Enter Verification Code")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Code sent to \(viewModel.phoneNumber)")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, 8)
            .padding(.bottom, 32)

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

            // Resend code button with cooldown
            if viewModel.resendCooldown > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 13, weight: .regular))
                    Text("Resend in \(viewModel.resendCooldown)s")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                }
                .foregroundColor(AppColors.textSecondary)
                .padding(.top, 16)
            } else {
                Button(action: {
                    Task {
                        await viewModel.sendOtpWithClerk(appEnvironment: appEnvironment)
                    }
                }) {
                    Text("Resend code")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 16)
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
