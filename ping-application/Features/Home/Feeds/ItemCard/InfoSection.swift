//
//  InfoSection.swift
//  PingNative
//
//  Info section with name, rating, price, hours, description, footer buttons
//
//  Related files:
//  - InfoSectionGradients.swift - Category gradient helper
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
                            .foregroundColor(AppColors.textPrimary.opacity(0.9)) // High visual weight
                            .lineLimit(2)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            if let rating = rating {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "FBBF24"))
                                    
                                    Text(String(format: "%.1f", rating))
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary.opacity(0.6))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(GlassSurface(cornerRadius: 8, opacity: 0.05) { Color.clear })
                            }
                            
                            if let priceRange = priceRange, priceRange > 0 {
                                Text(String(repeating: "$", count: priceRange))
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
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
                                .foregroundColor(AppColors.textTertiary.opacity(0.6))
                                .padding(.top, 2)
                            Text(location)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary.opacity(0.45)) // Tertiary weight
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
                    
                    // Category & Subcategory with dynamic color coding
                    HStack(spacing: 8) {
                        if let category = category, !category.isEmpty {
                            let categoryColors = MatchmakingColorUtils.getSubcategoryColors(category)
                            GlassPill(
                                text: category.replacingOccurrences(of: "_", with: " ").capitalized,
                                color: categoryColors.dark
                            )
                        }

                        if let subcategory = subcategory, !subcategory.isEmpty {
                            let subcategoryColors = MatchmakingColorUtils.getSubcategoryColors(subcategory)
                            GlassPill(
                                text: subcategory.replacingOccurrences(of: "_", with: " ").capitalized,
                                color: subcategoryColors.dark
                            )
                        }
                    }
                    
                    // Description
                    if let description = description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary.opacity(0.65)) // Secondary weight
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
            .background(Color.clear) // Transparent background for footer area
        }
    }
    
}
