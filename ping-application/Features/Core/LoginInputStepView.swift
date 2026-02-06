//
//  LoginInputStepView.swift
//  PingNative
//
//  Input step view for login modal
//

import SwiftUI

struct LoginInputStepView: View {
    @ObservedObject var viewModel: LoginViewModel
    @Binding var isEmailMode: Bool
    var appEnvironment: AppEnvironment

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Image(systemName: isEmailMode ? "envelope" : "iphone")
                    .font(.system(size: 44))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.bottom, 4)

                Text("Sign In")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isEmailMode.toggle()
                    }
                }) {
                    Text(isEmailMode ? "Use phone instead" : "Use email instead")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 40)

            HStack(spacing: 0) {
                if !isEmailMode {
                    HStack(spacing: 8) {
                        Text("🇺🇸")
                            .font(.system(size: 20))
                        Text("+1")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Rectangle()
                            .fill(AppColors.borderSubtle)
                            .frame(width: 1, height: 24)
                            .padding(.horizontal, 8)
                    }
                    .padding(.leading, 16)

                    TextField("Phone number", text: $viewModel.phoneNumber)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .keyboardType(.numberPad)
                        .padding(.trailing, 16)
                        .onChange(of: viewModel.phoneNumber) { newValue in
                            viewModel.phoneNumber = formatPhoneNumber(newValue)
                        }
                } else {
                    TextField("Email address", text: $viewModel.email)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 20)
                }
            }
            .frame(height: 64)
            .glassInputStyle()
            .padding(.horizontal, 24)
            .padding(.bottom, 32)

            GlassCTAButton(
                title: "Continue",
                isLoading: viewModel.isLoading,
                isDisabled: isEmailMode ? viewModel.email.isEmpty : viewModel.phoneNumber.isEmpty
            ) {
                if isEmailMode {
                    // Email Login
                } else {
                    Task {
                        await viewModel.sendOtpWithClerk(appEnvironment: appEnvironment)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
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
