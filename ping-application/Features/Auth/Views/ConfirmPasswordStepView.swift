//
//  ConfirmPasswordStepView.swift
//  PingNative
//
//  Confirm password step for signup flow
//

import SwiftUI

struct ConfirmPasswordStepView: View {
    @Binding var password: String
    let errors: [String: String]
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm password")
                    .font(.system(size: 30, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Re-enter your password to ensure it matches.")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 8) {
                SecureField("Re-enter your password", text: $password)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .glassInputStyle()
                    .onAppear {
                        isFocused = true
                    }

                if let error = errors["confirmPassword"] {
                    Text(error)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()
        }
    }
}
