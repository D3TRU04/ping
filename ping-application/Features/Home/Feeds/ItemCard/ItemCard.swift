//
//  ItemCard.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/feeds/item-card/ItemCard.tsx
//  Complete place card component with all sub-components
//

import SwiftUI
import UIKit

struct ItemCard: View {
    let item: Place
    let isLiked: Bool
    let isSaved: Bool
    let onImageError: () -> Void
    let imageFailed: Bool
    let currentUserId: String
    let onLikeChange: (Bool) -> Void
    let onSaveChange: (String) -> Void
    let showToast: () -> Void
    
    @State private var expandedHours: Bool = false
    
    private let cardHeight = UIScreen.main.bounds.height * 0.58
    
    var body: some View {
        VStack(spacing: 0) {
            // Image Section
            ImageSection(
                imageUrl: item.imageUrl,
                imageFailed: imageFailed,
                onImageError: onImageError,
                subtopic: item.subtopic,
                isLiked: isLiked,
                isSaved: isSaved,
                onLike: {
                    onLikeChange(!isLiked)
                },
                onSave: {
                    onSaveChange("Want to Go")
                },
                onShare: {
                    handleShare()
                },
                longitude: item.longitude ?? 0,
                latitude: item.latitude ?? 0
            )
            .frame(height: 220)
            
            // Info Section
            InfoSection(
                name: item.name,
                location: item.address,
                rating: item.rating,
                priceRange: item.priceRange,
                hours: item.hours ?? [],
                category: item.category,
                subcategory: item.subcategory,
                description: item.description,
                expandedHours: expandedHours,
                onToggleHours: {
                    expandedHours.toggle()
                },
                onDirections: {
                    openDirections()
                },
                onCall: {
                    makeCall()
                }
            )
        }
        .frame(height: cardHeight)
        .glassCardStyle(cornerRadius: 36, opacity: 0.05)
        // MARK: - Card Outer Spacing (prevents edge cutoff)
        .padding(.horizontal, 24) // Increased margin from screen edges
        .padding(.bottom, 24) // Vertical spacing between cards
    }
    
    private func handleShare() {
        // TODO: Implement share functionality
        let activityVC = UIActivityViewController(
            activityItems: [item.name, item.address ?? ""],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func openDirections() {
        guard let lat = item.latitude,
              let lng = item.longitude else { return }
        
        let url = URL(string: "maps://?daddr=\(lat),\(lng)")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func makeCall() {
        guard let phone = item.phone,
              let url = URL(string: "tel://\(phone)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
