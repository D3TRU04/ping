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
                    .background(isActive ? Color.white.opacity(0.3) : Color.black.opacity(0.05))
                    .clipShape(Capsule())
            }
            .foregroundColor(isActive ? .white : AppColors.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .fixedSize(horizontal: true, vertical: false)
            .background(
                Group {
                    if isActive {
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        Color(hex: "F3F4F6")
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                isActive ? Capsule().stroke(Color(hex: "1FC9C3"), lineWidth: 1) : nil
            )
            .shadow(
                color: isActive ? Color.black.opacity(0.12) : Color.clear,
                radius: 20,
                x: 0,
                y: 10
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.95))
    }
}
