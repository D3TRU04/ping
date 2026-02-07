//
//  FinalStepView.swift
//  PingNative
//
//  Final step view for onboarding completion
//

import SwiftUI

// MARK: - Final Step
struct FinalStepView: View {
    let errors: [String: String]

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(0.9), location: 0.0),
                                        .init(color: .white.opacity(0.5), location: 0.5),
                                        .init(color: .white.opacity(0.7), location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)

                Text("\u{1F389}")
                    .font(.system(size: 40))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("You're all set!")
                .font(.system(size: 30, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Welcome to the Ping community! We'll use your interests to personalize your experience.")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Error message for signup failures
            if let submitError = errors["submit"] {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(hex: "DC2626"))
                        .font(.system(size: 18))

                    Text(submitError)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "DC2626"))

                    Spacer()
                }
                .padding()
                .background(Color(hex: "FEE2E2"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "DC2626"), lineWidth: 1)
                )
                .cornerRadius(12)
            }

            VStack(spacing: 12) {
                FeatureCard(
                    icon: "\u{2713}",
                    iconColor: Color(hex: "1FC9C3"),
                    title: "Ready to Explore",
                    subtitle: "Discover amazing places around you"
                )

                FeatureCard(
                    icon: "person.2.fill",
                    iconColor: Color(hex: "4ECDC4"),
                    title: "Connect & Share",
                    subtitle: "Plan activities with friends"
                )
            }

            Spacer()
        }
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor)
                    .frame(width: 40, height: 40)

                if icon == "\u{2713}" {
                    Text(icon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding()
        .glassCardStyle(cornerRadius: 20)
    }
}
