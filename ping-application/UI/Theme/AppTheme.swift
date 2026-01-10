//
//  AppTheme.swift
//  PingNative
//
//  Created on 12/3/25.
//

import SwiftUI

/// App-wide theme constants
struct AppTheme {
    // Colors
    static let primaryColor = Color.black
    static let secondaryColor = Color.gray
    static let backgroundColor = Color(hex: "FAFAFA")
    static let cardBackgroundColor = Color.white
    
    // Spacing
    static let padding: CGFloat = 24
    static let cornerRadius: CGFloat = 20
    
    // Typography
    static let titleFont = Font.system(size: 32, weight: .bold, design: .default)
    static let headlineFont = Font.system(size: 18, weight: .semibold, design: .default)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .default)
}
