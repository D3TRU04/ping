//
//  MatchmakingSideCard.swift
//  PingNative
//
//  Side card component for this-or-that selection in matchmaking
//

import SwiftUI

struct MatchmakingSideCard: View {
    let option: PlaceOption
    let isSelected: Bool
    let action: () -> Void

    private var priceText: String {
        guard let price = option.priceRange, price > 0 else { return "" }
        return String(repeating: "$", count: min(price, 4))
    }

    var body: some View {
        let colors = MatchmakingColorUtils.getSubcategoryColors(option.subcategory)

        Button(action: action) {
            ZStack {
                // Base layer - frosted glass
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)

                // Glass tint layer
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Top highlight - simulates light hitting glass
                VStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 80)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))

                // Inner glow/edge highlight
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )

                // Centered content with fixed heights for alignment
                VStack(spacing: 12) {
                    // Subcategory pill with vertical gradient and solid border
                    Text(option.subcategory)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [colors.light, colors.dark],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colors.dark, lineWidth: 1.5)
                        )

                    // Name - fixed minimum height
                    Text(option.name)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 44)
                        .padding(.horizontal, 8)

                    // Description - fixed height container
                    Text(option.description)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 48)
                        .padding(.horizontal, 8)

                    // Price - fixed height container
                    Text(priceText.isEmpty ? " " : priceText)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(priceText.isEmpty ? .clear : AppColors.textTertiary)
                        .frame(height: 20)
                }
                .padding(16)

                // Selection overlay
                if isSelected {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.25))

                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(colors.dark)
                            }
                        }
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: isSelected)
    }
}
