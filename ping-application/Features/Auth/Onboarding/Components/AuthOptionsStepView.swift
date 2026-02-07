//
//  AuthOptionsStepView.swift
//  PingNative
//
//  Auth options step view for onboarding
//

import SwiftUI

struct AuthOptionsStepView: View {
    let onEmailSignup: () -> Void
    let onPhoneSignup: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Create your account")
                    .font(.system(size: 30, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Choose how you'd like to sign up for Ping")
                    .font(.system(size: 16, design: .rounded))
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
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .glassCardStyle(cornerRadius: 20)
                }

                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(height: 1)
                    Text("or")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.horizontal, 16)
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
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
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .glassCardStyle(cornerRadius: 20)
                }
            }

            Spacer()
        }
    }
}
