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
                    ? AppColors.textPrimary
                    : (isSatelliteMode ? .white : AppColors.textPrimary)
            )
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        Capsule().fill(Color.white.opacity(0.18))
                        Capsule().fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.2), location: 0.0),
                                    .init(color: .white.opacity(0.05), location: 0.3),
                                    .init(color: .white.opacity(0.0), location: 0.5),
                                    .init(color: .white.opacity(0.02), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        Capsule().fill(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                    } else if isSatelliteMode {
                        Capsule().fill(Color.black.opacity(0.5))
                    } else {
                        Capsule().fill(Color.white.opacity(0.65))
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                ZStack {
                    Capsule()
                        .stroke(
                            LinearGradient(
                                stops: isSelected ? [
                                    .init(color: .white.opacity(1.0), location: 0.0),
                                    .init(color: .white.opacity(0.7), location: 0.3),
                                    .init(color: .white.opacity(0.5), location: 0.6),
                                    .init(color: .white.opacity(0.85), location: 1.0)
                                ] : isSatelliteMode ? [
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
                            lineWidth: isSelected ? 1 : (isSatelliteMode ? 0.5 : 1.5)
                        )
                    if isSelected {
                        Capsule()
                            .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                            .padding(1)
                    }
                }
            )
            .shadow(
                color: isSelected
                    ? Color.black.opacity(0.1)
                    : Color.black.opacity(isSatelliteMode ? 0 : 0.06),
                radius: isSelected ? 8 : 6,
                x: 0,
                y: isSelected ? 4 : 3
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
