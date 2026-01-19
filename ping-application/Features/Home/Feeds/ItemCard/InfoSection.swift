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
    let location: String?
    let rating: Double?
    let priceRange: Int?
    let hours: [String]
    let description: String?
    let expandedHours: Bool
    let onToggleHours: () -> Void
    let onDirections: () -> Void
    let onCall: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Scrollable content area
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    // Title and Rating
                    HStack(alignment: .top) {
                        Text(name)
                            .font(.system(size: name.count > 28 ? 18 : 22, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        if let rating = rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "FBBF24"))
                                
                                Text(String(format: "%.1f", rating))
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "F3F4F6"))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.top, 14)
                    
                    // Location
                    if let location = location, !location.isEmpty {
                        HStack(alignment: .top, spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textTertiary)
                                .padding(.top, 2)
                            Text(location)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    // Price Range and Hours row
                    HStack(spacing: 12) {
                        if let priceRange = priceRange, priceRange > 0 {
                            Text(String(repeating: "$", count: priceRange))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        
                        // Hours Display - Always show if available
                        if !hours.isEmpty {
                            HoursDisplay(
                                hours: hours,
                                expanded: expandedHours,
                                onToggle: onToggleHours
                            )
                        }
                    }
                    
                    // Description
                    if let description = description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .lineSpacing(3)
                            .lineLimit(3)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Footer Buttons - Always pinned at bottom
            FooterButtons(
                placeName: name,
                onDirections: onDirections,
                onCall: onCall
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 8)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 20)
                .offset(y: -20),
                alignment: .top
            )
        }
    }
}
