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
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)

                Text("Code sent to \(viewModel.phoneNumber)")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, 8)
            .padding(.bottom, 40)

            HStack(spacing: 12) {
                Image(systemName: "lock.shield")
                    .foregroundColor(AppColors.textSecondary)
                    .font(.system(size: 20))

                TextField("6-digit code", text: $viewModel.otpCode)
                    .font(.system(size: 18, weight: .medium))
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
            .background(Color(hex: "F3F4F6"))
            .cornerRadius(20)
            .padding(.horizontal, 24)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.error)
                    .padding(.top, 8)
            }

            Spacer().frame(height: 24)

            Button(action: {
                Task {
                    await viewModel.verifyOtpWithClerk(appEnvironment: appEnvironment)
                }
            }) {
                ZStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Verify")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
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
            .disabled(viewModel.isLoading || viewModel.otpCode.count != 6)
            .opacity((viewModel.isLoading || viewModel.otpCode.count != 6) ? 0.5 : 1)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
