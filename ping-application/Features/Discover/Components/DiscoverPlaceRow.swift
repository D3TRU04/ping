//
//  DiscoverPlaceRow.swift
//  PingNative
//
//  Place row item for Discover bottom sheet
//

import SwiftUI

struct DiscoverPlaceRow: View {
    let place: Place

    var body: some View {
        HStack(spacing: 14) {
            PlaceRowThumbnail()

            PlaceRowInfo(place: place)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppColors.textTertiary)
                .frame(width: 28, height: 28)
                .background(Color.white.opacity(0.65))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(1.0), location: 0.0),
                                    .init(color: .white.opacity(0.8), location: 0.3),
                                    .init(color: .white.opacity(0.6), location: 0.6),
                                    .init(color: .white.opacity(0.9), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        }
        .padding(14)
        .glassCardStyle(cornerRadius: 16)
    }
}

// MARK: - Place Row Thumbnail
private struct PlaceRowThumbnail: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.65))
                .frame(width: 60, height: 60)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)

            ZStack {
                Circle()
                    .fill(Color(hex: "1FC9C3").opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(Color(hex: "1FC9C3"))
            }
        }
    }
}

// MARK: - Place Row Info
private struct PlaceRowInfo: View {
    let place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.name)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)

            HStack(spacing: 8) {
                if let category = place.category {
                    PlaceRowCategoryBadge(
                        text: category.replacingOccurrences(of: "_", with: " ").capitalized,
                        gradientColors: CategoryGradientHelper.getGradient(for: category)
                    )
                }

                if let subcategory = place.subcategory, !subcategory.isEmpty {
                    PlaceRowCategoryBadge(
                        text: subcategory.replacingOccurrences(of: "_", with: " ").capitalized,
                        gradientColors: CategoryGradientHelper.getGradient(for: subcategory)
                    )
                }

                if let rating = place.rating {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "FBBF24"))
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - Place Row Category Badge
private struct PlaceRowCategoryBadge: View {
    let text: String
    let gradientColors: [Color]

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .regular, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(Capsule())
    }
}
