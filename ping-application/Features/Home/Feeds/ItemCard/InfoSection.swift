//
//  InfoSection.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/feeds/item-card/components/InfoSection.tsx
//  Info section with name, rating, price, hours, description, footer buttons
//

import SwiftUI

struct InfoSection: View {
    let name: String
    let rating: Double?
    let priceRange: Int?
    let hours: [String]
    let description: String?
    let expandedHours: Bool
    let onToggleHours: () -> Void
    let onDirections: () -> Void
    let onCall: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title and Rating
                HStack(alignment: .top) {
                    Text(name)
                        .font(.system(size: name.count > 28 ? 18 : 24, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if let rating = rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.yellow)
                            
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Price Range
                if let priceRange = priceRange {
                    Text(String(repeating: "$", count: priceRange))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 24)
                }
                
                // Hours Display
                if !hours.isEmpty {
                    HoursDisplay(
                        hours: hours,
                        expanded: expandedHours,
                        onToggle: onToggleHours
                    )
                    .padding(.horizontal, 24)
                }
                
                // Description
                if let description = description {
                    Text(description)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                }
                
                // Footer Buttons
                FooterButtons(
                    placeName: name,
                    onDirections: onDirections,
                    onCall: onCall
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
    }
}
