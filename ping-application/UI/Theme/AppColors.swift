//
//  AppColors.swift
//  PingNative
//
//  Source: ping/apps/src/theme/colors.ts
//  Generated Swift equivalent
//

import SwiftUI

struct AppColors {
    // Primary colors
    static let coral = Color(hex: "1FC9C3")
    static let sunnyYellow = Color(hex: "FFD93D")
    static let nightPurple = Color(hex: "6B4EFF")
    static let mint = Color(hex: "1FC9C3")
    
    // UI elements
    static let background = Color.white
    static let text = Color(hex: "2D3436")
    static let textSecondary = Color(hex: "636E72")
    static let cardBackground = Color(hex: "F5F6FA")
    
    // Additional UI colors
    static let success = Color(hex: "00B894")
    static let error = Color(hex: "D63031")
    static let warning = Color(hex: "FDCB6E")
    static let info = Color(hex: "0984E3")
    
    // Card colors
    static let cardShadow = Color.black.opacity(0.1)
    
    // Swipe indicators
    static let like = Color(hex: "00B894")
    static let dislike = Color(hex: "D63031")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
