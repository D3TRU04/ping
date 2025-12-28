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
    
    var body: some View {
        Button(action: onPress) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.9))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}
