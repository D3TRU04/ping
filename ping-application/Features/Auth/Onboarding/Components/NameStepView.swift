//
//  NameStepView.swift
//  PingNative
//
//  Name input step view for onboarding
//

import SwiftUI

struct NameStepView: View {
    @Binding var fullName: String
    let errors: [String: String]
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your name?")
                    .font(.system(size: 30, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("We use your name so friends can recognize and connect with you easily.")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 8) {
                TextField("Enter your full name", text: $fullName)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .textInputAutocapitalization(.words)
                    .focused($isFocused)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .glassInputStyle()
                    .onAppear {
                        isFocused = true
                    }

                if let error = errors["fullName"] {
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
