//
//  AuthStepViews.swift
//  PingNative
//
//  Authentication-related step views for onboarding
//

import SwiftUI

// MARK: - Auth Options Step
struct AuthOptionsStepView: View {
    let onEmailSignup: () -> Void
    let onPhoneSignup: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Create your account")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)

                Text("Choose how you'd like to sign up for Ping")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 16) {
                // Phone Sign Up
                Button(action: onPhoneSignup) {
                    HStack {
                        Image(systemName: "iphone")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Sign up with Phone Number")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.borderSubtle, lineWidth: 1)
                    )
                }

                // Divider
                HStack {
                    Rectangle()
                        .fill(AppColors.borderSubtle)
                        .frame(height: 1)
                    Text("or")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.horizontal, 16)
                    Rectangle()
                        .fill(AppColors.borderSubtle)
                        .frame(height: 1)
                }
                .frame(width: 340)
                .padding(.vertical, 16)

                // Email Sign Up
                Button(action: onEmailSignup) {
                    HStack {
                        Image(systemName: "envelope")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Sign up with Email")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.borderSubtle, lineWidth: 1)
                    )
                }
            }

            Spacer()
        }
    }
}

// MARK: - Phone Number Step
struct PhoneNumberStepView: View {
    @Binding var phoneNumber: String
    let errors: [String: String]
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your number?")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)

                Text("We'll use this to verify your account.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text("\u{1F1FA}\u{1F1F8}")
                        .font(.system(size: 20))
                    Text("+1")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    Rectangle()
                        .fill(AppColors.borderSubtle)
                        .frame(width: 1, height: 24)
                        .padding(.horizontal, 8)

                    TextField("Phone number", text: $phoneNumber)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(AppColors.textPrimary)
                        .keyboardType(.numberPad)
                        .focused($isFocused)
                        .onChange(of: phoneNumber) { newValue in
                            phoneNumber = formatPhoneNumber(newValue)
                        }
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color(hex: "F3F4F6"))
                .cornerRadius(20)
                .onAppear {
                    isFocused = true
                }

                if let error = errors["phoneNumber"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()
        }
    }

    private func formatPhoneNumber(_ number: String) -> String {
        let cleanNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "XXX-XXX-XXXX"
        var result = ""
        var index = cleanNumber.startIndex

        for ch in mask where index < cleanNumber.endIndex {
            if ch == "X" {
                result.append(cleanNumber[index])
                index = cleanNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}

// MARK: - Email Step
struct EmailStepView: View {
    @Binding var email: String
    let errors: [String: String]
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your email?")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)

                Text("We'll use this to create your account and keep you signed in.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 8) {
                TextField("Enter your email address", text: $email)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(hex: "F3F4F6"))
                    .cornerRadius(20)
                    .onAppear {
                        isFocused = true
                    }

                if let error = errors["email"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()
        }
    }
}

// MARK: - OTP Step
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

// MARK: - Password Step
struct PasswordStepView: View {
    @Binding var password: String
    let errors: [String: String]
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Create a password")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)

                Text("Choose a strong password to keep your account secure.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 8) {
                SecureField("Enter your password", text: $password)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(hex: "F3F4F6"))
                    .cornerRadius(20)
                    .onAppear {
                        isFocused = true
                    }

                if let error = errors["password"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()
        }
    }
}
