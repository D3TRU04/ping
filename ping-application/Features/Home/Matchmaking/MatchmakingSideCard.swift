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
                // Centered content with fixed heights for alignment
                VStack(spacing: 12) {
                    Spacer() // Push content to center
                    
                    // Subcategory pill with vertical gradient and solid border
                    GlassPill(
                        text: option.subcategory,
                        color: colors.dark
                    )

                    // Name
                    Text(option.name)
                        .font(.system(size: 18, weight: .medium, design: .rounded)) // Increased size/weight
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)

                    // Description
                    Text(option.description)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(4)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)

                    // Price
                    if !priceText.isEmpty {
                        Text(priceText)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textTertiary)
                            .padding(.top, 4)
                    }
                    
                    Spacer() // Push content to center
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill available space

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
                                    .font(.system(size: 16, weight: .bold))
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
        .frame(maxHeight: .infinity) // Ensure button expands
        .scaleEffect(isSelected ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: isSelected)
    }
}
