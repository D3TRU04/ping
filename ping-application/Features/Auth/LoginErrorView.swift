//
//  LoginErrorView.swift
//  PingNative
//
//  Error message component for login view
//

import SwiftUI

struct LoginErrorView: View {
    let errorMessage: String
    let onDismiss: () -> Void
    let onSignIn: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(AppColors.error)
                .font(.system(size: 18))

            VStack(alignment: .leading, spacing: 4) {
                Text(errorMessage)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(AppColors.error)

                Button(action: onSignIn) {
                    Text("Go to Sign In →")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.error)
                }
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(AppColors.error)
                    .font(.system(size: 18))
            }
        }
        .padding()
        .background(AppColors.error.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.error, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}
