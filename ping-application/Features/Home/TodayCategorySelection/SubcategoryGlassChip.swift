//
//  SubcategoryGlassChip.swift
//  PingNative
//
//  Glass capsule chip for subcategory selection in the chip cloud
//

import SwiftUI

struct SubcategoryGlassChip: View {
    let subcategory: Subcategory
    let isSelected: Bool
    let onTap: () -> Void

    @State private var bounceScale: CGFloat = 1.0

    private var gradientColors: [Color] {
        MatchmakingColorUtils.getSubcategoryGradient(subcategory.name)
    }

    var body: some View {
        Button(action: {
            onTap()
            // Trigger bounce animation
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                bounceScale = 1.08
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    bounceScale = 1.0
                }
            }
        }) {
            HStack(spacing: 6) {
                Text(subcategory.icon)
                    .font(.system(size: 14))
                Text(subcategory.name)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        Capsule().fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ).opacity(0.3)
                        )
                    } else {
                        Capsule().fill(Color.white.opacity(0.15))
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected
                            ? AnyShapeStyle(AppColors.mint)
                            : AnyShapeStyle(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(1.0), location: 0.0),
                                        .init(color: .white.opacity(0.7), location: 0.4),
                                        .init(color: .white.opacity(0.5), location: 0.7),
                                        .init(color: .white.opacity(0.8), location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                              ),
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.95))
        .scaleEffect(bounceScale)
    }
}
