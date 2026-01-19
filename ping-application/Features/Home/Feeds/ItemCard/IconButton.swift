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
                .font(.system(size: 18, weight: .medium)) // Slightly smaller icon for better proportion
                .foregroundColor(filled ? .white : color)
                .frame(width: 40, height: 40)
                .background(
                    Group {
                        if filled {
                            LinearGradient(
                                colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        } else {
                            Color.white.opacity(0.95)
                        }
                    }
                )
                .clipShape(Circle())
                .shadow(color: filled ? Color(hex: "1FC9C3").opacity(0.3) : Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.9))
    }
}
