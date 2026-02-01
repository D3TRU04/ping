//
//  PreferencesNavBar.swift
//  PingNative
//
//  Navigation bar for preferences view
//

import SwiftUI

struct PreferencesNavBar: View {
    let onBack: () -> Void
    let onSave: () -> Void
    let isSaving: Bool

    var body: some View {
        HStack(alignment: .center) {
            Button(action: onBack) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 17))
                }
                .foregroundColor(AppColors.mint)
            }

            Spacer()

            Text("Preferences")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Button(action: onSave) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                        .scaleEffect(0.8)
                } else {
                    Text("Save")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.mint)
                }
            }
            .disabled(isSaving)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [Color(hex: "FAFAFA").opacity(0.95), Color(hex: "FAFAFA").opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
