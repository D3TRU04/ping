//
//  IconButton.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/feeds/item-card/components/IconButton.tsx
//  Reusable icon button component
//

import SwiftUI

struct IconButton: View {
    let icon: String
    let onPress: () -> Void
    var color: Color = AppColors.mint
    var filled: Bool = false
    
    var body: some View {
        Button(action: onPress) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .regular)) // Slightly smaller icon for better proportion
                .foregroundColor(filled ? AppColors.textPrimary : color)
                .frame(width: 40, height: 40)
                .background(
                    ZStack {
                        Circle().fill(Color.white.opacity(filled ? 0.12 : 0.08))
                        if filled {
                            Circle().fill(
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
                            Circle().fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                )
                            )
                        } else {
                            GlassSurface(cornerRadius: 24, opacity: 0.08) {
                                Color.clear
                            }
                        }
                    }
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.95), location: 0.0),
                                    .init(color: .white.opacity(0.6), location: 0.3),
                                    .init(color: .white.opacity(0.4), location: 0.6),
                                    .init(color: .white.opacity(0.8), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.9))
    }
}
