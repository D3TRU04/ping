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
                .foregroundColor(.white)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(Capsule())
    }
}
