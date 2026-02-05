//
//  SubcategoryMasonryCard.swift
//  PingNative
//
//  Visual card for Pinterest-style subcategory selection
//

import SwiftUI

struct SubcategoryMasonryCard: View {
    let subcategory: Subcategory
    let isSelected: Bool
    let height: CGFloat
    let onTap: () -> Void

    private var gradientColors: [Color] {
        MatchmakingColorUtils.getSubcategoryGradient(subcategory.name)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Spacer()

                // Large emoji icon
                Text(subcategory.icon)
                    .font(.system(size: 36))

                // Subcategory name
                Text(subcategory.name)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Spacer()
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                GlassSurface(cornerRadius: 16, opacity: isSelected ? 0.15 : 0.08) {
                    if isSelected {
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ).opacity(0.3)
                    } else {
                        Color.clear
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? AppColors.mint : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.96))
    }
}

// Height generator for varied card sizes
enum SubcategoryCardHeight {
    static func forIndex(_ index: Int) -> CGFloat {
        // Alternate between different heights for visual variety
        let heights: [CGFloat] = [160, 140, 180, 150, 170, 145]
        return heights[index % heights.count]
    }
}
