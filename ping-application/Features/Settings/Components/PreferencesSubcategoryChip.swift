//
//  PreferencesSubcategoryChip.swift
//  PingNative
//
//  Chip component for selected subcategories in preferences
//

import SwiftUI

struct PreferencesSubcategoryChip: View {
    let name: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(name)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppColors.textPrimary)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.12))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(1.0), location: 0.0),
                            .init(color: .white.opacity(0.7), location: 0.3),
                            .init(color: .white.opacity(0.5), location: 0.6),
                            .init(color: .white.opacity(0.85), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}
