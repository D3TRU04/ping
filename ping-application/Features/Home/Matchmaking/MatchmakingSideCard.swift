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

        GeometryReader { geometry in
            Button(action: action) {
                ZStack {
                    // Centered content with fixed layout
                    VStack(spacing: 12) {
                        Spacer() // Push content to center

                        // Subcategory pill with vertical gradient and solid border
                        GlassPill(
                            text: option.subcategory,
                            color: colors.dark
                        )

                        // Name - fixed height area with text wrapping
                        Text(option.name)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(3)
                            .minimumScaleFactor(0.8)
                            .multilineTextAlignment(.center)
                            .frame(height: 66) // Fixed height for 3 lines
                            .padding(.horizontal, 4)

                        // Description - fixed height area with text wrapping
                        Text(option.description)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(4)
                            .minimumScaleFactor(0.8)
                            .multilineTextAlignment(.center)
                            .frame(height: 72) // Fixed height for 4 lines
                            .padding(.horizontal, 4)

                        // Price - fixed height area
                        Text(priceText.isEmpty ? " " : priceText)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(priceText.isEmpty ? .clear : AppColors.textTertiary)
                            .frame(height: 20)

                        Spacer() // Push content to center
                    }
                    .padding(20)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                    // Selection overlay
                    if isSelected {
                        Color.white.opacity(0.25)
                            .cornerRadius(24)

                        VStack {
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(colors.dark)
                                }
                            }
                            Spacer()
                        }
                        .padding(16)
                    }
                }
                .glassCardStyle(cornerRadius: 32, opacity: 0.1)
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isSelected ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: isSelected)
        }
    }
}
