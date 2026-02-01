//
//  OtpStepView.swift
//  PingNative
//
//  OTP verification step view for onboarding
//

import SwiftUI

struct OtpStepView: View {
    @Binding var otpCode: String
    let destination: String
    let errors: [String: String]
    var resendCountdown: Int = 0
    var isResending: Bool = false
    var onResendCode: (() -> Void)? = nil
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter Verification Code")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)

                Text("We sent a code to \(destination).")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "lock.shield")
                        .foregroundColor(AppColors.textSecondary)
                        .font(.system(size: 20))

                    TextField("6-digit code", text: $otpCode)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                        .keyboardType(.numberPad)
                        .onChange(of: otpCode) { newValue in
                            if newValue.count > 6 {
                                otpCode = String(newValue.prefix(6))
                            }
                        }
                        .focused($isFocused)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color(hex: "F3F4F6"))
                .cornerRadius(20)
                .onAppear {
                    isFocused = true
                }

                if let error = errors["otp"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Resend Code Button
                if let onResend = onResendCode {
                    Button(action: {
                        onResend()
                    }) {
                        HStack(spacing: 8) {
                            if isResending {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14, weight: .medium))
                            }

                            if resendCountdown > 0 {
                                Text("Resend code in \(resendCountdown)s")
                                    .font(.system(size: 16, weight: .medium))
                            } else {
                                Text("Resend code")
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                        .foregroundColor(resendCountdown > 0 ? AppColors.textTertiary : AppColors.mint)
                    }
                    .disabled(resendCountdown > 0 || isResending)
                    .padding(.top, 8)
                }
            }

            Spacer()
        }
    }
}
