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
    let category: String?
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
                    
                    // Category & Subcategory
                    HStack(spacing: 8) {
                        if let category = category, !category.isEmpty {
                            Text(category.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: getSubcategoryGradient(category),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(Capsule())
                        }
                        
                        if let subcategory = subcategory, !subcategory.isEmpty {
                            Text(subcategory.replacingOccurrences(of: "_", with: " ").capitalized)
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
        let lowerName = name.lowercased()
        
        // Semantic mapping for common themes
        if lowerName.contains("coffee") || lowerName.contains("cafe") || lowerName.contains("bakery") || lowerName.contains("bread") || lowerName.contains("waffle") || lowerName.contains("crepe") || lowerName.contains("breakfast") {
            return [Color(hex: "E2D1C3"), Color(hex: "CDB4A6")] // Soft Beige/Latte
        } else if lowerName.contains("salad") || lowerName.contains("vegan") || lowerName.contains("vegetarian") || lowerName.contains("park") || lowerName.contains("nature") || lowerName.contains("hike") {
            return [Color(hex: "A8E6CF"), Color(hex: "88D8B0")] // Soft Sage Green
        } else if lowerName.contains("ocean") || lowerName.contains("sea") || lowerName.contains("water") || lowerName.contains("pool") || lowerName.contains("swim") {
            return [Color(hex: "A1C4FD"), Color(hex: "8AB6F9")] // Soft Sky Blue
        } else if lowerName.contains("pizza") || lowerName.contains("burger") || lowerName.contains("fast food") || lowerName.contains("taco") {
            return [Color(hex: "FAD390"), Color(hex: "F6B93B")] // Soft Muted Yellow/Orange
        } else if lowerName.contains("dessert") || lowerName.contains("ice cream") || lowerName.contains("cake") || lowerName.contains("sweet") || lowerName.contains("donut") {
            return [Color(hex: "F8A5C2"), Color(hex: "F78FB3")] // Soft Pastel Pink
        } else if lowerName.contains("bar") || lowerName.contains("wine") || lowerName.contains("beer") || lowerName.contains("cocktail") || lowerName.contains("night") {
            return [Color(hex: "D6A2E8"), Color(hex: "B39CD0")] // Soft Lilac
        } else if lowerName.contains("sushi") || lowerName.contains("japanese") || lowerName.contains("seafood") {
            return [Color(hex: "FFBE76"), Color(hex: "FFA502")] // Soft Salmon
        }

        // Fallback deterministic selection with more variation
        let sum = name.utf8.reduce(0) { $0 + Int($1) }
        let index = sum % 8 

        switch index {
        case 0: // Soft Teal
            return [Color(hex: "81ECEC"), Color(hex: "00CEC9")]
        case 1: // Soft Periwinkle
            return [Color(hex: "74B9FF"), Color(hex: "0984E3")]
        case 2: // Soft Purple
            return [Color(hex: "A29BFE"), Color(hex: "6C5CE7")]
        case 3: // Soft Peach
            return [Color(hex: "FAB1A0"), Color(hex: "E17055")]
        case 4: // Soft Grey/Blue
            return [Color(hex: "B2BEC3"), Color(hex: "636E72")]
        case 5: // Soft Rose
            return [Color(hex: "FD79A8"), Color(hex: "E84393")]
        case 6: // Soft Lavender
            return [Color(hex: "E0C3FC"), Color(hex: "8EC5FC")]
        case 7: // Soft Mint
            return [Color(hex: "55EFC4"), Color(hex: "00B894")]
        default:
            return [Color(hex: "81ECEC"), Color(hex: "00CEC9")]
        }
    }
}
