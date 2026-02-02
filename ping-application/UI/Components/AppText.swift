//
//  AppText.swift
//  PingNative
//
//  Source: ping/apps/src/components/AppText.tsx
//  Generated Swift equivalent
//

import SwiftUI

struct AppText: View {
    let text: String
    var font: Font = .system(size: 16, weight: .regular)
    var color: Color = AppColors.text
    var alignment: TextAlignment = .leading
    
    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .multilineTextAlignment(alignment)
    }
}

// Convenience initializers
extension AppText {
    init(_ text: String, font: Font = .system(size: 16, weight: .regular), color: Color = AppColors.text) {
        self.text = text
        self.font = font
        self.color = color
    }
}
