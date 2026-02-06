//
//  GroupPlaceTypeTabButton.swift
//  PingNative
//
//  Tab button component for switching between place types
//

import SwiftUI

struct GroupPlaceTypeTabButton: View {
    let title: String
    let count: Int
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                Text("\(count)")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isActive ? Color.white.opacity(0.3) : Color.white.opacity(0.15))
                    .clipShape(Capsule())
            }
            .foregroundColor(isActive ? .white : AppColors.textPrimary.opacity(0.8))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .fixedSize(horizontal: true, vertical: false)
            .background(
                Group {
                    if isActive {
                        ZStack {
                            GlassSurface(cornerRadius: 30, opacity: 0.1) { Color.clear }
                            AppColors.mint.opacity(0.8)
                        }
                    } else {
                        GlassSurface(cornerRadius: 30, opacity: 0.05) { Color.clear }
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isActive ? Color.white.opacity(0.4) : Color.white.opacity(0.2), lineWidth: 0.5)
            )
            .shadow(
                color: isActive ? AppColors.mint.opacity(0.3) : Color.black.opacity(0.05),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }
}
