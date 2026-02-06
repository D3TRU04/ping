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
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(place.name)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    if let rating = place.rating {
                        HStack(spacing: 3) {
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

                    Text(place.category.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                colors: SubcategoryGradientHelper.getGradient(place.category),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())

                    if let subcategory = place.subcategory, !subcategory.isEmpty {
                        Text(subcategory.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                LinearGradient(
                                    colors: SubcategoryGradientHelper.getGradient(subcategory),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                    }
                }

                if !place.location.isEmpty {
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10, weight: .regular))
                            .padding(.top, 2)
                        Text(place.location)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundColor(AppColors.textPrimary.opacity(0.65))
                }

                if let hours = formattedHours {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10, weight: .regular))
                        Text(hours)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                    }
                    .foregroundColor(AppColors.textTertiary)
                }
            }

            Spacer()

            VStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppColors.textTertiary)
                    .frame(width: 28, height: 28)
                    .background(Color(hex: "F3F4F6"))
                    .clipShape(Circle())
                Spacer()
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
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
