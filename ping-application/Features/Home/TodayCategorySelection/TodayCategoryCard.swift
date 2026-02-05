//
//  TodayCategoryCard.swift
//  PingNative
//
//  Category card component for Today page selection flow
//

import SwiftUI

struct TodayCategoryCard: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(category.icon)
                    .font(.system(size: 28))
                Text(category.name)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                GlassSurface(cornerRadius: 20, opacity: isSelected ? 0.15 : 0.08) {
                    if isSelected {
                        LinearGradient(
                            colors: category.gradient.map { Color(hex: $0) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ).opacity(0.3)
                    } else {
                        Color.clear
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? AppColors.mint : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.95))
    }
}
