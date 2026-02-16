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
            Image(systemName: icon)
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 56, height: 56)
                .background(
                    GlassSurface(cornerRadius: 28, opacity: 0.05) {
                        Color.clear
                    }
                )
                .clipShape(Circle())

            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
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
        .padding(.top, 48)
        .padding(.bottom, 100)
    }
}
