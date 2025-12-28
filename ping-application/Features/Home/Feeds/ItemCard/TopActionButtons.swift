//
//  TopActionButtons.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/feeds/item-card/components/TopActionButtons.tsx
//  Top action buttons (save, share, like)
//

import SwiftUI

struct TopActionButtons: View {
    let isLiked: Bool
    let isSaved: Bool
    let onLike: () -> Void
    let onSave: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            IconButton(
                icon: isSaved ? "bookmark.fill" : "bookmark",
                onPress: onSave
            )
            
            IconButton(
                icon: "square.and.arrow.up",
                onPress: onShare
            )
            
            IconButton(
                icon: isLiked ? "heart.fill" : "heart",
                onPress: onLike,
                color: isLiked ? Color(hex: "FF5C5C") : AppColors.mint
            )
        }
    }
}
