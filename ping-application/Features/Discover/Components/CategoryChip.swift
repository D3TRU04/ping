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
                        Color.white.opacity(0.65)
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Group {
                    if !isSelected {
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    stops: isSatelliteMode ? [
                                        .init(color: .white.opacity(0.5), location: 0.0),
                                        .init(color: .white.opacity(0.3), location: 0.3),
                                        .init(color: .white.opacity(0.2), location: 0.6),
                                        .init(color: .white.opacity(0.4), location: 1.0)
                                    ] : [
                                        .init(color: .white.opacity(1.0), location: 0.0),
                                        .init(color: .white.opacity(0.8), location: 0.3),
                                        .init(color: .white.opacity(0.6), location: 0.6),
                                        .init(color: .white.opacity(0.9), location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSatelliteMode ? 0.5 : 1.5
                            )
                    }
                }
            )
            .shadow(
                color: isSelected
                    ? Color(hex: "1FC9C3").opacity(0.3)
                    : Color.black.opacity(isSatelliteMode ? 0 : 0.06),
                radius: isSelected ? 8 : 6,
                x: 0,
                y: isSelected ? 4 : 3
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
