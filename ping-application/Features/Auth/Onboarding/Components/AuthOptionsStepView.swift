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
