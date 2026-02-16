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
                    .font(.system(size: 14, weight: isActive ? .medium : .regular, design: .rounded))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                Text("\(count)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isActive ? Color.white.opacity(0.3) : Color.white.opacity(0.15))
                    .clipShape(Capsule())
            }
            .foregroundColor(isActive ? AppColors.textPrimary : AppColors.textPrimary.opacity(0.8))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .fixedSize(horizontal: true, vertical: false)
            .background(
                ZStack {
                    if isActive {
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
                    } else {
                        GlassSurface(cornerRadius: 30, opacity: 0.05) { Color.clear }
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                ZStack {
                    Capsule()
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(isActive ? 1.0 : 0.6), location: 0.0),
                                    .init(color: .white.opacity(isActive ? 0.7 : 0.3), location: 0.3),
                                    .init(color: .white.opacity(isActive ? 0.5 : 0.2), location: 0.6),
                                    .init(color: .white.opacity(isActive ? 0.85 : 0.5), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isActive ? 1 : 0.5
                        )
                    if isActive {
                        Capsule()
                            .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                            .padding(1)
                    }
                }
            )
            .shadow(
                color: isActive ? Color.black.opacity(0.1) : Color.black.opacity(0.05),
                radius: isActive ? 12 : 6,
                x: 0,
                y: isActive ? 6 : 3
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }
}
