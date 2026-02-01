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
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isEmailMode.toggle()
                    }
                }) {
                    Text(isEmailMode ? "Use phone instead" : "Use email instead")
                        .font(.system(size: 16, weight: .regular))
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
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)

                        Rectangle()
                            .fill(AppColors.borderSubtle)
                            .frame(width: 1, height: 24)
                            .padding(.horizontal, 8)
                    }
                    .padding(.leading, 16)

                    TextField("Phone number", text: $viewModel.phoneNumber)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                        .keyboardType(.numberPad)
                        .padding(.trailing, 16)
                        .onChange(of: viewModel.phoneNumber) { newValue in
                            viewModel.phoneNumber = formatPhoneNumber(newValue)
                        }
                } else {
                    TextField("Email address", text: $viewModel.email)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 20)
                }
            }
            .frame(height: 64)
            .background(Color(hex: "F3F4F6"))
            .cornerRadius(20)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)

            Button(action: {
                if isEmailMode {
                    // Email Login
                } else {
                    Task {
                        await viewModel.sendOtpWithClerk(appEnvironment: appEnvironment)
                    }
                }
            }) {
                ZStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Continue")
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
            .disabled(viewModel.isLoading || (isEmailMode ? viewModel.email.isEmpty : viewModel.phoneNumber.isEmpty))
            .opacity((viewModel.isLoading || (isEmailMode ? viewModel.email.isEmpty : viewModel.phoneNumber.isEmpty)) ? 0.5 : 1)
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
