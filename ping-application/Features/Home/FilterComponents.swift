//
//  FilterComponents.swift
//  PingNative
//
//  Filter UI components for the ForYou feed
//

import SwiftUI

// MARK: - Filter Sheet
struct FilterSheet: View {
    @Binding var filters: PlaceFilters
    @Binding var isPresented: Bool
    var onApply: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "FAFAFA").ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            FilterSection(title: "Sort By", icon: "arrow.up.arrow.down") {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(SortOption.allCases) { option in
                                        FilterChip(
                                            title: option.rawValue,
                                            icon: option.icon,
                                            isSelected: filters.sortBy == option,
                                            action: { filters.sortBy = option }
                                        )
                                    }
                                }
                            }

                            FilterSection(title: "Minimum Rating", icon: "star.fill") {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(RatingFilter.allCases) { rating in
                                        FilterChip(
                                            title: rating.rawValue,
                                            icon: rating == .any ? nil : "star.fill",
                                            isSelected: filters.minRating == rating,
                                            action: { filters.minRating = rating }
                                        )
                                    }
                                }
                            }

                            FilterSection(title: "Max Price", icon: "dollarsign.circle") {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(PriceFilter.allCases) { price in
                                        FilterChip(
                                            title: price.rawValue,
                                            icon: nil,
                                            isSelected: filters.maxPrice == price,
                                            action: { filters.maxPrice = price }
                                        )
                                    }
                                }
                            }

                            Spacer(minLength: 100)
                        }
                        .padding(24)
                    }

                    VStack(spacing: 16) {
                        Button(action: {
                            onApply()
                            isPresented = false
                        }) {
                            Text("Apply Filters")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color(hex: "1FC9C3"), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "FAFAFA").opacity(0), Color(hex: "FAFAFA")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    )
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filters.reset()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 32, height: 32)
                            .background(Color.black.opacity(0.05))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

// MARK: - Filter Section
struct FilterSection<Content: View>: View {
    let title: String
    let icon: String?
    @ViewBuilder let content: Content

    init(title: String, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(AppColors.mint)
                        .frame(width: 24, alignment: .center)
                }
                Text(title)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            content
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .regular))
                        .frame(width: 16, alignment: .center)
                }
                Text(title)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        Color.white
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "1FC9C3") : Color(hex: "E5E7EB"), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? AppColors.mint.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }
}
