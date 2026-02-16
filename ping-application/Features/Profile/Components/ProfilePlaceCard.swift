//
//  ProfilePlaceCard.swift
//  PingNative
//
//  Place card component for profile views
//

import SwiftUI

struct ProfilePlaceCard: View {
    let place: PlaceListItem

    private var formattedHours: String? {
        guard let hours = place.hours, !hours.isEmpty else { return nil }

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let todayName = days[weekday - 1]

        if let todayHour = hours.first(where: { $0.hasPrefix(todayName) }) {
            if let colonIndex = todayHour.firstIndex(of: ":") {
                return String(todayHour[todayHour.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
            }
            return todayHour
        }
        return nil
    }

    private var priceString: String? {
        guard let price = place.price, price > 0 else { return nil }
        return String(repeating: "$", count: price)
    }

    var body: some View {
        GlassSurface(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(place.name)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if !place.location.isEmpty {
                    Text(place.location)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 12) {
                        if let rating = place.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "FBBF24"))
                                Text(String(format: "%.1f", rating))
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }

                        if let price = priceString {
                            Text(price)
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        HStack(spacing: 6) {
                            Text(place.category.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.black.opacity(0.06))
                                .clipShape(Capsule())

                            if let subcategory = place.subcategory, !subcategory.isEmpty {
                                Text(subcategory.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.black.opacity(0.06))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    if let hours = formattedHours {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(AppColors.textTertiary)
                            Text(hours)
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
    }
}

// MARK: - Gradient Helper
struct SubcategoryGradientHelper {
    static func getGradient(_ name: String) -> [Color] {
        let lowerName = name.lowercased()

        if lowerName.contains("coffee") || lowerName.contains("cafe") || lowerName.contains("bakery") {
            return [Color(hex: "E2D1C3"), Color(hex: "CDB4A6")]
        } else if lowerName.contains("salad") || lowerName.contains("vegan") || lowerName.contains("park") {
            return [Color(hex: "A8E6CF"), Color(hex: "88D8B0")]
        } else if lowerName.contains("ocean") || lowerName.contains("sea") || lowerName.contains("pool") {
            return [Color(hex: "A1C4FD"), Color(hex: "8AB6F9")]
        } else if lowerName.contains("pizza") || lowerName.contains("burger") || lowerName.contains("taco") {
            return [Color(hex: "FAD390"), Color(hex: "F6B93B")]
        } else if lowerName.contains("dessert") || lowerName.contains("ice cream") || lowerName.contains("cake") {
            return [Color(hex: "F8A5C2"), Color(hex: "F78FB3")]
        } else if lowerName.contains("bar") || lowerName.contains("wine") || lowerName.contains("cocktail") {
            return [Color(hex: "D6A2E8"), Color(hex: "B39CD0")]
        } else if lowerName.contains("sushi") || lowerName.contains("japanese") || lowerName.contains("seafood") {
            return [Color(hex: "FFBE76"), Color(hex: "FFA502")]
        }

        let sum = name.utf8.reduce(0) { $0 + Int($1) }
        let index = sum % 8

        switch index {
        case 0: return [Color(hex: "81ECEC"), Color(hex: "00CEC9")]
        case 1: return [Color(hex: "74B9FF"), Color(hex: "0984E3")]
        case 2: return [Color(hex: "A29BFE"), Color(hex: "6C5CE7")]
        case 3: return [Color(hex: "FAB1A0"), Color(hex: "E17055")]
        case 4: return [Color(hex: "B2BEC3"), Color(hex: "636E72")]
        case 5: return [Color(hex: "FD79A8"), Color(hex: "E84393")]
        case 6: return [Color(hex: "E0C3FC"), Color(hex: "8EC5FC")]
        case 7: return [Color(hex: "55EFC4"), Color(hex: "00B894")]
        default: return [Color(hex: "81ECEC"), Color(hex: "00CEC9")]
        }
    }
}
