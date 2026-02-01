//
//  PasswordStepView.swift
//  PingNative
//
//  Password input step view for onboarding
//

import SwiftUI

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
