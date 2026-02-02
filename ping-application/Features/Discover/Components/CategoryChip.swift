//
//  CategoryChip.swift
//  PingNative
//
//  Category chip button component
//

import SwiftUI

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var isSatelliteMode: Bool = false
    let action: () -> Void

    private var isEmoji: Bool {
        icon.unicodeScalars.first?.properties.isEmoji ?? false
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isEmoji {
                    Text(icon)
                        .font(.system(size: 14))
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .regular))
                }
                Text(title)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
            }
            .foregroundColor(
                isSelected
                    ? .white
                    : (isSatelliteMode ? .white : AppColors.textPrimary)
            )
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else if isSatelliteMode {
                        Color.black.opacity(0.5)
                    } else {
                        Color.white
                    }
                }
            )
            .clipShape(Capsule())
            .shadow(
                color: isSelected
                    ? Color(hex: "1FC9C3").opacity(0.3)
                    : Color.black.opacity(isSatelliteMode ? 0 : 0.06),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
