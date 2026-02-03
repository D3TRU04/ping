//
//  PhoneNumberStepView.swift
//  PingNative
//
//  Phone number input step view for onboarding
//

import SwiftUI

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
                        .font(.system(size: 16, weight: .regular))
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
