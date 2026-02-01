//
//  UsernameStepView.swift
//  PingNative
//
//  Username input step view for onboarding
//

import SwiftUI

struct UsernameStepView: View {
    @Binding var username: String
    var usernameAvailable: Bool?
    let errors: [String: String]
    let onUsernameChanged: (String) -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your username")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)

                Text("Your username is your unique identity on Ping.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 12) {
                TextField("Enter username", text: $username)
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
                    .onChange(of: username) { newValue in
                        onUsernameChanged(newValue)
                    }
                    .onAppear {
                        isFocused = true
                    }

                if let error = errors["username"] {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color(hex: "EF4444"))
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "EF4444"))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "FEE2E2"))
                    .cornerRadius(12)
                }

                if let available = usernameAvailable {
                    HStack {
                        Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(.white)
                        Text(available ? "Username is available!" : "Username is already taken")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(available ? Color(hex: "10B981") : Color(hex: "EF4444"))
                    .cornerRadius(12)
                }
            }

            Spacer()
        }
    }
}
