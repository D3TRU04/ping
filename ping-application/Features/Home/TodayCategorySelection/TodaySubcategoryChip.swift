//
//  TodaySubcategoryChip.swift
//  PingNative
//
//  Subcategory chip/pill component for Today page selection flow
//

import SwiftUI

struct TodaySubcategoryChip: View {
    let subcategory: Subcategory
    let categoryColor: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
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
                Capsule().fill(isSelected ? categoryColor.opacity(0.3) : Color.white.opacity(0.15))
            )
            .overlay(
                Capsule().stroke(isSelected ? categoryColor : Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.95))
    }
}
