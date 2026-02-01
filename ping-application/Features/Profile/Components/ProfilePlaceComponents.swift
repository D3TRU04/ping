//
//  ProfilePlaceComponents.swift
//  PingNative
//
//  Place-related UI components for profile views
//

import SwiftUI

// MARK: - Place List Item Model
struct PlaceListItem: Identifiable {
    let id: String
    let name: String
    let category: String
    let subcategory: String?
    let location: String
    let imageUrl: String?
    let rating: Double?
    let hours: [String]?
    let price: Int?
}

// MARK: - Places List
struct PlacesList: View {
    let places: [PlaceListItem]

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(places) { place in
                ProfilePlaceCard(place: place)
            }
        }
    }
}

// MARK: - Empty State View
struct ProfileEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7").opacity(0.15), Color(hex: "1FC9C3").opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .blur(radius: 10)

                Circle()
                    .fill(Color.white)
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)

                Image(systemName: icon)
                    .font(.system(size: 26, weight: .light))
                    .foregroundColor(AppColors.mint.opacity(0.6))
            }

            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .frame(maxWidth: 240)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 100)
    }
}
