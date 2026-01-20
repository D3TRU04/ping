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
    let subcategory: String?
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
                        
                        VStack(alignment: .trailing, spacing: 6) {
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
                            
                            if let priceRange = priceRange, priceRange > 0 {
                                Text(String(repeating: "$", count: priceRange))
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "FBBF24"))
                                    .shadow(color: Color(hex: "FBBF24").opacity(0.5), radius: 4, x: 0, y: 0)
                                    .padding(.trailing, 4)
                            }
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
                    
                    // Hours row (Price removed)
                    HStack(spacing: 12) {
                        // Hours Display - Always show if available
                        if !hours.isEmpty {
                            HoursDisplay(
                                hours: hours,
                                expanded: expandedHours,
                                onToggle: onToggleHours
                            )
                        }
                    }
                    
                    // Subcategory
                    if let subcategory = subcategory, !subcategory.isEmpty {
                        Text(subcategory)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    colors: getSubcategoryGradient(subcategory),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                    }
                    
                    // Description
                    if let description = description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .lineSpacing(3)
                            // Removed lineLimit to prevent cutoff
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
    
    private func getSubcategoryGradient(_ name: String) -> [Color] {
        // Deterministic selection based on string content
        let sum = name.utf8.reduce(0, { $0 + Int($1) })
        let index = sum % 6
        
        switch index {
        case 0:
            return [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")] // Mint
        case 1:
            return [Color(hex: "FF9F43"), Color(hex: "EE5A24")] // Orange
        case 2:
            return [Color(hex: "54a0ff"), Color(hex: "2e86de")] // Blue
        case 3:
            return [Color(hex: "a55eea"), Color(hex: "8854d0")] // Purple
        case 4:
            return [Color(hex: "ff6b6b"), Color(hex: "ee5253")] // Red
        case 5:
            return [Color(hex: "1dd1a1"), Color(hex: "10ac84")] // Green
        default:
            return [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")]
        }
    }
}
