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
    static let primaryColor = Color.blue
    static let secondaryColor = Color.gray
    static let backgroundColor = Color(.systemBackground)
    static let cardBackgroundColor = Color(.secondarySystemBackground)
    
    // Spacing
    static let padding: CGFloat = 16
    static let cornerRadius: CGFloat = 12
    
    // Typography
    static let titleFont = Font.largeTitle
    static let headlineFont = Font.headline
    static let bodyFont = Font.body
}
