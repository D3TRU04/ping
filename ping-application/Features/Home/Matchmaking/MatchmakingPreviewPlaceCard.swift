//
//  MatchmakingPreviewPlaceCard.swift
//  PingNative
//
//  Place card component for the matchmaking preview popup
//

import SwiftUI

struct MatchmakingPreviewPlaceCard: View {
    let place: Place

    private var priceString: String? {
        guard let price = place.priceRange, price > 0 else { return nil }
        return String(repeating: "$", count: price)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Place info (no image)
            VStack(alignment: .leading, spacing: 6) {
                Text(place.name)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    if let rating = place.rating, rating > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "FBBF24"))
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    if let price = priceString {
                        Text(price)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    if let category = place.category {
                        GlassPill(
                            text: category.replacingOccurrences(of: "_", with: " ").capitalized,
                            color: Color(hex: "A78BFA")
                        )
                    }

                    if let subcategory = place.subcategory, !subcategory.isEmpty {
                        GlassPill(
                            text: subcategory.replacingOccurrences(of: "_", with: " ").capitalized,
                            color: Color(hex: "2DD4BF")
                        )
                    }

                    Spacer(minLength: 0)
                }

                if let address = place.address, !address.isEmpty {
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10, weight: .medium))
                            .padding(.top, 2)
                        Text(address)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            // Chevron button
            VStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
                    .frame(width: 28, height: 28)
                    .background(
                        GlassSurface(cornerRadius: 14, opacity: 0.1) { Color.clear }
                    )
                    .clipShape(Circle())
                Spacer()
            }
        }
        .padding(16)
        .glassCardStyle(cornerRadius: 24, opacity: 0.1)
    }
}
