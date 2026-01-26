//
//  DiscoverPlaceCard.swift
//  PingNative
//
//  Selected place card component for Discover screen
//

import SwiftUI

struct DiscoverPlaceCard: View {
    let place: Place
    var isSatelliteMode: Bool = false
    let onDismiss: () -> Void
    let onNavigate: () -> Void

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

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(place.name)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(isSatelliteMode ? .white : AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if let address = place.address {
                    Text(address)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                PlaceCardDetails(
                    place: place,
                    isSatelliteMode: isSatelliteMode,
                    formattedHours: formattedHours
                )
            }

            Spacer(minLength: 0)

            PlaceCardActions(
                isSatelliteMode: isSatelliteMode,
                onDismiss: onDismiss,
                onNavigate: onNavigate
            )
        }
        .padding(20)
        .background(isSatelliteMode ? Color.black.opacity(0.8) : Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Place Card Details
private struct PlaceCardDetails: View {
    let place: Place
    let isSatelliteMode: Bool
    let formattedHours: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                if let rating = place.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "FBBF24"))
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textSecondary)
                    }
                }

                HStack(spacing: 6) {
                    if let category = place.category {
                        CategoryBadge(
                            text: category.replacingOccurrences(of: "_", with: " ").capitalized,
                            isSatelliteMode: isSatelliteMode,
                            gradientColors: CategoryGradientHelper.getGradient(for: category)
                        )
                    }

                    if let subcategory = place.subcategory, !subcategory.isEmpty {
                        CategoryBadge(
                            text: subcategory.replacingOccurrences(of: "_", with: " ").capitalized,
                            isSatelliteMode: isSatelliteMode,
                            gradientColors: CategoryGradientHelper.getGradient(for: subcategory)
                        )
                    }
                }
            }

            if let hours = formattedHours {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textTertiary)
                    Text(hours)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(isSatelliteMode ? .white.opacity(0.9) : AppColors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Category Badge
private struct CategoryBadge: View {
    let text: String
    let isSatelliteMode: Bool
    let gradientColors: [Color]

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                LinearGradient(
                    colors: isSatelliteMode ? [Color.white.opacity(0.4), Color.white.opacity(0.2)] : gradientColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(Capsule())
    }
}

// MARK: - Place Card Actions
private struct PlaceCardActions: View {
    let isSatelliteMode: Bool
    let onDismiss: () -> Void
    let onNavigate: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textTertiary)
                    .frame(width: 36, height: 36)
                    .background(isSatelliteMode ? Color.white.opacity(0.2) : Color(hex: "F3F4F6"))
                    .clipShape(Circle())
            }

            Button(action: onNavigate) {
                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSatelliteMode ? .white : AppColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(isSatelliteMode ? Color.white.opacity(0.2) : Color(hex: "F3F4F6"))
                    .clipShape(Circle())
            }
        }
    }
}
